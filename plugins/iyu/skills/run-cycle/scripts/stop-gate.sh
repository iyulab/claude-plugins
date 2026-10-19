#!/bin/sh
# Stop hook for /iyu:run-cycle: decides from on-disk state whether a run may end its turn.
#
# Input:  the Stop hook JSON on stdin (cwd, transcript_path, ...).
# Output: {"decision":"block","reason":"..."} on stdout to keep the run going; nothing (or a
#         systemMessage) to let the turn end. Always exits 0 on a decision. A crash exits non-zero,
#         which Claude Code treats as a non-blocking error, so every failure here fails toward
#         allowing: a premature stop is escaped by invoking the skill again, a run that cannot end
#         is not escapable at all.
#
# Everything mechanical is decided here, deterministically. The one judgment that needs reading
# comprehension, auditing a FRONTIER-EXHAUSTED claim against the roadmap and ledgers, goes to a
# read-only auditor model with the exact file paths already resolved (section 6).
#
# IYU_RUN_CYCLE_AUDITOR, when set, replaces that auditor with a shell command that reads the
# prompt on stdin and prints {"ok": true|false, "reason": "..."}; the dry-run harness uses it.
#
# Processes are few on purpose: this runs on every turn end for the rest of the session once the
# skill is invoked, and each process costs a tenth of a second or more under Git Bash on Windows.
# Parsing is done by one awk run per input rather than by pipelines per file.

set -u

# --- helpers -----------------------------------------------------------------------------------

json_escape() {
    tr -d '\r' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |
        awk 'NR > 1 { printf "\\n" } { printf "%s", $0 }'
}

block() {
    printf '{"decision":"block","reason":"%s"}\n' "$(printf '%s' "$1" | json_escape)"
    exit 0
}

allow() { # optional $1: a note for the user
    if [ -n "${1:-}" ]; then
        printf '{"systemMessage":"%s"}\n' "$(printf '%s' "$1" | json_escape)"
    fi
    exit 0
}

# Prints the unescaped values of the named top-level string fields of the JSON on stdin, one per
# line, in the order given (an empty line for a missing field). Paths come out with forward slashes.
json_fields() {
    awk -v keys="$*" '
    { buf = buf $0 }
    END {
        n = split(keys, k, " ")
        for (i = 1; i <= n; i++) {
            v = ""
            p = index(buf, "\"" k[i] "\"")
            if (p) {
                rest = substr(buf, p + length(k[i]) + 2)
                sub(/^[ \t]*:[ \t]*/, "", rest)
                if (substr(rest, 1, 1) == "\"") {
                    for (j = 2; j <= length(rest); j++) {
                        c = substr(rest, j, 1)
                        if (c == "\\") {
                            j++; c = substr(rest, j, 1)
                            if (c == "\\") c = "/"; else if (c == "n" || c == "t") c = " "
                        }
                        else if (c == "\"") break
                        v = v c
                    }
                }
            }
            print v
        }
    }'
}

# --- 1. Who is driving? --------------------------------------------------------------------------
# A skill's Stop hook stays registered for the rest of the session. Once the human's latest message
# is something other than the /iyu:run-cycle invocation, the human has taken over and this turn is
# not the run's. Claude Code marks typed prompts with "origin":{"kind":"human"}; hook feedback and
# skill text never carry it. The format is undocumented, so no match means "unknown", not "no".

{ IFS= read -r cwd; IFS= read -r transcript; } <<EOF
$(tr -d '\r' | json_fields cwd transcript_path)
EOF

