#!/bin/sh
# Structural checks for a continuity root: continuity-docs.md section 7, by its codes.
#
# Usage:  sh docs-lint.sh <root>
#         <root> is the continuity root the caller already resolved (continuity-docs.md section 1);
#         this script never resolves or guesses one.
# Output: one verdict line per code, in section 7's order, each followed by its findings:
#           L04 FAIL (error) - 2 finding(s)
#             ROADMAP.md:12  completed item: - [x] ...
#         Verdicts: PASS, FAIL (error class), WARN (warn class), UNCHECKED. The last line is
#         "Result: PASS ..." or "Result: FAIL ...". No Result line means the script did not finish:
#         read every code as unchecked.
# Exit:   1 only when an error-class check found a violation; 0 otherwise. A check that cannot
#         reach a verdict - an unreadable file, a format it does not recognize, a failed scan -
#         counts as passed and is reported UNCHECKED, so the script never strands a handoff that a
#         later pass could fix.
#
# It only reads. Nothing in the root is written, created or moved.
#
# DOCS_LINT_TODAY (YYYY-MM-DD), when set, replaces today's date for L08; the fixture suite uses it.
#
# Processes are few on purpose: under Git Bash on Windows each one costs a tenth of a second or
# more. One awk scans every document, the shell tests link targets with its builtin `[ -e ]`, and
# one awk formats the report.

set -u
# The budgets are in characters, but whether awk's length() counts characters depends on the awk
# and the locale: macOS awk counts bytes in every locale, and C.UTF-8 is missing on some systems.
# So every awk runs on bytes (LC_ALL=C exists everywhere) and clen() counts UTF-8 characters.
LC_ALL=C
export LC_ALL

codes='L04 L05 L07 L10 L01 L06 L08'

all_unchecked() {
    for c in $codes; do
        case $c in L04 | L05 | L07 | L10) k=error ;; *) k=warn ;; esac
        printf '%s UNCHECKED (%s)\n  unchecked: %s\n' "$c" "$k" "$1"
    done
    printf 'Result: PASS (nothing checked: %s)\n' "$1"
    exit 0
}

root=${1:-}
[ -n "$root" ] || all_unchecked 'no continuity root given'
[ -d "$root" ] || all_unchecked "continuity root not found: $root"
cd "$root" 2>/dev/null || all_unchecked "continuity root not readable: $root"

files=''
for d in ROADMAP HANDOFF STRANDS HISTORY; do
    [ -r "$d.md" ] && files="$files $d.md"
done
[ -n "$files" ] || all_unchecked "no continuity docs in $root"

today=${DOCS_LINT_TODAY:-$(date +%Y-%m-%d 2>/dev/null)}
tab=$(printf '\t')

