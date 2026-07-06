#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Usuwa TYLKO 100% bezpieczne śmieci (nie dev tools)
#>

param(
    [switch]$DryRun
)

$ErrorActionPreference = "SilentlyContinue"

$localAppData = $env:LOCALAPPDATA
$roamingAppData = $env:APPDATA
$runTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🧹 BEZPIECZNE CZYSZCZENIE - TYLKO ŚMIECI" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Lista TYLKO 100% bezpiecznych do usunięcia
$safeToDelete = @(
    # Cache instalatorów
    @{ Path = "C:\ProgramData\Package Cache"; Name = "Package Cache (VS installers)"; Type = "Cache" },
    @{ Path = (Join-Path $localAppData "Package Cache"); Name = "Package Cache (local)"; Type = "Cache" },
    @{ Path = (Join-Path $localAppData "SquirrelTemp"); Name = "SquirrelTemp (installers)"; Type = "Cache" },
    
    # Updatery (POMINIĘTE - użyj reinstall-three-apps.ps1)
    # @{ Path = (Join-Path $localAppData "highlight-updater"); Name = "Highlight updater"; Type = "Updater" },
    # @{ Path = (Join-Path $localAppData "lm-studio-updater"); Name = "LM Studio updater"; Type = "Updater" },
    # @{ Path = (Join-Path $localAppData "ac-electron-updater"); Name = "AC Electron updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "nativeaccess2-updater"); Name = "Native Access updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "keystation-88-mk3-software-manager-updater"); Name = "Keystation updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "ujamapp-updater"); Name = "UJAM updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "softubecentral-updater"); Name = "Softube updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "notion-updater"); Name = "Notion updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "productmanager-updater"); Name = "Product Manager updater"; Type = "Updater" },
    @{ Path = (Join-Path $localAppData "landr-desktop-app-updater"); Name = "LANDR updater"; Type = "Updater" },
    
    # Audio software (nie związane z myAI)
    @{ Path = "C:\ProgramData\Steinberg"; Name = "Steinberg (Cubase/audio)"; Type = "Audio" },
    @{ Path = (Join-Path $roamingAppData "Steinberg"); Name = "Steinberg AppData"; Type = "Audio" },
    @{ Path = (Join-Path $localAppData "Steinberg Download Assistant"); Name = "Steinberg Download Assistant"; Type = "Audio" },
    @{ Path = (Join-Path $roamingAppData "Pro Sound Effects"); Name = "Pro Sound Effects"; Type = "Audio" },
    @{ Path = (Join-Path $roamingAppData "IK Product Manager"); Name = "IK Product Manager"; Type = "Audio" },
    @{ Path = (Join-Path $roamingAppData "Custom Shop"); Name = "Custom Shop"; Type = "Audio" },
    @{ Path = (Join-Path $roamingAppData "ujamapp"); Name = "UJAM app"; Type = "Audio" },
    @{ Path = (Join-Path $roamingAppData "Native Instruments"); Name = "Native Instruments"; Type = "Audio" },
    @{ Path = (Join-Path $localAppData "LANDR"); Name = "LANDR"; Type = "Audio" },
    @{ Path = (Join-Path $localAppData "Ableton"); Name = "Ableton"; Type = "Audio" },
    @{ Path = "C:\ProgramData\Softube"; Name = "Softube"; Type = "Audio" },
    @{ Path = "C:\ProgramData\Avid"; Name = "Avid"; Type = "Audio" },
    @{ Path = "C:\ProgramData\Akai"; Name = "Akai"; Type = "Audio" },
    @{ Path = "C:\ProgramData\UIU"; Name = "UIU"; Type = "Audio" },
    @{ Path = "C:\ProgramData\Minimal"; Name = "Minimal"; Type = "Audio" },
    
    # Inne (nie dev tools)
    @{ Path = (Join-Path $localAppData "CEF"); Name = "CEF (Chromium cache)"; Type = "Cache" },
    @{ Path = (Join-Path $localAppData "WinSparkle"); Name = "WinSparkle (updater framework)"; Type = "Cache" },
    # WYKLUCZONO - AKTYWNE USŁUGI WINDOWS:
    # @{ Path = (Join-Path $localAppData "Comms"); Name = "Comms"; Type = "Cache" },  # CrossDeviceService
    # @{ Path = (Join-Path $localAppData "ConnectedDevicesPlatform"); Name = "Connected Devices"; Type = "Cache" },  # PhoneExperienceHost
    # @{ Path = "C:\ProgramData\USOShared"; Name = "Windows Update cache"; Type = "Cache" },  # UsoSvc
    # @{ Path = "C:\ProgramData\USOPrivate"; Name = "Windows Update cache"; Type = "Cache" },  # UsoSvc
    @{ Path = (Join-Path $roamingAppData "com.adobe.dunamis"); Name = "Adobe Dunamis"; Type = "Adobe" }
)

$totalSize = 0
$deleted = 0
$errors = @()

Write-Host "📋 LISTA DO USUNIĘCIA:`n" -ForegroundColor Yellow