driving=unknown
if [ -n "$transcript" ] && [ -r "$transcript" ]; then
    driving=$(awk '
        index($0, "\"origin\":{\"kind\":\"human\"}") { last = $0; seen = 1 }
        END {
            if (!seen) print "unknown"
            else if (index(last, "<command-name>/iyu:run-cycle</command-name>")) print "yes"
            else print "no"
        }' "$transcript")
fi
[ "$driving" = no ] && allow

# --- 2. The log directory and this run's logs ----------------------------------------------------
# Numbers come from the file names and are compared as numbers: cycle-205 > cycle-99 > cycle-03,
# however many logs there are and whatever their modification times.

[ -n "$cwd" ] || cwd=$(pwd)

logs=$(find "$cwd" -mindepth 1 \( -name node_modules -o -name .git -o -name bin -o -name obj \
    -o -name dist -o -name build -o -name target -o -name .venv -o -name venv \) -prune \
    -o -type f -name 'cycle-*.md' -print 2>/dev/null | grep -E '/cycle-logs/cycle-[0-9]+\.md$')

stub_instruction="Open this run's first cycle log as a header-only stub before any cycle work: <continuity root>/cycle-logs/cycle-{NN}.md (NN = highest existing index + 1) with the lines Date: / Root: / Budget: {N} / Start: {NN} / Status: in-progress. This hook reads the run's budget and start only from that header."

if [ -z "$logs" ]; then
    [ "$driving" = yes ] && block "run-cycle has not written a cycle log yet. $stub_instruction"
    allow
fi

# Several log directories (an umbrella): the one holding the most recently modified log.
newest=
while IFS= read -r f; do
    if [ -z "$newest" ] || [ "$f" -nt "$newest" ]; then newest=$f; fi
done <<EOF
$logs
EOF
dir=${newest%/*}

# One pass over the directory's logs. The newest log is the highest index; its header gives this
# run's Budget:/Start:. Cycles completed = logs at or above Start whose Status: is complete. Also
# finds the latest complete log of this run and the complete log before it.
{
    IFS= read -r top_n; IFS= read -r top_log; IFS= read -r budget; IFS= read -r start
    IFS= read -r top_status; IFS= read -r completed; IFS= read -r latest_n; IFS= read -r latest
    IFS= read -r prev
} <<EOF
$(printf '%s\n' "$logs" | awk -v d="$dir" '
    function field(f, key,   line, c, v) {
        if ((f, key) in memo) return memo[f, key]
        c = 0; v = ""
        while (c < 20 && (getline line < f) > 0) {
            c++; sub(/\r$/, "", line); sub(/^[ \t>*_-]+/, "", line)
            if (index(line, key ":") == 1) {
                v = substr(line, length(key) + 2); sub(/^[ \t*_`]+/, "", v)
                v = match(v, /^[A-Za-z0-9-]+/) ? tolower(substr(v, 1, RLENGTH)) : ""
                break
            }
        }
        close(f)
        if (v ~ /^[0-9]+$/) v = v + 0
        return memo[f, key] = v
    }
    {
        p = $0; sub(/\/[^\/]*$/, "", p); if (p != d) next
        k = $0; sub(/.*\/cycle-/, "", k); sub(/\.md$/, "", k); k = k + 0
        path[k] = $0
        if (top == "" || k > top) top = k
    }
    END {
        b = field(path[top], "Budget"); s = field(path[top], "Start")
        print top; print path[top]; print b; print s; print field(path[top], "Status")
        if (b !~ /^[0-9]+$/ || s !~ /^[0-9]+$/) exit
        done = 0; latest = ""; prev = ""
        for (k in path)
            if (k + 0 >= s + 0 && field(path[k], "Status") == "complete") {
                done++
                if (latest == "" || k + 0 > latest + 0) latest = k
            }
        if (latest != "")
            for (k in path)
                if (k + 0 < latest + 0 && (prev == "" || k + 0 > prev + 0) && field(path[k], "Status") == "complete")
                    prev = k
        print done; print latest; print (latest == "" ? "" : path[latest]); print (prev == "" ? "" : path[prev])
    }')
EOF

if [ -z "$budget" ] || [ -z "$start" ]; then
    # The newest log predates the Budget:/Start: header, so this run has written nothing yet.
    [ "$driving" = yes ] && block "The newest log, $top_log, has no Budget:/Start: header, so this run has not opened its own log yet. $stub_instruction"
    allow
fi

# --- 3. Has this run already ended? ----------------------------------------------------------------
# A run ends by writing its report, whose block opens "Run: cycles {Start}-{last}". A report line
# whose range covers this run's Start, with the newest log complete, means the run is over.

reports=$(find "$dir" -maxdepth 1 -type f -name 'RUN-SUMMARY-*.md' 2>/dev/null)
covered=no
any_run_line=no
if [ -n "$reports" ]; then
    read -r covered any_run_line <<EOF
$(printf '%s\n' "$reports" | awk -v s="$start" '
    {
        while ((getline line < $0) > 0) {
            sub(/\r$/, "", line); sub(/^[ \t>*_-]+/, "", line)
            if (index(line, "Run:") != 1) continue
            any = 1
            # "cycles 202–205", "cycles 202-205", or a single "cycle 7"; a later date is not a bound.
            if (!match(line, /[Cc]ycles?[ \t]+[0-9]+/)) continue
            r = substr(line, RSTART); sub(/^[Cc]ycles?[ \t]+/, "", r)
            match(r, /^[0-9]+/); a = substr(r, 1, RLENGTH) + 0; r = substr(r, RLENGTH + 1)
            b = a
            if (match(r, /^[ \t]*(-|–|—|~|to|\.\.)[ \t]*[0-9]+/)) {
                r = substr(r, 1, RLENGTH); sub(/^[^0-9]*/, "", r); b = r + 0
            }
            if (a <= s + 0 && s + 0 <= b) cov = 1
        }
        close($0)
    }
    END { print (cov ? "yes" : "no"), (any ? "yes" : "no") }')
