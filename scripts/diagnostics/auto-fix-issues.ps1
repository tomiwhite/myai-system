# ============================================================================
# AUTO-FIX COMMON ISSUES
# ============================================================================

param(
    [switch]$WhatIf
)

$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backupDir = "C:\myAI_System\backups\config-backups"
$logDir = "C:\myAI_System\logs"
$changeLog = @()

function Add-ChangeLog {
    param(
        [string]$Action,
        [string]$Target,
        [string]$Status,
        [string]$Details = ""
    )

    $script:changeLog += [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Action = $Action
        Target = $Target
        Status = $Status
        Details = $Details
    }
}

function Backup-ExecutionPolicy {
    if (-not (Test-Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }

    $backupPath = Join-Path $backupDir "execution-policy-backup-$timestamp.json"
    @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        CurrentUser = Get-ExecutionPolicy -Scope CurrentUser
        LocalMachine = Get-ExecutionPolicy -Scope LocalMachine
        Process = Get-ExecutionPolicy -Scope Process
    } | ConvertTo-Json | Set-Content $backupPath -Encoding UTF8

    return $backupPath
}

function Save-RunLog {
    if (-not (Test-Path $logDir)) {
        New-Item -Path $logDir -ItemType Directory -Force | Out-Null
    }

    $logPath = Join-Path $logDir "auto-fix-issues-$timestamp.json"
    $changeLog | ConvertTo-Json -Depth 5 | Set-Content $logPath -Encoding UTF8
    return $logPath
}

Write-Host "`n🔧 AUTO-FIX - Naprawiam Znalezione Problemy`n" -ForegroundColor Cyan

if ($WhatIf) {
    Write-Host "⚠️  TRYB WHATIF - zmiany nie zostaną zastosowane`n" -ForegroundColor Yellow
}

$fixed = @()

# 1. Usuń martwy link myLM_Studio
Write-Host "1️⃣  Usuwam martwy link myLM_Studio..." -ForegroundColor Yellow
$desktop = [Environment]::GetFolderPath("Desktop")
$deadLink = "$desktop\myLM_Studio — skrót .lnk"
if (Test-Path $deadLink) {
    if ($WhatIf) {
        Write-Host "   ℹ️  WhatIf: usunąłbym $deadLink" -ForegroundColor Cyan
        Add-ChangeLog -Action "RemoveDeadLink" -Target $deadLink -Status "WhatIf"
    } else {
        Remove-Item $deadLink -Force
        Write-Host "   ✅ Usunięto" -ForegroundColor Green
        $fixed += "Usunięto martwy link: myLM_Studio"
        Add-ChangeLog -Action "RemoveDeadLink" -Target $deadLink -Status "Applied"
    }
} else {
    Write-Host "   ℹ️  Nie znaleziono (może już usunięty)" -ForegroundColor Gray
    Add-ChangeLog -Action "RemoveDeadLink" -Target $deadLink -Status "Skipped" -Details "Not found"
}

# 2. Ustaw Execution Policy
Write-Host "`n2️⃣  Ustawiam Execution Policy..." -ForegroundColor Yellow
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq "Undefined" -or $currentPolicy -eq "Restricted") {
    if ($WhatIf) {
        Write-Host "   ℹ️  WhatIf: ustawiłbym CurrentUser na RemoteSigned" -ForegroundColor Cyan
        Add-ChangeLog -Action "SetExecutionPolicy" -Target "CurrentUser" -Status "WhatIf" -Details "RemoteSigned"
    } else {
        $policyBackup = Backup-ExecutionPolicy
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Host "   ✅ Ustawiono: RemoteSigned" -ForegroundColor Green
        Write-Host "   💾 Backup: $policyBackup" -ForegroundColor Cyan
        $fixed += "Execution Policy → RemoteSigned"
        Add-ChangeLog -Action "SetExecutionPolicy" -Target "CurrentUser" -Status "Applied" -Details "RemoteSigned; backup=$policyBackup"
    }
} else {
    Write-Host "   ✅ Już ustawione: $currentPolicy" -ForegroundColor Green
    Add-ChangeLog -Action "SetExecutionPolicy" -Target "CurrentUser" -Status "Skipped" -Details $currentPolicy
}

# 3. Sprawdź Git config (OxygenUp to prawdziwy profil GitHub, nie zmieniamy)
Write-Host "`n3️⃣  Sprawdzam Git config..." -ForegroundColor Yellow
$gitName = git config --global user.name 2>$null
$gitEmail = git config --global user.email 2>$null

Write-Host "   Aktualne: $gitName <$gitEmail>" -ForegroundColor White

# Sprawdzamy czy email to GitHub noreply
if (-not $gitEmail) {
    Write-Host "   ⚠️  Brak Git email w konfiguracji globalnej" -ForegroundColor Yellow
    Write-Host "   Zalecany: 45501831+tomiwhite@users.noreply.github.com" -ForegroundColor Cyan
} elseif ($gitEmail -notmatch "@users.noreply.github.com$") {
    Write-Host "   ⚠️  Email powinien być GitHub noreply!" -ForegroundColor Yellow
    Write-Host "   Zalecany: 45501831+tomiwhite@users.noreply.github.com" -ForegroundColor Cyan
} else {
    Write-Host "   ✅ Email OK (GitHub noreply)" -ForegroundColor Green
}

if ($gitName) {
    Write-Host "   ✅ user.name OK ($gitName)" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Brak Git user.name w konfiguracji globalnej" -ForegroundColor Yellow
}

