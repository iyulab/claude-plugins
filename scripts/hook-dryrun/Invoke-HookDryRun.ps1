<#
.SYNOPSIS
  Dry-runs the run-cycle Stop hook (a `type: agent` hook) against on-disk fixtures.

.DESCRIPTION
  The Stop hook is the plugin's only enforcement surface and it is an LLM reading a prompt, so a
  one-sentence prompt edit can change what it blocks. This script is its regression check.

  For each fixture it:
    1. copies `fixtures/<name>/tree` to a fresh temp directory, renaming every `_cycle-logs_`
       directory to `cycle-logs` (fixtures store them renamed so that neither this repository's own
       Stop hook nor continuity-root resolution mistakes a fixture for a real log directory);
    2. extracts the hook prompt from `plugins/iyu/skills/run-cycle/SKILL.md` frontmatter and
       substitutes `$ARGUMENTS` with a Stop hook input whose `cwd` is that temp directory;
    3. runs it through `claude -p` with read AND write tools available — the hook's real tool set is
       undocumented beyond "tools like Read, Grep, and Glob", so the dry run must be able to observe
       a hook that writes;
    4. asserts the `ok` verdict, reason substrings, and that no file in the tree changed.

  NON-DETERMINISM: the hook is a model run, so one pass proves little. A fixture passes only when
  all -Repeat runs (default 3) satisfy every assertion. Treat a flaky fixture as a failing one: a
  verdict that holds two times in three is a prompt that a real run can still trip over.

  The model defaults to haiku because agent hooks without a `model` field run on "a fast model".

  Runs (fixture x repeat) execute concurrently, -ThrottleLimit at a time (default 6); each has its own
  temp tree, so they share nothing. -ThrottleLimit 1 runs them one after another.

.EXAMPLE
  pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1
  pwsh scripts/hook-dryrun/Invoke-HookDryRun.ps1 -Fixture e-* -Repeat 5
#>
[CmdletBinding()]
param(
    [string]$Fixture = '*',
    [int]$Repeat = 3,
    [string]$Model = 'haiku',
    [int]$ThrottleLimit = 6,
    [string]$SkillPath = (Join-Path $PSScriptRoot '../../plugins/iyu/skills/run-cycle/SKILL.md')
)

$ErrorActionPreference = 'Stop'

function Get-HookPrompt([string]$path) {
    $lines = Get-Content -LiteralPath $path -Encoding utf8
    if ($lines[0] -ne '---') { throw "No frontmatter in $path" }
    $end = [Array]::IndexOf($lines, '---', 1)
    $fm = $lines[1..($end - 1)]
    $start = -1
    for ($i = 0; $i -lt $fm.Count; $i++) {
        if ($fm[$i] -match '^(\s*)prompt:\s*\|\s*$') { $start = $i; $indent = $Matches[1].Length; break }
    }
    if ($start -lt 0) { throw "No 'prompt: |' block in the frontmatter of $path" }
    $body = New-Object System.Collections.Generic.List[string]
    for ($i = $start + 1; $i -lt $fm.Count; $i++) {
        $l = $fm[$i]
        if ($l.Trim() -eq '') { $body.Add(''); continue }
        $lead = $l.Length - $l.TrimStart().Length
        if ($lead -le $indent) { break }
        $body.Add($l)
    }
    $strip = ($body | Where-Object { $_ -ne '' } | ForEach-Object { $_.Length - $_.TrimStart().Length } | Measure-Object -Minimum).Minimum
    $text = ($body | ForEach-Object { if ($_.Length -ge $strip) { $_.Substring($strip) } else { $_ } }) -join "`n"
    if ($text -notmatch 'Output contract') { throw 'Extracted hook prompt looks truncated (no "Output contract").' }
    return $text
}

function New-FixtureTree([string]$src, [string]$dst) {
    Copy-Item -LiteralPath $src -Destination $dst -Recurse
    Get-ChildItem -LiteralPath $dst -Recurse -Directory -Filter '_cycle-logs_' |
        Sort-Object { $_.FullName.Length } -Descending |
        ForEach-Object { Rename-Item -LiteralPath $_.FullName -NewName 'cycle-logs' }
}

function Get-TreeHashes([string]$root) {
    $h = @{}
    Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
        $h[$_.FullName.Substring($root.Length)] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $h
}

function Get-Verdict([string]$raw) {
    # stream-json: one event per line; the last `result` event carries the final text.
    $res = $raw -split "`r?`n" | Where-Object { $_ -match '^\{.*"type"\s*:\s*"result"' } | Select-Object -Last 1
    if (-not $res) { return $null }
    $text = [string]($res | ConvertFrom-Json).result
    $m = [regex]::Matches($text, '\{[^{}]*"ok"\s*:\s*(true|false)[^{}]*\}')
    if ($m.Count -eq 0) { return $null }
    try { return ($m[$m.Count - 1].Value | ConvertFrom-Json) } catch { return $null }
}

