# ============================================================================
# RUN SYSTEM BASELINE CHECK
# ============================================================================
#
# Safe automation runner for repeated operational checks in C:\myAI_System.
# It executes read-only or preview-mode scripts and stores a JSON summary report.
#
# Usage:
#   .\scripts\startup\run-system-baseline-check.ps1
#   .\scripts\startup\run-system-baseline-check.ps1 -IncludeDeepAudit
# ============================================================================

param(
    [switch]$IncludeDeepAudit
)

$ErrorActionPreference = "Stop"

function Write-Header {
    Write-Host "`n" -NoNewline
    Write-Host ("=" * 80) -ForegroundColor Cyan
    Write-Host " $args" -ForegroundColor Yellow
    Write-Host ("=" * 80) -ForegroundColor Cyan
}

function Write-Step { Write-Host "`n[STEP] $args" -ForegroundColor Magenta }
function Write-Ok { Write-Host "  [OK] $args" -ForegroundColor Green }
function Write-Warn { Write-Host "  [WARN] $args" -ForegroundColor Yellow }
function Write-Info { Write-Host "  [INFO] $args" -ForegroundColor Cyan }

function Invoke-ScriptCheck {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string[]]$Arguments = @()
    )

    $startedAt = Get-Date

    if (-not (Test-Path $ScriptPath)) {
        return [PSCustomObject]@{
            Name = $Name
            ScriptPath = $ScriptPath
            Args = ($Arguments -join " ")
            StartedAt = $startedAt.ToString("yyyy-MM-dd HH:mm:ss")
            DurationSec = 0
            ExitCode = 127
            Status = "Missing"
            OutputPreview = "Script not found"
        }
    }

    try {
        $argList = @("-NoProfile", "-File", $ScriptPath) + $Arguments
        $proc = Start-Process -FilePath "pwsh" -ArgumentList $argList -NoNewWindow -Wait -PassThru -ErrorAction Stop
        $exitCode = $proc.ExitCode
        $output = "See terminal output for full details"
    } catch {
        $output = $_ | Out-String
        $exitCode = 1
    }

    $endedAt = Get-Date
    $duration = [math]::Round(($endedAt - $startedAt).TotalSeconds, 2)

    $status = if ($exitCode -eq 0) { "Passed" } else { "Failed" }

    $previewLines = @($output -split "`r?`n" | Where-Object { $_ -ne "" } | Select-Object -First 12)
    $preview = if ($previewLines.Count -gt 0) { $previewLines -join "`n" } else { "(no output)" }

    return [PSCustomObject]@{
        Name = $Name
        ScriptPath = $ScriptPath
        Args = ($Arguments -join " ")
        StartedAt = $startedAt.ToString("yyyy-MM-dd HH:mm:ss")
        DurationSec = $duration
        ExitCode = $exitCode
        Status = $status
        OutputPreview = $preview
    }
}

Write-Header "SYSTEM BASELINE CHECK"
Write-Info "Start time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info "Workspace: C:\myAI_System"

$checks = @(
    @{ Name = "Naming Validator"; Script = "C:\myAI_System\scripts\validation\validate-naming-rules.ps1"; Args = @() },
    @{ Name = "Env Sync DryRun"; Script = "C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1"; Args = @("-DryRun") },
    @{ Name = "Quick Permissions Check"; Script = "C:\myAI_System\scripts\diagnostics\quick-permissions-check.ps1"; Args = @() },
    @{ Name = "Auto Fix WhatIf"; Script = "C:\myAI_System\scripts\diagnostics\auto-fix-issues.ps1"; Args = @("-WhatIf") }
)

if ($IncludeDeepAudit) {
    $checks += @{ Name = "Deep System Audit"; Script = "C:\myAI_System\scripts\diagnostics\deep-system-audit.ps1"; Args = @() }
}

$results = @()

foreach ($check in $checks) {
    Write-Step "Running: $($check.Name)"
    $result = Invoke-ScriptCheck -Name $check.Name -ScriptPath $check.Script -Arguments $check.Args
    $results += $result

    if ($result.Status -eq "Passed") {
        Write-Ok "$($check.Name) finished in $($result.DurationSec)s"
    } elseif ($result.Status -eq "Missing") {
        Write-Warn "$($check.Name) missing script: $($check.Script)"
    } else {
        Write-Warn "$($check.Name) failed with exit code $($result.ExitCode)"
    }
}

$reportDir = "C:\myAI_System\reports\performance"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$runStamp = Get-Date -Format "yyyyMMdd-HHmmss"
$reportPath = Join-Path $reportDir "baseline-check-$runStamp.json"

$summary = [PSCustomObject]@{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Workspace = "C:\myAI_System"
    IncludeDeepAudit = [bool]$IncludeDeepAudit
    TotalChecks = $results.Count
    Passed = @($results | Where-Object { $_.Status -eq "Passed" }).Count
    Failed = @($results | Where-Object { $_.Status -eq "Failed" }).Count
    Missing = @($results | Where-Object { $_.Status -eq "Missing" }).Count
    Checks = $results
}

$summary | ConvertTo-Json -Depth 8 | Set-Content -Path $reportPath -Encoding UTF8

Write-Header "BASELINE CHECK SUMMARY"
$results | Select-Object Name, Status, ExitCode, DurationSec | Format-Table -AutoSize
Write-Info "JSON report: $reportPath"

if ($summary.Failed -gt 0 -or $summary.Missing -gt 0) {
    exit 1
}

exit 0
