<#
.SYNOPSIS
  Tests the blind mission setter (plugins/iyu/skills/walk/scripts/set-missions.sh).

.DESCRIPTION
  The setter's value is that it cannot see the product: it runs in an empty temporary directory
  with no tools, no settings sources and no MCP servers. The deterministic cases replace the model
  with a stub (IYU_WALK_SETTER) and assert what the stub was given and where it ran, how the answer
  is extracted, and the exit codes. -Live also runs the real model call with a probe brief and
  asserts it reports no tools and no context beyond the brief and the input, on every repeat.

.EXAMPLE
  pwsh scripts/walk-setter-dryrun/Invoke-WalkSetterDryRun.ps1
  pwsh scripts/walk-setter-dryrun/Invoke-WalkSetterDryRun.ps1 -Live -Repeat 2
#>
[CmdletBinding()]
param(
    [switch]$Live,
    [int]$Repeat = 2,
    [string]$Setter = (Join-Path $PSScriptRoot '../../plugins/iyu/skills/walk/scripts/set-missions.sh')
)

$ErrorActionPreference = 'Stop'
$Setter = (Resolve-Path $Setter).Path

function Get-Sh {
    if (-not $IsWindows) { return (Get-Command sh).Source }
    $candidates = @($env:CLAUDE_CODE_GIT_BASH_PATH)
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) { $candidates += Join-Path (Split-Path (Split-Path $git.Source)) 'bin/bash.exe' }
    $candidates += Join-Path $env:ProgramFiles 'Git/bin/bash.exe'
    $found = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
    if (-not $found) { throw 'Git Bash not found; set CLAUDE_CODE_GIT_BASH_PATH.' }
    return $found
}
$sh = Get-Sh