# Najpierw policz rozmiary
foreach ($item in $safeToDelete) {
    if (Test-Path $item.Path) {
        try {
            $items = Get-ChildItem $item.Path -Recurse -Force -File -ErrorAction SilentlyContinue
            $size = ($items | Measure-Object -Property Length -Sum).Sum
            if ($null -eq $size) { $size = 0 }
            $sizeMB = [math]::Round($size / 1MB, 2)
            
            $item.SizeMB = $sizeMB
            $item.FileCount = $items.Count
            $totalSize += $sizeMB
            
            Write-Host "   ❌ [$($item.Type)] $($item.Name) - $sizeMB MB ($($items.Count) plików)" -ForegroundColor Gray
        } catch {
            Write-Host "   ⚠️  [$($item.Type)] $($item.Name) - błąd dostępu" -ForegroundColor Yellow
        }
    } else {
        Write-Host "   ⏭️  [$($item.Type)] $($item.Name) - już usunięty" -ForegroundColor DarkGray
    }
}

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📦 Łącznie: $([math]::Round($totalSize, 2)) MB ($([math]::Round($totalSize/1024, 2)) GB)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Zapisz manifest przed usuwaniem (punkt odniesienia do audytu/odtworzenia)
$manifestDir = "C:\myAI_System\reports\cleanup"
New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
$manifestPath = Join-Path $manifestDir "safe-cleanup-manifest-$runTimestamp.json"
@{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    DryRun = [bool]$DryRun
    TotalMB = [math]::Round($totalSize, 2)
    Items = @(
        $safeToDelete | Where-Object { $_.ContainsKey('SizeMB') } | ForEach-Object {
            @{
                Name = $_.Name
                Type = $_.Type
                Path = $_.Path
                SizeMB = $_.SizeMB
                FileCount = $_.FileCount
            }
        }
    )
} | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8
Write-Host "📝 Manifest: $manifestPath`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 DRY RUN - nic nie zostanie usunięte" -ForegroundColor Yellow
    Write-Host "   Powyższa lista pokazuje co zostałoby usunięte.`n" -ForegroundColor Gray
    exit 0
}

Write-Host "⚠️  CZY USUNĄĆ? Wpisz 'TAK': " -ForegroundColor Yellow -NoNewline
$confirm = Read-Host

if ($confirm -ne 'TAK') {
    Write-Host "`n❌ Anulowano`n" -ForegroundColor Red
    exit
}

Write-Host "`n🗑️  Usuwanie...`n" -ForegroundColor Yellow

foreach ($item in $safeToDelete) {
    if (Test-Path $item.Path) {
        try {
            Write-Host "   🗑️  $($item.Name)..." -NoNewline
            
            # Usuń pliki pojedynczo (pomiń zablokowane)
            $filesDeleted = 0
            $filesSkipped = 0
            
            Get-ChildItem $item.Path -Recurse -Force -File -ErrorAction SilentlyContinue | ForEach-Object {
                try {
                    Remove-Item $_.FullName -Force -ErrorAction Stop
                    $filesDeleted++
                } catch {
                    $filesSkipped++
                }
            }
            
            # Usuń puste foldery
            Get-ChildItem $item.Path -Recurse -Force -Directory -ErrorAction SilentlyContinue | 
                Sort-Object -Property FullName -Descending | ForEach-Object {
                    if ((Get-ChildItem $_.FullName -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                        Remove-Item $_.FullName -Force -ErrorAction SilentlyContinue
                    }
                }
            
            # Usuń główny folder jeśli pusty
            if ((Get-ChildItem $item.Path -Force -ErrorAction SilentlyContinue).Count -eq 0) {
                Remove-Item $item.Path -Force -ErrorAction SilentlyContinue
            }
            
            if ($filesSkipped -gt 0) {
                Write-Host " ⚠️  $($item.SizeMB) MB ($filesSkipped zablokowanych)" -ForegroundColor Yellow
            } else {
                Write-Host " ✅ $($item.SizeMB) MB" -ForegroundColor Green
            }
            
            $deleted++
        } catch {
            Write-Host " ❌ $($_.Exception.Message)" -ForegroundColor Red
            $errors += "$($item.Name): $($_.Exception.Message)"
        }
    }
}

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ ZAKOŃCZONO" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
Write-Host "   ✅ Usunięto: $deleted folderów" -ForegroundColor Green
Write-Host "   💾 Zwolniono: $([math]::Round($totalSize, 2)) MB ($([math]::Round($totalSize/1024, 2)) GB)" -ForegroundColor Green
Write-Host "   ❌ Błędy: $($errors.Count)`n" -ForegroundColor $(if ($errors.Count -gt 0) { "Yellow" } else { "Green" })

# Raport
$reportPath = "C:\myAI_System\reports\cleanup\safe-cleanup-$runTimestamp.json"
New-Item -ItemType Directory -Path "C:\myAI_System\reports\cleanup" -Force | Out-Null
@{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Deleted = $deleted
    FreedMB = [math]::Round($totalSize, 2)
    FreedGB = [math]::Round($totalSize/1024, 2)
    Errors = $errors
    Manifest = $manifestPath
} | ConvertTo-Json | Set-Content $reportPath -Encoding UTF8

Write-Host "📄 Raport: $reportPath`n" -ForegroundColor Cyan