EOF
fi
report_ok=no
if [ "$covered" = yes ]; then report_ok=yes
elif [ -n "$reports" ] && [ "$any_run_line" = no ]; then report_ok=yes  # reports from before the Run: header
fi

# Without a readable transcript, an ended run is the strongest evidence that this turn is not the
# run's: the human kept working after it.
if [ "$covered" = yes ] && [ "$top_status" = complete ] && [ "$driving" = unknown ]; then
    allow
fi

# --- 4. Run-ending conditions --------------------------------------------------------------------

today=$(date +%Y-%m-%d)

report_instruction() { # $1 = last completed cycle number
    printf '%s' "Write the End-of-Run Report before ending: $dir/RUN-SUMMARY-$today.md (if that file exists, append a new block below the existing ones; never overwrite). The block opens with exactly this line: \`Run: cycles ${start}–$1 · ended $today\`, then three parts: (1) progress, with STEP 3 evidence; (2) deferred L2 decisions, briefed; (3) self-made L1 decisions, each with how to reverse it. Then make the end-of-run commit and invoke /iyu:handoff."
}

finish() { # every allow path that ends a run passes the report check; $1 = optional user note
    if [ "$report_ok" = yes ]; then allow "${1:-}"; fi
    block "This run is over ($completed of $budget cycles complete since cycle $start), but its report is missing. $(report_instruction "${latest_n:-$top_n}")"
}

if [ -z "$latest" ]; then
    block "Cycle $top_n of this run is in progress (its log, $top_log, still says Status: in-progress) and no cycle of this run is complete yet, 0 of $budget. Keep working: finish that cycle through STEP 5, flip its Status: to complete, and go straight on to the next cycle without ending the turn."
fi

