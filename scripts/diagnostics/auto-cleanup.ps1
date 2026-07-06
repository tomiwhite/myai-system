#Requires -RunAsAdministrator
# ============================================================================
# AUTO-CLEANUP - Automatyczne czyszczenie systemu
# ============================================================================

param(
    [switch]$DryRun
)

$runTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupDir = "C:\myAI_System\backups\registry-backups"
$reportDir = "C:\myAI_System\reports\cleanup"
$plannedActions = @()

function Add-PlannedAction {
    param(
        [string]$Category,
        [string]$Target,
        [string]$Detail = ""
    )

    $script:plannedActions += [PSCustomObject]@{
        Category = $Category
        Target = $Target
        Detail = $Detail
    }
}

function Backup-RegistryKey {
    param(
        [string]$PSPath
    )

    if (-not (Test-Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }

    $regPathForExport = $PSPath -replace '^Microsoft\.PowerShell\.Core\\Registry::', ''
    $regPathForExport = $regPathForExport -replace '^HKEY_LOCAL_MACHINE', 'HKLM' -replace '^HKEY_CURRENT_USER', 'HKCU'
    $safeName = ($regPathForExport -replace '[^a-zA-Z0-9]', '_')
    $backupPath = Join-Path $backupDir "regkey-$safeName-$runTimestamp.reg"
    reg export $regPathForExport $backupPath /y 2>$null | Out-Null
    return $backupPath
}

Write-Host "`n🧹 AUTO-CLEANUP - Czyszczenie systemu`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 DRY RUN - nic nie zostanie usunięte ani zmienione`n" -ForegroundColor Yellow
}

$cleaned = @()

# 1. Usuń puste foldery z Program Files (wymaga admin)
Write-Host "1️⃣  Usuwam puste foldery z Program Files..." -ForegroundColor Yellow

$emptyDirs = @(
    "C:\Program Files\AIR Music Tech",
    "C:\Program Files\Microsoft Update Health Tools",
    "C:\Program Files\MixupAudio",
    "C:\Program Files\ModifiableWindowsApps",
    "C:\Program Files\Slate Digital Connect",
    "C:\Program Files\Softube Central",
    "C:\Program Files (x86)\Adobe",
    "C:\Program Files (x86)\Newfangled Audio",
    "C:\Program Files (x86)\PSPaudioware",
    "C:\Program Files (x86)\Techivation"
)

foreach ($dir in $emptyDirs) {
    if (Test-Path $dir) {
        $items = Get-ChildItem $dir -Recurse -ErrorAction SilentlyContinue
        if ($items.Count -eq 0) {
            if ($DryRun) {
                Write-Host "   ℹ️  DryRun: usunąłbym pusty folder: $dir" -ForegroundColor Cyan
                Add-PlannedAction -Category "EmptyFolder" -Target $dir
                continue
            }
            try {
                Remove-Item $dir -Force -ErrorAction Stop
                Write-Host "   ✅ Usunięto: $dir" -ForegroundColor Green
                $cleaned += "Pusty folder: $dir"
            } catch {
                Write-Host "   ⚠️  Nie można usunąć: $dir (wymaga admin)" -ForegroundColor Yellow
            }
        }
    }
}

# 2. Napraw uprawnienia do C:\myAI_System i D:\myai
Write-Host "`n2️⃣  Naprawiam uprawnienia..." -ForegroundColor Yellow

$paths = @("C:\myAI_System", "D:\myai")

foreach ($path in $paths) {
    if (Test-Path $path) {
        if ($DryRun) {
            Write-Host "   ℹ️  DryRun: dodałbym FullControl dla biezacego uzytkownika: $path" -ForegroundColor Cyan
            Add-PlannedAction -Category "Acl" -Target $path -Detail "FullControl current user"
            continue
        }
        try {
            $acl = Get-Acl $path
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
            
            # Dodaj pełne uprawnienia dla current user
            $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                $currentUser,
                "FullControl",
                "ContainerInherit,ObjectInherit",
                "None",
                "Allow"
            )
            
            $acl.AddAccessRule($accessRule)
            Set-Acl $path $acl
            
            Write-Host "   ✅ $path - Naprawiono uprawnienia" -ForegroundColor Green
            $cleaned += "Uprawnienia: $path"
        } catch {
            Write-Host "   ⚠️  $path - Wymaga uprawnień administratora" -ForegroundColor Yellow
        }
    }
}

# 3. Przejmij ownership pliku z obcym właścicielem
Write-Host "`n3️⃣  Naprawiam właściciela pliku..." -ForegroundColor Yellow

$foreignFile = "C:\myAI_System\reports\permissions\20251109024250-permissions-audit.json"
if (Test-Path $foreignFile) {
    if ($DryRun) {
        Write-Host "   ℹ️  DryRun: przejąłbym właściciela pliku: $foreignFile" -ForegroundColor Cyan
        Add-PlannedAction -Category "Owner" -Target $foreignFile
    } else {
        try {
            $acl = Get-Acl $foreignFile
            $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().User
            $acl.SetOwner($currentUser)
            Set-Acl $foreignFile $acl
            
            Write-Host "   ✅ Naprawiono właściciela" -ForegroundColor Green
            $cleaned += "Właściciel: $foreignFile"
        } catch {
            Write-Host "   ⚠️  Wymaga uprawnień administratora" -ForegroundColor Yellow
        }
    }
}