# 4. Upewnij się że D:\myai\.env ma poprawną zawartość
Write-Host "`n4️⃣  Sprawdzam D:\myai\.env..." -ForegroundColor Yellow
if (Test-Path "D:\myai\.env") {
    $content = Get-Content "D:\myai\.env" -Raw
    if ($content -match "ENVIRONMENT=") {
        Write-Host "   ✅ D:\myai\.env ma zawartość" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️  D:\myai\.env pusty lub niepoprawny" -ForegroundColor Yellow
        if (Test-Path "D:\myai\.env.template") {
            if ($WhatIf) {
                Write-Host "   ℹ️  WhatIf: skopiowałbym D:\myai\.env.template → D:\myai\.env" -ForegroundColor Cyan
                Add-ChangeLog -Action "CopyEnvTemplate" -Target "D:\myai\.env" -Status "WhatIf"
            } else {
                Write-Host "   Kopiuję z template..." -ForegroundColor Cyan
                Copy-Item "D:\myai\.env.template" "D:\myai\.env" -Force
                $fixed += "Utworzono D:\myai\.env z template"
                Add-ChangeLog -Action "CopyEnvTemplate" -Target "D:\myai\.env" -Status "Applied"
            }
        }
    }
} else {
    Write-Host "   ⚠️  D:\myai\.env nie istnieje" -ForegroundColor Yellow
    if (Test-Path "D:\myai\.env.template") {
        if ($WhatIf) {
            Write-Host "   ℹ️  WhatIf: utworzyłbym D:\myai\.env z template" -ForegroundColor Cyan
            Add-ChangeLog -Action "CopyEnvTemplate" -Target "D:\myai\.env" -Status "WhatIf"
        } else {
            Write-Host "   Tworzę z template..." -ForegroundColor Cyan
            Copy-Item "D:\myai\.env.template" "D:\myai\.env" -Force
            Write-Host "   ✅ Utworzono" -ForegroundColor Green
            $fixed += "Utworzono D:\myai\.env z template"
            Add-ChangeLog -Action "CopyEnvTemplate" -Target "D:\myai\.env" -Status "Applied"
        }
    }
}

# 5. Sprawdź uprawnienia do .env
Write-Host "`n5️⃣  Sprawdzam uprawnienia .env..." -ForegroundColor Yellow
if (Test-Path "C:\myai\.env") {
    $env = Get-Item "C:\myai\.env"
    if (-not $env.IsReadOnly) {
        if ($WhatIf) {
            Write-Host "   ℹ️  WhatIf: ustawiłbym read-only dla C:\myai\.env" -ForegroundColor Cyan
            Add-ChangeLog -Action "SetReadOnly" -Target "C:\myai\.env" -Status "WhatIf"
        } else {
            $env.IsReadOnly = $true
            Write-Host "   ✅ Ustawiono read-only dla C:\myai\.env" -ForegroundColor Green
            $fixed += "C:\myai\.env → read-only"
            Add-ChangeLog -Action "SetReadOnly" -Target "C:\myai\.env" -Status "Applied"
        }
    } else {
        Write-Host "   ✅ C:\myai\.env już read-only" -ForegroundColor Green
        Add-ChangeLog -Action "SetReadOnly" -Target "C:\myai\.env" -Status "Skipped" -Details "Already read-only"
    }
}

# 6. Sprawdź czy są inne martwe linki
Write-Host "`n6️⃣  Szukam innych martwych linków..." -ForegroundColor Yellow
$shortcuts = Get-ChildItem $desktop -Filter "*.lnk"
$deadCount = 0

foreach ($shortcut in $shortcuts) {
    try {
        $shell = New-Object -ComObject WScript.Shell
        $link = $shell.CreateShortcut($shortcut.FullName)
        $target = $link.TargetPath
        
        if ($target -and -not (Test-Path $target)) {
            Write-Host "   ❌ $($shortcut.Name) → Martwy" -ForegroundColor Red
            Write-Host "      Target: $target" -ForegroundColor Gray
            if ($WhatIf) {
                Write-Host "      WhatIf: usunąłbym..." -ForegroundColor Cyan
                Add-ChangeLog -Action "RemoveDeadLink" -Target $shortcut.FullName -Status "WhatIf" -Details $target
            } else {
                Write-Host "      Usuwam..." -ForegroundColor Yellow
                Remove-Item $shortcut.FullName -Force
                $deadCount++
                $fixed += "Usunięto martwy link: $($shortcut.Name)"
                Add-ChangeLog -Action "RemoveDeadLink" -Target $shortcut.FullName -Status "Applied" -Details $target
            }
        }
        
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    } catch {}
}

if ($deadCount -eq 0) {
    Write-Host "   ✅ Nie znaleziono więcej martwych linków" -ForegroundColor Green
} else {
    Write-Host "   ✅ Usunięto $deadCount martwych linków" -ForegroundColor Green
}

if ($WhatIf -or $changeLog.Count -gt 0) {
    $logPath = Save-RunLog
    Write-Host "`n📝 Log zmian: $logPath" -ForegroundColor Cyan
}

# Podsumowanie
Write-Host "`n" -NoNewline
Write-Host "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE NAPRAW:" -ForegroundColor Yellow

if ($fixed.Count -eq 0) {
    if ($WhatIf -and $changeLog.Count -gt 0) {
        Write-Host "   ℹ️  WhatIf wykrył potencjalne zmiany, ale nic nie zostało zastosowane" -ForegroundColor Cyan
    } else {
        Write-Host "   ✅ Wszystko było już OK!" -ForegroundColor Green
    }
} else {
    Write-Host "   🔧 Naprawiono: $($fixed.Count) rzeczy" -ForegroundColor Cyan
    foreach ($fix in $fixed) {
        Write-Host "      • $fix" -ForegroundColor White
    }
}

Write-Host "`n✅ Auto-fix zakończony!`n" -ForegroundColor Green