# What the latest complete log says: a run-fatal HUMAN-NEEDED (in it or in the newest log), and its
# frontier token. Only a HUMAN-NEEDED: at the start of a line counts; prose that mentions the token
# mid-sentence is not an emission. The token is read from the Emergent Next Capability line (or the
# three lines after it); only when that has none is the whole log searched.
{
    IFS= read -r human_needed; IFS= read -r token; IFS= read -r candidate; IFS= read -r next_scope
} <<EOF
$(awk -v latest="$latest" '
    function kind(s) {
        o = index(s, "FRONTIER-OPEN:") > 0; x = index(s, "FRONTIER-EXHAUSTED:") > 0
        return o && x ? "both" : o ? "open" : x ? "exhausted" : ""
    }
    FNR == 1 { win = 0 }
    { sub(/\r$/, "") }
    /^[ \t>*_-]*`?HUMAN-NEEDED:/ { hn = 1 }
    FILENAME != latest { next }
    /Emergent Next Capability/ { win = FNR + 3 }
    win && FNR <= win && kind($0) != "" && line == "" { line = $0 }
    kind($0) != "" { any = any $0 "\n" }
    scope == "" && /Next-Cycle Scope/ { scope = $0 }
    END {
        print (hn ? "yes" : "no")
        if (line == "") line = any
        t = kind(line); print (t == "" ? "none" : t)
        c = line; sub(/\n.*$/, "", c); sub(/.*FRONTIER-OPEN:[` \t]*/, "", c); sub(/`[ \t]*$/, "", c); print c
        sub(/^[ \t*-]+/, "", scope); sub(/[. \t]+$/, "", scope); print scope
    }' "$latest" "$top_log")
EOF

[ "$human_needed" = yes ] && finish
[ "$completed" -ge "$budget" ] && finish

# --- 5. Budget remains: the frontier token decides -----------------------------------------------

token_shapes="Write exactly one of these literal tokens on the log's Emergent Next Capability line: \`FRONTIER-OPEN: <candidate> [autonomous|discussion]\` when STEP 5 derived a follow-on, or \`FRONTIER-EXHAUSTED: <why, across all three lenses> | ladder: <rung acted on, or \"no actionable signal — why\">\` when derivation across all three lenses produced nothing autonomous-eligible."

progress="run-cycle is mid-run: $completed of $budget cycles complete since cycle $start, budget remaining."
if [ "$top_n" != "$latest_n" ]; then
    next_step="continue cycle $top_n, whose log is already open as an in-progress stub"
else
    next_step="open the next cycle log as a stub (Budget: $budget / Start: $start / Status: in-progress) and run that cycle from STEP 0"
fi

case $token in
    none)
        block "$progress The latest complete log, $latest, carries no frontier token, so STEP 5's derivation was skipped, which is never a valid reason to stop. Re-run STEP 5 for cycle $latest_n and record the outcome. $token_shapes" ;;
    both)
        block "$progress The latest complete log, $latest, carries both FRONTIER-OPEN: and FRONTIER-EXHAUSTED: on its Emergent Next Capability line; exactly one is allowed. Fix the line, then continue. $token_shapes" ;;
    open)
        block "$progress Cycle $latest_n ended on FRONTIER-OPEN: $candidate — unblocked work remains. Keep working: $next_step, scoped by cycle $latest_n's ${next_scope:-Next-Cycle Scope}. Do not end the turn between cycles; end it only when the run itself ends." ;;
esac

# --- 6. FRONTIER-EXHAUSTED with budget remaining: audit the claim --------------------------------
# The token is the run's own claim that nothing unblocked remains. A token the same agent writes
# and then reads is not verification, so a separate model checks it against the files. It gets the
# paths already resolved and only read tools, so it can neither pick the wrong log nor write.

roadmap=
for r in "$dir/../ROADMAP.md" "$dir/../../ROADMAP.md"; do
    if [ -f "$r" ]; then roadmap=$r; break; fi
done

audit_prompt() {
    cat <<PROMPT
You audit one claim and answer with JSON only. You are read-only: never create, edit, move, or delete a file.

A development run stopped early: cycle log $latest ends with FRONTIER-EXHAUSTED:, the run's own claim that no unblocked autonomous work remains, although its cycle budget is not spent. Decide whether the claim holds. Read these files and nothing else:
- the latest cycle log: $latest
- the cycle log before it: ${prev:-none}
- the roadmap (a phase backlog): ${roadmap:-none}

The claim FAILS only if one of these is plainly true:
1. The latest log itself still names unblocked autonomous work: a Next-Cycle Scope that is not "None", an actionable Carry-Forward item, an autonomous-eligible candidate, or an actionable value-ladder signal.
2. An entry in the previous log's Blocked-on-Human or Decisions ledger is neither carried forward in the latest log nor recorded there as resolved (silently dropped).
3. The roadmap holds a phase that is plainly neither completed, nor parked in the latest log's Blocked-on-Human ledger, nor recorded under its Pending Human Decisions as discussion-class. Human-gated phases never count against the claim.

Judge only what is plain; you are spotting obviously remaining autonomous work, not adjudicating wording. A missing file, an empty roadmap, or a genuinely ambiguous case passes.

Answer with exactly one JSON object and nothing else:
{"ok": true, "reason": "<one line>"} when the claim holds;
{"ok": false, "reason": "<the remaining work, naming each phase, item, or dropped ledger entry>"} when it fails.
PROMPT
}

audit_note=
verdict=
if [ -n "${IYU_RUN_CYCLE_AUDITOR:-}" ]; then
    verdict=$(audit_prompt | (cd "$cwd" && sh -c "$IYU_RUN_CYCLE_AUDITOR") 2>/dev/null)
elif command -v claude >/dev/null 2>&1; then
    verdict=$(audit_prompt | (cd "$cwd" && claude -p --model haiku --setting-sources '' \
        --tools 'Read,Grep,Glob' --no-session-persistence) 2>/dev/null)
else
    audit_note="run-cycle: the FRONTIER-EXHAUSTED claim in $latest was not audited (the claude CLI is not on PATH)."
fi

# The last {"ok": ...} object in the answer: its ok value and its reason.
{ IFS= read -r audit_ok; IFS= read -r why; } <<EOF
$(printf '%s' "$verdict" | tr -d '\r' | tr '\n' ' ' | awk '{
    s = $0; obj = ""
    while (match(s, /\{[^{}]*"ok"[ \t]*:[ \t]*(true|false)[^{}]*\}/)) {
        obj = substr(s, RSTART, RLENGTH); s = substr(s, RSTART + RLENGTH)
    }
    if (obj == "") { print ""; print ""; exit }
    print (obj ~ /"ok"[ \t]*:[ \t]*true/ ? "true" : "false")
    print obj
}' | { IFS= read -r ok; IFS= read -r obj; printf '%s\n' "$ok"; printf '%s' "$obj" | json_fields reason; })
EOF

case $audit_ok in
    false)
        block "$progress Cycle $latest_n claims FRONTIER-EXHAUSTED:, but an audit of the logs and roadmap found unblocked work: ${why:-see the roadmap}. Continue with it: $next_step. If an item is in fact human-gated, park it in the Blocked-on-Human ledger or record it under Pending Human Decisions, then re-derive STEP 5. $token_shapes" ;;
    true) ;;
    *) [ -n "$audit_note" ] || audit_note="run-cycle: the FRONTIER-EXHAUSTED claim in $latest could not be audited (the auditor gave no verdict); the stop was allowed." ;;
esac

finish "$audit_note"
