<#
.SYNOPSIS
  Tests the run-cycle Stop hook (plugins/iyu/skills/run-cycle/scripts/stop-gate.sh) against fixtures.

.DESCRIPTION
  The Stop hook is the plugin's only enforcement surface. It is a `type: command` script, so every
  verdict it reaches by itself is deterministic and checked here exactly, run once per fixture.

  For each fixture the script:
    1. copies `fixtures/<name>/tree` to a fresh temp directory, renaming every `_cycle-logs_`
       directory to `cycle-logs` (fixtures store them renamed so that neither this repository's own
       Stop hook nor continuity-root resolution mistakes a fixture for a real log directory), then
       applies `fill` and `touch` from expect.json;
    2. writes the fixture's `transcript` beside the tree and pipes a Stop hook input whose `cwd` is
       the temp tree into the script, under the same sh that Claude Code uses (Git Bash on Windows);
    3. asserts the verdict, reason or message substrings, whether the auditor was called, and that
       no file in the tree changed.

  The one model call the hook can make, auditing a FRONTIER-EXHAUSTED claim, is replaced by a stub
  that returns the fixture's `auditor` verdict (IYU_RUN_CYCLE_AUDITOR). -LiveAudit instead runs the
  real auditor (`claude -p`) on the fixtures that define `auditor`, -Repeat times each, and passes a
  fixture only when every repeat does: a verdict that holds two runs in three is one a real run can
  still trip over.

.EXAMPLE
  pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1
  pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1 -Fixture k-*
  pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1 -LiveAudit -Repeat 3
#>
[CmdletBinding()]
param(
    [string]$Fixture = '*',
    [switch]$LiveAudit,
    [int]$Repeat = 3,
    [string]$Gate = (Join-Path $PSScriptRoot '../../plugins/iyu/skills/run-cycle/scripts/stop-gate.sh')
)

$ErrorActionPreference = 'Stop'

function Get-Sh {
    if (-not $IsWindows) { return (Get-Command sh).Source }
    # Claude Code runs shell-form hooks under Git Bash. `bash` on PATH is often WSL's, which is not it.
    $candidates = @($env:CLAUDE_CODE_GIT_BASH_PATH)
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) { $candidates += Join-Path (Split-Path (Split-Path $git.Source)) 'bin/bash.exe' }
    $candidates += Join-Path $env:ProgramFiles 'Git/bin/bash.exe'
    $found = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
    if (-not $found) { throw 'Git Bash not found; set CLAUDE_CODE_GIT_BASH_PATH.' }
    return $found
}

function New-FixtureTree([string]$src, [string]$dst, $expect) {
    Copy-Item -LiteralPath $src -Destination $dst -Recurse
    Get-ChildItem -LiteralPath $dst -Recurse -Directory -Filter '_cycle-logs_' |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object { Rename-Item -LiteralPath $_.FullName -NewName 'cycle-logs' }
    if ($expect.fill) {
        # Bulk logs from finished runs, so a fixture can hold more logs than a file-listing tool returns.
        $logs = Join-Path $dst ($expect.fill.dir -replace '_cycle-logs_', 'cycle-logs')
        foreach ($i in [int]$expect.fill.from..[int]$expect.fill.to) {
            $runStart = $i - (($i - [int]$expect.fill.from) % 10)
            Set-Content -LiteralPath (Join-Path $logs ('cycle-{0:D2}.md' -f $i)) -Encoding utf8 -Value @(
                "# Cycle ${i}: earlier work", 'Date: 2026-09-20', 'Root: `claudedocs/`', 'Budget: 10',
                "Start: $runStart", 'Status: complete', '', '## Carry-Forward',
                '- Emergent Next Capability: `FRONTIER-OPEN:` next slice [autonomous]')
        }
    }
    if ($expect.touch) {
        foreach ($p in $expect.touch.PSObject.Properties) {
            $rel = $p.Name -replace '_cycle-logs_', 'cycle-logs'
            (Get-Item -LiteralPath (Join-Path $dst $rel)).LastWriteTime = (Get-Date).AddMinutes([int]$p.Value)
        }
    }
}

function Get-TreeHashes([string]$root) {
    $h = @{}
    Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
        $h[$_.FullName.Substring($root.Length)] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $h
}