function Invoke-HookRun($fxPath, $expect, [string]$prompt, [string]$model) {
    $root = Join-Path ([IO.Path]::GetTempPath()) ("hook-dryrun-" + [guid]::NewGuid().ToString('N').Substring(0, 8))
    New-FixtureTree (Join-Path $fxPath 'tree') $root
    if ($expect.touch) {
        foreach ($p in $expect.touch.PSObject.Properties) {
            $rel = $p.Name -replace '_cycle-logs_', 'cycle-logs'
            (Get-Item -LiteralPath (Join-Path $root $rel)).LastWriteTime = (Get-Date).AddMinutes([int]$p.Value)
        }
    }
    $before = Get-TreeHashes $root
    $transcript = ''
    if ($expect.transcript) {
        # Beside the tree, not in it, so the hash check covers only the tree.
        $metaDir = "$root.meta"
        New-Item -ItemType Directory -Path $metaDir | Out-Null
        $transcript = Join-Path $metaDir 'transcript.jsonl'
        $lines = foreach ($entry in @($expect.transcript)) { $entry | ConvertTo-Json -Compress -Depth 10 }
        Set-Content -LiteralPath $transcript -Value $lines -Encoding utf8
    }
    $hookInput = [ordered]@{
        session_id = 'dryrun'; transcript_path = $transcript; cwd = $root; hook_event_name = 'Stop'
        stop_hook_active = $false; last_assistant_message = 'Cycle work for this turn is done.'
    } | ConvertTo-Json -Compress
    $p = $prompt.Replace('$ARGUMENTS', $hookInput)

    # A real session's transcript lives outside the project too; grant read access the way a user's
    # session would need to, so the dry run tests the prompt rather than the sandbox.
    $extra = if ($transcript) { @('--add-dir', (Split-Path $transcript)) } else { @() }
    Push-Location $root
    try {
        $raw = $p | claude -p --model $model --setting-sources '' --tools 'Read,Glob,Grep,Write,Edit' @extra `
            --permission-mode acceptEdits --no-session-persistence --output-format stream-json --verbose 2>&1 | Out-String
    } finally { Pop-Location }

    $v = Get-Verdict $raw
    $problems = @()
    if ($null -eq $v) { $problems += 'no JSON verdict in output' }
    else {
        if ([bool]$v.ok -ne [bool]$expect.ok) { $problems += "ok=$($v.ok), expected $($expect.ok)" }
        $reason = ([string]$v.reason) -replace '\\', '/'
        $rootFwd = $root -replace '\\', '/'
        foreach ($s in @($expect.reasonContains)) { if ($s -and $reason -notlike "*$s*") { $problems += "reason lacks '$s'" } }
        foreach ($s in @($expect.reasonNotContains)) { if ($s -and $reason -like "*$s*") { $problems += "reason contains '$s'" } }
        if ($expect.reasonContainsFixtureRoot -and $reason -notlike "*$rootFwd*" -and $reason -notlike "*$($rootFwd.TrimEnd('/') -replace '^([A-Za-z]):', '/$1')*") {
            $problems += 'reason does not carry the resolved absolute path'
        }
    }
    $after = Get-TreeHashes $root
    $changed = @($before.Keys | Where-Object { $after[$_] -ne $before[$_] }) + @($after.Keys | Where-Object { -not $before.ContainsKey($_) })
    if ($changed) { $problems += "hook modified files: $($changed -join ', ')" }

    $trace = "$root.trace.jsonl"
    if ($problems) { Set-Content -LiteralPath $trace -Value $raw -Encoding utf8 }  # beside the tree, not in it
    else {
        Remove-Item -LiteralPath $root -Recurse -Force
        if ($transcript) { Remove-Item -LiteralPath (Split-Path $transcript) -Recurse -Force }
    }
    [pscustomobject]@{ Problems = $problems; Reason = $v.reason; Root = $root; Trace = $trace }
}

$prompt = Get-HookPrompt (Resolve-Path $SkillPath)
$fixtures = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'fixtures') -Directory | Where-Object Name -like $Fixture
if (-not $fixtures) { throw "No fixture matches '$Fixture'." }

$jobs = foreach ($fx in $fixtures) {
    $expect = Get-Content -LiteralPath (Join-Path $fx.FullName 'expect.json') -Raw -Encoding utf8 | ConvertFrom-Json
    for ($r = 1; $r -le $Repeat; $r++) { [pscustomobject]@{ Name = $fx.Name; Path = $fx.FullName; Expect = $expect; Run = $r } }
}
# Parallel runspaces do not inherit this script's functions; hand them over as source.
$lib = @('New-FixtureTree', 'Get-TreeHashes', 'Get-Verdict', 'Invoke-HookRun' |
    ForEach-Object { "function $_ {`n$((Get-Item "function:$_").Definition)`n}" }) -join "`n"
$results = $jobs | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
    $ErrorActionPreference = 'Stop'
    . ([scriptblock]::Create($using:lib))
    $res = Invoke-HookRun $_.Path $_.Expect $using:prompt $using:Model
    $res | Add-Member -NotePropertyName Name -NotePropertyValue $_.Name -PassThru |
        Add-Member -NotePropertyName Run -NotePropertyValue $_.Run -PassThru
}

$failed = 0
foreach ($fx in $fixtures) {
    $expect = ($jobs | Where-Object Name -eq $fx.Name | Select-Object -First 1).Expect
    $bad = @($results | Where-Object { $_.Name -eq $fx.Name -and $_.Problems } | Sort-Object Run)
    $status = if ($bad) { 'FAIL'; $failed++ } else { 'PASS' }
    Write-Host ("[{0}] {1}  ({2}/{3} runs clean) — {4}" -f $status, $fx.Name, ($Repeat - $bad.Count), $Repeat, $expect.why)
    foreach ($b in $bad) {
        Write-Host ("    run {0}: {1}" -f $b.Run, ($b.Problems -join '; '))
        Write-Host ("      reason: {0}" -f $b.Reason)
        Write-Host ("      tree kept at: {0}" -f $b.Root)
        Write-Host ("      tool trace:   {0}" -f $b.Trace)
    }
}
if ($failed) { Write-Host "$failed fixture(s) failed."; exit 1 }
Write-Host 'All fixtures passed.'
