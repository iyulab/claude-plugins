#!/bin/sh
# Mission setter for /iyu:walk: writes missions from a product's stated purpose, blind to its build.
#
# Usage:  set-missions.sh <brief-file> <input-file> <out-file>
#   brief-file  the setter brief (references/setter.md) — passed as the whole system prompt
#   input-file  the purpose material the skill quoted from the project (goal, users, environment)
#   out-file    where the setter's JSON goes; written only when the setter returns a JSON object
#
# Why a script and not a subagent: a subagent starts inside the repository with file tools and may
# inherit the project's instructions, so "do not read the code" would be a request, not a fact. Here
# the setter is a separate model call in an empty temporary directory with no tools, no settings
# sources, no MCP servers and its own system prompt — it can see only what the input file says.
#
# IYU_WALK_SETTER, when set, replaces the model call with a shell command that reads the prompt on
# stdin and prints the answer; the dry-run harness uses it. IYU_WALK_MODEL picks the model (default
# sonnet).
#
# Exit: 0 written · 2 the setter returned no JSON object (nothing written) · 64 usage error.

set -u

if [ "$#" -ne 3 ] || [ ! -f "$1" ] || [ ! -f "$2" ]; then
    echo "usage: set-missions.sh <brief-file> <input-file> <out-file>" >&2
    exit 64
fi
brief=$1
input=$2
out=$3

# Resolve the brief to an absolute path before moving into the empty directory — a relative path
# would not resolve there — and hand it over as a file, not an argument: a multi-line brief with
# quotes, backticks and tables survives a file on every shell, an argument does not.
brief=$(cd "$(dirname "$brief")" && pwd)/$(basename "$brief") || exit 64
work=$(mktemp -d 2>/dev/null || mktemp -d -t iyu-walk) || exit 64
raw="$work.out"
trap 'rm -rf "$work" "$raw" "$raw.err"' EXIT INT TERM

if [ -n "${IYU_WALK_SETTER:-}" ]; then
    { cat "$brief"; printf '\n\n'; cat "$input"; } |
        (cd "$work" && sh -c "$IYU_WALK_SETTER") >"$raw" 2>"$raw.err"
else
    (cd "$work" && claude -p --model "${IYU_WALK_MODEL:-sonnet}" \
        --system-prompt-file "$brief" \
        --tools '' --setting-sources '' --strict-mcp-config --no-session-persistence) \
        <"$input" >"$raw" 2>"$raw.err"
fi

# Keep the span from the first "{" to the last "}" — drops a code fence or a stray sentence around
# the object. Whether it parses as the schema is the skill's check, not this script's.
awk '
    { lines[NR] = $0 }
    END {
        first = 0; last = 0
        for (i = 1; i <= NR; i++) if (!first && index(lines[i], "{")) first = i
        for (i = NR; i >= 1; i--) if (!last && index(lines[i], "}")) last = i
        if (!first || !last || last < first) exit 2
        for (i = first; i <= last; i++) {
            s = lines[i]
            if (i == first) s = substr(s, index(s, "{"))
            if (i == last) { n = 0; for (j = length(s); j > 0; j--) if (substr(s, j, 1) == "}") { n = j; break } s = substr(s, 1, n) }
            print s
        }
    }' "$raw" >"$raw.json" || {
        rm -f "$raw.json"
        # Say why, so the caller can report it: the first lines of what came back, and of stderr.
        echo "set-missions: the setter returned no JSON object. Output began:" >&2
        head -c 600 "$raw" >&2; echo >&2
        [ -s "$raw.err" ] && { echo "stderr began:" >&2; head -c 600 "$raw.err" >&2; echo >&2; }
        exit 2
    }

mv "$raw.json" "$out"
exit 0