$tmp = Join-Path ([IO.Path]::GetTempPath()) ('walk-setter-dryrun-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
New-Item -ItemType Directory -Path $tmp | Out-Null
$brief = Join-Path $tmp 'brief.md';  Set-Content -LiteralPath $brief -Value 'BRIEF-MARKER you write missions.' -NoNewline
$input_ = Join-Path $tmp 'purpose.md'; Set-Content -LiteralPath $input_ -Value 'PURPOSE-MARKER A notes app for small teams.' -NoNewline

$failures = 0
function Check([string]$name, [bool]$ok, [string]$detail = '') {
    if ($ok) { Write-Host "PASS  $name" } else { Write-Host "FAIL  $name  $detail"; $script:failures++ }
}

function Invoke-Setter([string]$stub, [string]$out, [string[]]$argv = $null) {
    $env:IYU_WALK_SETTER = $stub
    $env:STUB_LOG = Join-Path $tmp 'stub.log'
    $env:STUB_IN = Join-Path $tmp 'stub.in'
    Remove-Item -LiteralPath $env:STUB_LOG, $env:STUB_IN -ErrorAction SilentlyContinue
    if ($null -eq $argv) { $argv = @($brief, $input_, $out) }
    & $sh $Setter @argv | Out-Null
    $code = $LASTEXITCODE
    Remove-Item Env:IYU_WALK_SETTER
    return $code
}

# 1. Fenced JSON: unfenced and written; the stub got brief + input on stdin, in an empty dir outside the repo.
$out = Join-Path $tmp 'o1.json'
$stub = 'pwd > "$STUB_LOG"; ls -A | wc -l | tr -d " " >> "$STUB_LOG"; cat > "$STUB_IN"; printf ''```json\n{"personas": [],\n "missions": []}\n```\n'''
$code = Invoke-Setter $stub $out
Check 'fenced-json: exit 0' ($code -eq 0) "exit $code"
Check 'fenced-json: object only' ((Test-Path $out) -and ((Get-Content -Raw $out).Trim() -eq "{`"personas`": [],`n `"missions`": []}")) ((Get-Content -Raw $out -ErrorAction SilentlyContinue))
$log = Get-Content $env:STUB_LOG
$ran = $log[0]
Check 'isolation: ran outside the repository' (-not $ran.StartsWith((Resolve-Path (Join-Path $PSScriptRoot '../..')).Path)) $ran
Check 'isolation: ran in an empty directory' ($log[1] -eq '0') "entries: $($log[1])"
Check 'isolation: temp directory removed afterwards' (-not (Test-Path -LiteralPath $ran)) $ran
$in = Get-Content -Raw $env:STUB_IN
Check 'input: brief and purpose both passed' ($in.Contains('BRIEF-MARKER') -and $in.Contains('PURPOSE-MARKER')) $in

# 2. Prose around the object: the object is kept.
$out = Join-Path $tmp 'o2.json'
$code = Invoke-Setter 'cat > /dev/null; printf ''Here you go: {"missions": [{"goal": "x"}]} hope it helps\n''' $out
Check 'prose-around: exit 0' ($code -eq 0) "exit $code"
Check 'prose-around: object only' ((Test-Path $out) -and ((Get-Content -Raw $out).Trim() -eq '{"missions": [{"goal": "x"}]}')) ((Get-Content -Raw $out -ErrorAction SilentlyContinue))

# 3. No JSON at all: exit 2, nothing written.
$out = Join-Path $tmp 'o3.json'
$env:IYU_WALK_SETTER = 'cat > /dev/null; echo "I cannot help with that."'
$err = & $sh $Setter $brief $input_ $out 2>&1 | Out-String
$code = $LASTEXITCODE
Remove-Item Env:IYU_WALK_SETTER
Check 'no-json: exit 2' ($code -eq 2) "exit $code"
Check 'no-json: nothing written' (-not (Test-Path $out))
Check 'no-json: says why, quoting the output' ($err.Contains('no JSON object') -and $err.Contains('I cannot help')) $err

# 4. Setter fails with no output: exit 2, nothing written.
$out = Join-Path $tmp 'o4.json'
$code = Invoke-Setter 'cat > /dev/null; exit 1' $out
Check 'setter-fails: exit 2' ($code -eq 2) "exit $code"
Check 'setter-fails: nothing written' (-not (Test-Path $out))

# 5. Usage error.
$code = Invoke-Setter 'cat' (Join-Path $tmp 'o5.json') @($brief)
Check 'usage: exit 64' ($code -eq 64) "exit $code"

# Live: the real call sees no tools and nothing but the brief and the input.
if ($Live) {
    $probe = Join-Path $tmp 'probe.md'
    Set-Content -LiteralPath $probe -NoNewline -Value @'
You are a probe. Reply with exactly one JSON object and nothing else:
{"tools": [names of every tool you can call], "other_context": [every distinct instruction or document in your context other than this system prompt and the user message, each as a short quote]}
Use empty lists when there are none.
'@
    # The caller stands in a "project" whose instructions carry a canary. The harness's own
    # environment notes (working directory, date, model) are expected; project instructions are not.
    $proj = Join-Path $tmp 'project'
    New-Item -ItemType Directory -Path (Join-Path $proj '.claude') | Out-Null
    Set-Content -LiteralPath (Join-Path $proj 'CLAUDE.md') -Value "# Project rules`nCANARY-7731: the notes app stores data in Postgres."
    Set-Content -LiteralPath (Join-Path $proj '.claude/settings.json') -Value '{"env": {"CANARY_SETTING": "CANARY-4410"}}'
    $leak = 'CANARY-7731|CANARY-4410|CLAUDE\.md|Postgres|project rules|auto-?memory|skills?\b|plugin|MCP|hook'
    Push-Location $proj
    try {
        for ($i = 1; $i -le $Repeat; $i++) {
            $out = Join-Path $tmp "live$i.json"
            Remove-Item Env:IYU_WALK_SETTER -ErrorAction SilentlyContinue
            # Relative paths on purpose: the script must read them before it leaves the caller's directory.
            & $sh $Setter '../probe.md' '../purpose.md' $out | Out-Null
            $code = $LASTEXITCODE
            $obj = $null
            if ($code -eq 0) { try { $obj = Get-Content -Raw $out | ConvertFrom-Json } catch { } }
            Check "live[$i]: answered" ($null -ne $obj) "exit $code"
            if ($obj) {
                Check "live[$i]: no tools" (@($obj.tools).Count -eq 0) ($obj.tools -join ', ')
                $hits = @($obj.other_context | Where-Object { $_ -match $leak })
                Check "live[$i]: no project instructions, settings or extensions" ($hits.Count -eq 0) ($hits -join ' | ')
            }
        }
    } finally { Pop-Location }
}

Remove-Item -LiteralPath $tmp -Recurse -Force
if ($failures) { Write-Host "$failures check(s) failed"; exit 1 }
Write-Host 'all checks passed'
