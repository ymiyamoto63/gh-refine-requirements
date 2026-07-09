# Installs the refine-requirements skill.
#   .\tools\install.ps1                              -> Claude Code (~/.claude/skills/)
#   .\tools\install.ps1 -CopilotTarget <repo-root>   -> also copy into <repo-root>\.github\skills\
param(
    [string]$CopilotTarget
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$skillSrc = Join-Path $repoRoot 'skills\refine-requirements'

$claudeDest = Join-Path $HOME '.claude\skills\refine-requirements'
New-Item -ItemType Directory -Force $claudeDest | Out-Null
Copy-Item (Join-Path $skillSrc '*') $claudeDest -Recurse -Force
Write-Host "Installed for Claude Code: $claudeDest (restart Claude Code to pick it up)"

if ($CopilotTarget) {
    if (-not (Test-Path $CopilotTarget)) {
        throw "Copilot target not found: $CopilotTarget"
    }
    $copilotDest = Join-Path $CopilotTarget '.github\skills\refine-requirements'
    New-Item -ItemType Directory -Force $copilotDest | Out-Null
    Copy-Item (Join-Path $skillSrc '*') $copilotDest -Recurse -Force
    Write-Host "Installed for GitHub Copilot: $copilotDest"
}
