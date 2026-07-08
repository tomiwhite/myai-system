# ============================================================================
# SAFE AUTOSTART - myAI System (C:\)
# ============================================================================
#
# Minimal and stable startup entrypoint for logon task.
# It only validates core prerequisites and opens the workspace.
# No auto-agent chat, no forced restarts, no extension auto-installs.
#
# Usage:
#   powershell -NoProfile -ExecutionPolicy Bypass -File
#   C:\myAI_System\scripts\startup\start-myai-system-safe.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

function Write-Info { param([string]$m) Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Warn { param([string]$m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Ok { param([string]$m) Write-Host "[OK]   $m" -ForegroundColor Green }

$codeExe = "C:\Program Files\Microsoft VS Code\Code.exe"
$repoRoot = "C:\myAI_System"
$workspaceFile = "C:\myAI_System\myai-system.code-workspace"
$reportPath = "C:\myAI_System\reports\post-restart-check.txt"

if (-not (Test-Path $repoRoot)) {
    throw "Repo root not found: $repoRoot"
}

if (-not (Test-Path "C:\myAI_System\reports")) {
    New-Item -ItemType Directory -Path "C:\myAI_System\reports" -Force | Out-Null
}

if (-not (Test-Path $codeExe)) {
    $codeCmd = Get-Command code -ErrorAction SilentlyContinue
    if ($codeCmd) {
        $codeExe = $codeCmd.Source
    }
}

if (-not (Test-Path $codeExe)) {
    throw "VS Code executable not found"
}

Start-Sleep -Seconds 25

if (Test-Path $workspaceFile) {
    Start-Process $codeExe -ArgumentList @("--reuse-window", $workspaceFile) | Out-Null
    $workspaceUsed = $workspaceFile
} else {
    Start-Process $codeExe -ArgumentList @("--reuse-window", $repoRoot) | Out-Null
    $workspaceUsed = $repoRoot
}

$lines = @(
    "Timestamp: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    "Mode: SAFE_AUTOSTART",
    "WorkspaceUsed: $workspaceUsed",
    "RepoRootExists: $(Test-Path $repoRoot)",
    "CodeExe: $codeExe",
    "TaskPolicy: no-auto-chat no-forced-restart"
)

Set-Content -Path $reportPath -Value ($lines -join "`r`n") -Encoding UTF8

Write-Ok "Safe autostart completed"
Write-Info "Workspace: $workspaceUsed"
Write-Info "Report: $reportPath"