function Invoke-GateRun($fx, $expect, [string]$sh, [string]$gate, [bool]$live) {
    $root = Join-Path ([IO.Path]::GetTempPath()) ('hook-dryrun-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-FixtureTree (Join-Path $fx.FullName 'tree') $root $expect
    $before = Get-TreeHashes $root

    # Transcript and auditor stub live beside the tree, not in it, so the hash check covers only the tree.
    $meta = "$root.meta"
    New-Item -ItemType Directory -Path $meta | Out-Null
    $transcript = ''
    if ($expect.transcript) {
        $transcript = Join-Path $meta 'transcript.jsonl'
        $lines = foreach ($entry in @($expect.transcript)) { $entry | ConvertTo-Json -Compress -Depth 10 }
        Set-Content -LiteralPath $transcript -Value $lines -Encoding utf8
    }
    $calls = Join-Path $meta 'auditor-called'
    $callsSh = $calls -replace '\\', '/'
    $verdict = switch -Regex ([string]$expect.auditor) {
        '^pass$' { '{"ok": true, "reason": "claim holds"}' }
        '^fail: (.*)$' { (@{ ok = $false; reason = $Matches[1] } | ConvertTo-Json -Compress) }
        default { 'no verdict here' }
    }
    $stub = Join-Path $meta 'auditor.sh'
    Set-Content -LiteralPath $stub -Encoding utf8 -Value @('cat > /dev/null', "echo called >> '$callsSh'", "printf '%s\n' '$verdict'")

    $hookInput = [ordered]@{
        session_id = 'dryrun'; transcript_path = $transcript; cwd = $root; hook_event_name = 'Stop'
        stop_hook_active = $false; last_assistant_message = 'Done for this turn.'
    } | ConvertTo-Json -Compress
    $saved = $env:IYU_RUN_CYCLE_AUDITOR
    try {
        $env:IYU_RUN_CYCLE_AUDITOR = if ($live) { $null } else { "sh '$($stub -replace '\\', '/')'" }
        $out = ($hookInput | & $sh $gate 2>&1 | Out-String).Trim()
        $exit = $LASTEXITCODE
    } finally { $env:IYU_RUN_CYCLE_AUDITOR = $saved }

    $problems = @()
    $ok = $true; $reason = ''; $message = ''
    if ($exit -ne 0) { $problems += "exit code $exit" }
    if ($out) {
        try { $o = $out | ConvertFrom-Json } catch { $problems += "output is not JSON: $out"; $o = $null }
        if ($o -and $o.decision -eq 'block') { $ok = $false; $reason = [string]$o.reason }
        elseif ($o) { $message = [string]$o.systemMessage }
    }
    if ($ok -ne [bool]$expect.ok) { $problems += "ok=$ok, expected $($expect.ok)" }
    $reasonFwd = $reason -replace '\\', '/'
    foreach ($s in @($expect.reasonContains)) { if ($s -and $reasonFwd -notlike "*$s*") { $problems += "reason lacks '$s'" } }
    foreach ($s in @($expect.reasonNotContains)) { if ($s -and $reasonFwd -like "*$s*") { $problems += "reason contains '$s'" } }
    foreach ($s in @($expect.messageContains)) { if ($s -and $message -notlike "*$s*") { $problems += "message lacks '$s'" } }
    if ($expect.reasonContainsFixtureRoot -and $reasonFwd -notlike "*$($root -replace '\\', '/')*") {
        $problems += 'reason does not carry the resolved absolute path'
    }
    if (-not $live) {
        $audited = Test-Path -LiteralPath $calls
        $wantAudit = $null -ne $expect.auditor -and $(if ($null -ne $expect.audited) { [bool]$expect.audited } else { $true })
        if ($audited -ne $wantAudit) { $problems += "auditor called=$audited, expected $wantAudit" }
    }
    $after = Get-TreeHashes $root
    $changed = @($before.Keys | Where-Object { $after[$_] -ne $before[$_] }) + @($after.Keys | Where-Object { -not $before.ContainsKey($_) })
    if ($changed) { $problems += "hook modified files: $($changed -join ', ')" }

    if (-not $problems) { Remove-Item -LiteralPath $root, $meta -Recurse -Force }
    [pscustomobject]@{ Problems = $problems; Reason = if ($reason) { $reason } else { $message }; Root = $root }
}

$sh = Get-Sh
$gatePath = (Resolve-Path $Gate).Path -replace '\\', '/'
$fixtures = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'fixtures') -Directory | Where-Object Name -like $Fixture
if (-not $fixtures) { throw "No fixture matches '$Fixture'." }

$failed = 0; $ran = 0
foreach ($fx in $fixtures) {
    $expect = Get-Content -LiteralPath (Join-Path $fx.FullName 'expect.json') -Raw -Encoding utf8 | ConvertFrom-Json
    if ($LiveAudit) {
        # Only fixtures whose verdict a real auditor can reach: a pass or a fail it actually gets asked.
        if ($expect.auditor -notmatch '^(pass|fail: )' -or $expect.audited -eq $false) { continue }
        $expect = $expect.PSObject.Copy()
        if ($expect.liveReasonContains) { $expect.reasonContains = $expect.liveReasonContains }
        else { $expect.PSObject.Properties.Remove('reasonContains') }
        $runs = 1..$Repeat | ForEach-Object { Invoke-GateRun $fx $expect $sh $gatePath $true }
    } else {
        $runs = @(Invoke-GateRun $fx $expect $sh $gatePath $false)
    }
    $ran++
    $bad = @($runs | Where-Object Problems)
    $status = if ($bad) { 'FAIL'; $failed++ } else { 'PASS' }
    Write-Host ('[{0}] {1}  ({2}/{3}) — {4}' -f $status, $fx.Name, ($runs.Count - $bad.Count), $runs.Count, $expect.why)
    foreach ($b in $bad) {
        Write-Host ('    {0}' -f ($b.Problems -join '; '))
        Write-Host ('      reason: {0}' -f $b.Reason)
        Write-Host ('      tree kept at: {0}' -f $b.Root)
    }
}
if (-not $ran) { throw 'No fixture ran.' }
if ($failed) { Write-Host "$failed fixture(s) failed."; exit 1 }
Write-Host 'All fixtures passed.'