# 4. Wyczyść cache AppData (bezpieczne foldery)
Write-Host "`n4️⃣  Czyszczę cache AppData..." -ForegroundColor Yellow

$cacheDirs = @(
    "$env:LOCALAPPDATA\Temp",
    "$env:LOCALAPPDATA\Microsoft\Windows\INetCache",
    "$env:APPDATA\Microsoft\Windows\Recent"
)

$freedSpace = 0

foreach ($cache in $cacheDirs) {
    if (Test-Path $cache) {
        if ($DryRun) {
            $sizeNow = (Get-ChildItem $cache -Recurse -Force -ErrorAction SilentlyContinue |
                        Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } |
                        Measure-Object -Property Length -Sum).Sum / 1MB
            Write-Host "   ℹ️  DryRun: wyczyściłbym $cache (~$([math]::Round($sizeNow, 2)) MB starszych niż 7 dni)" -ForegroundColor Cyan
            Add-PlannedAction -Category "Cache" -Target $cache -Detail "$([math]::Round($sizeNow, 2)) MB"
            continue
        }
        try {
            $sizeBefore = (Get-ChildItem $cache -Recurse -ErrorAction SilentlyContinue | 
                          Measure-Object -Property Length -Sum).Sum / 1MB
            
            Get-ChildItem $cache -Recurse -Force -ErrorAction SilentlyContinue | 
                Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-7) } | 
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            
            $sizeAfter = (Get-ChildItem $cache -Recurse -ErrorAction SilentlyContinue | 
                         Measure-Object -Property Length -Sum).Sum / 1MB
            
            $freed = $sizeBefore - $sizeAfter
            if ($freed -gt 0) {
                $freedSpace += $freed
                Write-Host "   ✅ $cache - Zwolniono $([math]::Round($freed, 2)) MB" -ForegroundColor Green
                $cleaned += "Cache: $cache ($([math]::Round($freed, 2)) MB)"
            }
        } catch {}
    }
}

if ($freedSpace -gt 0) {
    Write-Host "   💾 Całkowicie zwolniono: $([math]::Round($freedSpace, 2)) MB" -ForegroundColor Cyan
}

# 5. Usuń osierocony wpis rejestru (VS Installer)
Write-Host "`n5️⃣  Czyszczę rejestr..." -ForegroundColor Yellow

$regPaths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

try {
    foreach ($regPath in $regPaths) {
        Get-Item $regPath -ErrorAction SilentlyContinue | ForEach-Object {
            $props = Get-ItemProperty $_.PSPath
            if ($props.DisplayName -like "*Visual Studio Installer*" -and 
                $props.InstallLocation -and 
                -not (Test-Path $props.InstallLocation)) {
                
                if ($DryRun) {
                    Write-Host "   ℹ️  DryRun: usunąłbym wpis rejestru: Visual Studio Installer" -ForegroundColor Cyan
                    Add-PlannedAction -Category "Registry" -Target $_.PSPath -Detail "Visual Studio Installer"
                    return
                }

                try {
                    $regBackup = Backup-RegistryKey -PSPath $_.PSPath
                    Remove-Item $_.PSPath -Force
                    Write-Host "   ✅ Usunięto wpis: Visual Studio Installer" -ForegroundColor Green
                    Write-Host "   💾 Backup rejestru: $regBackup" -ForegroundColor Cyan
                    $cleaned += "Rejestr: Visual Studio Installer"
                } catch {
                    Write-Host "   ⚠️  Wymaga uprawnień administratora" -ForegroundColor Yellow
                }
            }
        }
    }
} catch {
    Write-Host "   ⚠️  Nie można edytować rejestru (wymaga admin)" -ForegroundColor Yellow
}

# Podsumowanie
Write-Host "`n"
Write-Host "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE CZYSZCZENIA:" -ForegroundColor Yellow

if ($DryRun) {
    if (-not (Test-Path $reportDir)) {
        New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
    }
    $manifestPath = Join-Path $reportDir "auto-cleanup-dryrun-$runTimestamp.json"
    @{
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        DryRun = $true
        PlannedActions = $plannedActions
    } | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8

    Write-Host "   🔍 DryRun: zaplanowano $($plannedActions.Count) akcji (nic nie wykonano)" -ForegroundColor Cyan
    foreach ($action in $plannedActions) {
        Write-Host "      • [$($action.Category)] $($action.Target) $($action.Detail)" -ForegroundColor White
    }
    Write-Host "   📝 Manifest: $manifestPath" -ForegroundColor Cyan
} elseif ($cleaned.Count -eq 0) {
    Write-Host "   ℹ️  Nic nie wymagało czyszczenia (lub brak uprawnień)" -ForegroundColor Gray
} else {
    Write-Host "   🧹 Wyczyszczono: $($cleaned.Count) elementów" -ForegroundColor Cyan
    foreach ($item in $cleaned) {
        Write-Host "      • $item" -ForegroundColor White
    }
}

Write-Host "`n💡 UWAGA: Niektóre operacje wymagają uprawnień administratora." -ForegroundColor Yellow
Write-Host "   Uruchom jako admin: Start-Process pwsh -Verb RunAs -ArgumentList '-File', 'C:\myAI_System\scripts\diagnostics\auto-cleanup.ps1'" -ForegroundColor Cyan

Write-Host "`n✅ Czyszczenie zakończone!`n" -ForegroundColor Green