# --- scan: one awk over every document ---------------------------------------------------------
# Records, tab-separated:
#   CHK  code file              - the check ran on this file
#   UNC  code file reason       - the check could not run on this file
#   FND  code location message  - a violation
#   LINK file line target       - a relative link for the shell to resolve
# shellcheck disable=SC2086 # $files is a list of fixed names without spaces
scan=$(awk -v today="$today" '
function trim(s) { sub(/^[ \t]+/, "", s); sub(/[ \t]+$/, "", s); return s }
# Characters in a UTF-8 string read as bytes: every byte that is not a continuation byte.
function clen(s,    t) { t = s; return length(s) - gsub(/[\200-\277]/, "", t) }
function snip(s,    i, n) {
    s = trim(s); gsub(/\t/, " ", s)
    if (clen(s) <= 80) return s
    for (i = 1; i <= length(s); i++)  # cut before the 78th character, never inside one
        if (substr(s, i, 1) !~ /[\200-\277]/ && ++n == 78) break
    return substr(s, 1, i - 1) "..."
}
function fnd(code, loc, msg) { printf "FND\t%s\t%s\t%s\n", code, loc, msg }
function unc(code, f, why) { printf "UNC\t%s\t%s\t%s\n", code, f, why }
function chk(code, f) { printf "CHK\t%s\t%s\n", code, f }
function isdate(d) { return d ~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/ }
function days(d,    y, m, dd) { # days since a fixed epoch; only differences are used
    y = substr(d, 1, 4) + 0; m = substr(d, 6, 2) + 0; dd = substr(d, 9, 2) + 0
    if (m <= 2) { y--; m += 12 }
    return 365 * y + int(y / 4) - int(y / 100) + int(y / 400) + int((153 * (m - 3) + 2) / 5) + dd
}
function fmt(n,    s, r) { # 61234 -> 61,234
    s = n ""; r = ""
    while (length(s) > 3) { r = "," substr(s, length(s) - 2) r; s = substr(s, 1, length(s) - 3) }
    return s r
}

# A done mark at the head of the text: the item or heading itself is marked done.
function leads_done(t) {
    sub(/^[ \t]*(#+|[-*+]|[0-9]+[.)])[ \t]+/, "", t)
    gsub(/^[*_~ \t]+/, "", t)
    return t ~ /^(✅|✔|☑)/
}
# A table cell holding only a done token.
function done_cell(c) {
    c = trim(c); gsub(/[*_~]/, "", c); c = trim(c)
    gsub(/\xEF\xB8\x8F/, "", c) # the variation selector after a symbol
    return c ~ /^((✅|✔|☑)[ \t]*)?(done|DONE|Done|complete|completed|Completed|완료)?$/ && c != ""
}
# Returns 1 when the line marks an item done (L04); sets marked when it marks anything at all.
function done_line(s,    n, i, cell) {
    if (s ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+\[[ ]\]/) { marked = 1; return 0 }
    if (s ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]+\[[xX]\]/) { marked = 1; return 1 }
    if (s ~ /^[ \t]*(#+|[-*+]|[0-9]+[.)])[ \t]/ && leads_done(s)) { marked = 1; return 1 }
    if (s ~ /^[ \t]*\|/ && s !~ /^[ \t]*\|[ \t:|-]*$/) {
        n = split(s, cell, "|")
        for (i = 2; i < n; i++) if (done_cell(cell[i])) { marked = 1; return 1 }
    }
    return 0
}

function link_target(t) {
    t = trim(t)
    if (t ~ /^</) { sub(/^</, "", t); sub(/>.*$/, "", t) } else sub(/[ \t].*$/, "", t)
    if (t == "" || t ~ /^#/ || t ~ /^[A-Za-z][A-Za-z0-9+.-]*:/ || t ~ /^[\/\\]/ || t ~ /[{}$]/) return
    sub(/#.*$/, "", t); sub(/\?.*$/, "", t); gsub(/%20/, " ", t)
    if (t != "") printf "LINK\t%s\t%d\t%s\n", F, FNR, t
}
function scan_links(s) {
    gsub(/`[^`]*`/, "", s); gsub(/<!--.*-->/, "", s)
    if (match(s, /^[ \t]*\[[^]]+\]:[ \t]+[^ \t]+/)) { sub(/^[ \t]*\[[^]]+\]:[ \t]+/, "", s); link_target(s); return }
    while (match(s, /\]\([^)]*\)/)) {
        link_target(substr(s, RSTART + 2, RLENGTH - 3))
        s = substr(s, RSTART + RLENGTH)
    }
}

# L01 item budget: a block is a list item, a table row, a heading, or a paragraph, with its
# continuation lines.
function flush_block() {
    if (blen > budget_item) fnd("L01", F ":" bstart, "item of " fmt(blen) " characters (budget " fmt(budget_item) "): " bsnip)
    blen = 0; bstart = 0
}
function open_block(s) { flush_block(); bstart = FNR; blen = clen(s); bsnip = snip(s) }

function end_entry() { # HANDOFF ## Waiting on you entry
    if (!estart) return
    miss = ""
    if (!e_reg) miss = miss ", Registered"
    if (!e_blocks) miss = miss ", Blocks"
    if (e_blocker || e_tried || e_unblocks) {
        if (!e_blocker) miss = miss ", Blocker"
        if (!e_tried) miss = miss ", Tried"
        if (!e_unblocks) miss = miss ", Unblocks"
    }
    if (miss != "") fnd("L05", F ":" estart, "missing " substr(miss, 3) ": " ehead)
    if (e_reg) {
        if (!isdate(e_date)) unc("L08", F ":" estart, "Registered has no YYYY-MM-DD date: " ehead)
        else if (isdate(today) && days(today) - days(e_date) > 14)
            fnd("L08", F ":" estart, "registered " e_date ", " (days(today) - days(e_date)) " days ago (over 14): " ehead)
    }
    estart = 0
}

function start_file(f) {
    F = f; T = f; sub(/\.md$/, "", T)
    infence = 0; chars = 0; blen = 0; bstart = 0; marked = 0; done = 0
    sec = ""; structured = 0; waiting = 0; estart = 0
    h_run = 0; h_int = 0; h_grad = 0; grad = 0; entry = 0; beneath_at = 0
    dated = 0; other = 0
    budget_item = 1200
}

function end_file() {
    flush_block()
    budget = (T == "ROADMAP") ? 60000 : (T == "HANDOFF") ? 30000 : (T == "STRANDS") ? 12000 : 0
    if (budget && chars > budget) fnd("L01", F, fmt(chars) " characters (budget " fmt(budget) ")")
    chk("L01", F); chk("L07", F)
    if (T == "ROADMAP") {
        if (marked) chk("L04", F)
        else unc("L04", F, "marks nothing as open or done (prose); the next migration brings it into a checkable shape")
    } else if (T == "HANDOFF") {
        end_entry()
        if (!structured) {
            why = "no ## In flight / ## Next / ## Waiting on you heading - not the handoff format"
            unc("L04", F, why); unc("L05", F, why); unc("L08", F, why)
        } else {
            chk("L04", F)
            if (waiting) { chk("L05", F); if (isdate(today)) chk("L08", F); else unc("L08", F, "today'"'"'s date unknown") }
            else { unc("L05", F, "no ## Waiting on you section"); unc("L08", F, "no ## Waiting on you section") }
        }
    } else if (T == "STRANDS") {
        if (h_run != 1) fnd("L10", F, "heading \"## 진행 중\" occurs " h_run " times (expected 1) - report it, do not repair")
        if (h_int != 1) fnd("L10", F, "heading \"## 중단됨\" occurs " h_int " times (expected 1) - report it, do not repair")
        if (h_grad != 1) fnd("L10", F, "heading \"## 완료·졸업\" occurs " h_grad " times (expected 1) - report it, do not repair")
        else if (grad > 10) fnd("L10", F, grad " entries under ## 완료·졸업 (cap 10) - archive the oldest " (grad - 10))
        chk("L10", F)
    } else if (T == "HISTORY") {
        if (dated > 30) fnd("L10", F, dated " live entries (cap 30) - archive the oldest " (dated - 30))
        if (dated || !other) chk("L10", F)
        else unc("L10", F, "no \"- **YYYY-MM-DD**\" entries - entry format not recognized")
    }
}

FNR == 1 {
    if (NR > 1) end_file()
    start_file(FILENAME)
    if (substr($0, 1, 3) == "\xEF\xBB\xBF") $0 = substr($0, 4)
}
{
    sub(/\r$/, "")
    line = $0
    chars += clen(line) + 1

    if (line ~ /^[ \t]*(```|~~~)/) { infence = !infence; flush_block(); next }
    if (infence) next

    # L01 - the Updated line, and item blocks
    if (line ~ /^(>[ \t]*)?(\*\*)?Updated(\*\*)?[ \t]*:/ && clen(line) > 300)
        fnd("L01", F ":" FNR, "Updated line of " fmt(clen(line)) " characters (budget 300)")
    if (line ~ /^[ \t]*$/) flush_block()
    else if (line ~ /^[ \t]*(#+[ \t]|\|)/) { open_block(line); flush_block() }
    else if (line ~ /^[ \t]*([-*+]|[0-9]+[.)])[ \t]/) open_block(line)
    else if (bstart) { blen += clen(line); }
    else open_block(line)

    scan_links(line)

    is_heading = (line ~ /^#+[ \t]/)
    is_h2 = (line ~ /^##?[ \t]/)

    if (T == "ROADMAP") {
        if (done_line(line)) fnd("L04", F ":" FNR, "completed item: " snip(line))
    } else if (T == "HANDOFF") {
        if (is_h2) {
            end_entry()
            h = tolower(line)
            if (h ~ /(^##?[ \t]+|[ (])in flight([ )]|$)/) { sec = "In flight"; structured = 1 }
            else if (h ~ /(^##?[ \t]+|[ (])next([ )]|$)/) { sec = "Next"; structured = 1 }
            else if (h ~ /(^##?[ \t]+|[ (])waiting on you([ )]|$)/) { sec = "Waiting on you"; structured = 1; waiting = 1 }
            else sec = ""
            next
        }
        if (sec == "In flight" || sec == "Next") {
            if (done_line(line)) fnd("L04", F ":" FNR, "completed item in ## " sec ": " snip(line))
        } else if (sec == "Waiting on you") {
            if (line ~ /^###[ \t]/) {
                end_entry()
                estart = FNR; ehead = snip(substr(line, 4))
                e_reg = e_blocks = e_blocker = e_tried = e_unblocks = 0; e_date = ""
            } else if (estart) {
                if (line ~ /(^|[^A-Za-z])Registered(\*\*)?[ \t]*:/) {
                    e_reg = 1; d = line; sub(/.*Registered(\*\*)?[ \t]*:[ \t]*(\*\*)?/, "", d); e_date = substr(d, 1, 10)
                }
                if (line ~ /(^|[^A-Za-z])Blocks(\*\*)?[ \t]*:/) e_blocks = 1
                if (line ~ /(^|[^A-Za-z])Blocker(\*\*)?[ \t]*:/) e_blocker = 1
                if (line ~ /(^|[^A-Za-z])Tried(\*\*)?[ \t]*:/) e_tried = 1
                if (line ~ /(^|[^A-Za-z])Unblocks([ \t][^:*]*)?(\*\*)?[ \t]*:/) e_unblocks = 1
            }
        }
    } else if (T == "STRANDS") {
        if (is_h2) {
            entry = 0
            if (line ~ /^## 진행 중/) { h_run++; sec = "run" }
            else if (line ~ /^## 중단됨/) { h_int++; sec = "int" }
            else if (line ~ /^## 완료·졸업/) { h_grad++; sec = "grad" }
            else sec = ""
            next
        }
        if (sec == "") next
        if (line ~ /^[-*+][ \t]/) {
            entry = FNR; beneath_at = 0
            if (sec == "grad") grad++
            if (clen(line) > 800) fnd("L01", F ":" FNR, "strand entry of " fmt(clen(line)) " characters (budget 800)")
        } else if (entry && line !~ /^[ \t]*$/ && line !~ /^[ \t]*<!--.*-->[ \t]*$/ && !beneath_at) {
            beneath_at = FNR
            fnd("L10", F ":" FNR, "line beneath the strand entry at line " entry " - an entry is its one line: " snip(line))
        }
    } else if (T == "HISTORY") {
        if (line ~ /^[-*+][ \t]+(\*\*)?\[?[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/) dated++
        else if (line ~ /^[-*+][ \t]/ || line ~ /^\|/ || line ~ /^##+[ \t]/) other++
    }
}
END { if (NR > 0) end_file() }
' $files 2>/dev/null)
rc=$?

# --- resolve links: shell builtins only -----------------------------------------------------------
out=''
nl='
'
if [ "$rc" -ne 0 ]; then
    for c in $codes; do out="$out${nl}UNC$tab$c$tab-${tab}scan failed (awk exit $rc)"; done
else
    while IFS="$tab" read -r kind a b c; do
        case $kind in
        LINK)
            [ -e "$c" ] || out="$out${nl}FND${tab}L07$tab$a:$b${tab}link does not resolve: $c"
            ;;
        ?*) out="$out$nl$kind$tab$a$tab$b${c:+$tab$c}" ;;
        esac
    done <<EOF
$scan
EOF
fi

# --- report ----------------------------------------------------------------------------------------
printf '%s\n' "$out" | awk -F '\t' -v codes="$codes" -v root="$root" '
BEGIN {
    n = split(codes, order, " ")
    for (i = 1; i <= n; i++) cls[order[i]] = (order[i] ~ /^L0[45]$|^L07$|^L10$/) ? "error" : "warn"
    title["L04"] = "no completed item in ROADMAP.md or HANDOFF.md ## In flight / ## Next"
    title["L05"] = "every ## Waiting on you entry carries its fields"
    title["L07"] = "every relative link resolves"
    title["L10"] = "live-window caps and STRANDS.md shape"
    title["L01"] = "character budgets"
    title["L06"] = "a restated fact agrees with its home"
    title["L08"] = "no ## Waiting on you entry older than 14 days"
    unc_n["L06"] = 1
    unc_l["L06", 1] = "needs reading, not matching: the hygiene pass judges it"
    cap = 25
}
NF == 0 { next }
$1 == "CHK" { ran[$2] = 1; next }
$1 == "UNC" { k = ++unc_n[$2]; unc_l[$2, k] = ($3 == "-" ? "" : $3 " - ") $4; next }
$1 == "FND" { k = ++fnd_n[$2]; if (k <= cap) fnd_l[$2, k] = $3 "  " $4; next }
END {
    fail = ""; warn = ""; skipped = ""; partly = ""
    for (i = 1; i <= n; i++) {
        c = order[i]; f = fnd_n[c] + 0; u = unc_n[c] + 0
        if (f) v = (cls[c] == "error") ? "FAIL" : "WARN"
        else if (ran[c] || !u) v = "PASS"
        else v = "UNCHECKED"
        printf "%s %s (%s) - %s", c, v, cls[c], title[c]
        if (f) printf " - %d finding(s)", f
        printf "\n"
        for (k = 1; k <= f && k <= cap; k++) printf "  %s\n", fnd_l[c, k]
        if (f > cap) printf "  ... and %d more\n", f - cap
        for (k = 1; k <= u; k++) printf "  unchecked: %s\n", unc_l[c, k]
        if (v == "FAIL") fail = fail ", " c
        else if (v == "WARN") warn = warn ", " c
        else if (v == "UNCHECKED") skipped = skipped ", " c
        if (v != "UNCHECKED" && u) partly = partly ", " c
    }
    extra = ""
    if (warn != "") extra = extra "; warnings: " substr(warn, 3)
    if (skipped != "") extra = extra "; unchecked: " substr(skipped, 3)
    if (partly != "") extra = extra "; partly unchecked: " substr(partly, 3)
    if (fail != "") {
        printf "Result: FAIL - error-class: %s%s\n", substr(fail, 3), extra
        exit 1
    }
    printf "Result: PASS%s\n", (extra == "" ? "" : " (" substr(extra, 3) ")")
}'
[ $? -eq 1 ] && exit 1
exit 0
