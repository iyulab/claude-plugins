<#
.SYNOPSIS
  Tests the continuity-doc lint (plugins/iyu/skills/_shared/scripts/docs-lint.sh) against fixtures.

.DESCRIPTION
  The lint mechanically runs the structural checks of continuity-docs.md section 7, by code. It is
  deterministic, so every fixture runs once and its verdicts are checked exactly.

  For each fixture the script:
    1. copies `fixtures/<name>/tree` to a fresh temp directory and, when expect.json sets `crlf`,
       rewrites every Markdown file there with CRLF line ends and a UTF-8 BOM;
    2. runs the lint on that directory (or on `root` from expect.json, relative to it) under the same
       sh that Claude Code uses (Git Bash on Windows), with DOCS_LINT_TODAY set to the fixture's
       `today` (default 2026-10-18);
    3. asserts the exit code, the lines the report must and must not contain, and that no file in
       the tree changed: the lint only reads.

.EXAMPLE
  pwsh scripts/docs-lint-dryrun/Invoke-DocsLintDryRun.ps1
  pwsh scripts/docs-lint-dryrun/Invoke-DocsLintDryRun.ps1 -Fixture l10-*
#>
[CmdletBinding()]
param(
    [string]$Fixture = '*',
    [string]$Lint = (Join-Path $PSScriptRoot '../../plugins/iyu/skills/_shared/scripts/docs-lint.sh')
)

$ErrorActionPreference = 'Stop'

function Get-Sh {
    if (-not $IsWindows) { return (Get-Command sh).Source }
    # Claude Code runs shell commands under Git Bash. `bash` on PATH is often WSL's, which is not it.
    $candidates = @($env:CLAUDE_CODE_GIT_BASH_PATH)
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) { $candidates += Join-Path (Split-Path (Split-Path $git.Source)) 'bin/bash.exe' }
    $candidates += Join-Path $env:ProgramFiles 'Git/bin/bash.exe'
    $found = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_) } | Select-Object -First 1
    if (-not $found) { throw 'Git Bash not found; set CLAUDE_CODE_GIT_BASH_PATH.' }
    return $found
}

function Get-TreeHashes([string]$root) {
    $h = @{}
    Get-ChildItem -LiteralPath $root -Recurse -File | ForEach-Object {
        $h[$_.FullName.Substring($root.Length)] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $h
}

function Invoke-LintRun($fx, $expect, [string]$sh, [string]$lint) {
    $root = Join-Path ([IO.Path]::GetTempPath()) ('docs-lint-dryrun-' + [guid]::NewGuid().ToString('N').Substring(0, 8))
    Copy-Item -LiteralPath (Join-Path $fx.FullName 'tree') -Destination $root -Recurse
    if ($expect.crlf) {
        $bom = [Text.UTF8Encoding]::new($true)
        Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.md' | ForEach-Object {
            $text = [IO.File]::ReadAllText($_.FullName) -replace "`r?`n", "`r`n"
            [IO.File]::WriteAllText($_.FullName, $text, $bom)
        }
    }
    $before = Get-TreeHashes $root

    $target = if ($expect.root) { Join-Path $root $expect.root } else { $root }
    $saved = $env:DOCS_LINT_TODAY
    try {
        $env:DOCS_LINT_TODAY = if ($expect.today) { $expect.today } else { '2026-10-18' }
        $out = (& $sh $lint ($target -replace '\\', '/') 2>&1 | Out-String).Trim() -replace "`r", ''
        $exit = $LASTEXITCODE
    } finally { $env:DOCS_LINT_TODAY = $saved }

    $problems = @()
    if ($exit -ne [int]$expect.exit) { $problems += "exit $exit, expected $($expect.exit)" }
    if ($out -notmatch '(?m)^Result: ') { $problems += 'no Result line' }
    # Every code's verdict is asserted, so a fixture is also clean on the codes it is not about.
    foreach ($code in 'L04', 'L05', 'L07', 'L10', 'L01', 'L06', 'L08') {
        $want = if ($expect.verdicts.$code) { $expect.verdicts.$code } elseif ($code -eq 'L06') { 'UNCHECKED' } else { 'PASS' }
        if ($out -notmatch "(?m)^$code $want ") { $problems += "$code is not $want" }
    }
    foreach ($s in @($expect.contains)) { if ($s -and -not $out.Contains($s)) { $problems += "report lacks '$s'" } }
    foreach ($s in @($expect.notContains)) { if ($s -and $out.Contains($s)) { $problems += "report contains '$s'" } }
    $after = Get-TreeHashes $root
    $changed = @($before.Keys | Where-Object { $after[$_] -ne $before[$_] }) + @($after.Keys | Where-Object { -not $before.ContainsKey($_) })
    if ($changed) { $problems += "lint modified files: $($changed -join ', ')" }

    if (-not $problems) { Remove-Item -LiteralPath $root -Recurse -Force }
    [pscustomobject]@{ Problems = $problems; Output = $out; Root = $root }
}

$sh = Get-Sh
$lintPath = (Resolve-Path $Lint).Path -replace '\\', '/'
$fixtures = Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'fixtures') -Directory | Where-Object Name -like $Fixture
if (-not $fixtures) { throw "No fixture matches '$Fixture'." }

$failed = 0
foreach ($fx in $fixtures) {
    $expect = Get-Content -LiteralPath (Join-Path $fx.FullName 'expect.json') -Raw -Encoding utf8 | ConvertFrom-Json
    $run = Invoke-LintRun $fx $expect $sh $lintPath
    $status = if ($run.Problems) { 'FAIL'; $failed++ } else { 'PASS' }
    Write-Host ('[{0}] {1} — {2}' -f $status, $fx.Name, $expect.why)
    if ($run.Problems) {
        Write-Host ('    {0}' -f ($run.Problems -join '; '))
        Write-Host ($run.Output -split "`n" | ForEach-Object { "      | $_" } | Out-String)
        Write-Host ('      tree kept at: {0}' -f $run.Root)
    }
}
if ($failed) { Write-Host "$failed fixture(s) failed."; exit 1 }
Write-Host "All $($fixtures.Count) fixtures passed."
