#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Automatyczne usuwanie folderów po odinstalowanych programach
.DESCRIPTION
    Pobiera listę zainstalowanych programów z rejestru i usuwa foldery bez dopasowania
#>

param(
    [switch]$DryRun,  # Tylko pokaż co zostanie usunięte
    [switch]$Aggressive  # Usuń też małe foldery bez .exe
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🧹 AUTO-CLEANUP: Foldery po odinstalowanych programach" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "⚠️  Tryb DRY RUN - nic nie zostanie usunięte`n" -ForegroundColor Yellow
}

# ============================================================================
# CZĘŚĆ 1: POBIERZ LISTĘ ZAINSTALOWANYCH PROGRAMÓW (PANEL STEROWANIA)
# ============================================================================

Write-Host "📋 Skanowanie zainstalowanych programów (Panel Sterowania)..." -ForegroundColor Yellow

$installedPrograms = @()
$installedFolders = @()

# Rejestr - TYLKO te z DisplayName (Programy i funkcje)
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

foreach ($path in $regPaths) {
    Get-ItemProperty $path 2>$null | ForEach-Object {
        # TYLKO programy z nazwą wyświetlaną
        if ($_.DisplayName -and $_.DisplayName.Length -gt 2) {
            $displayName = $_.DisplayName.Trim()
            $installedPrograms += $displayName
            
            # Dodaj lokalizację instalacji (ważne!)
            if ($_.InstallLocation) {
                $folderName = Split-Path $_.InstallLocation -Leaf
                if ($folderName -and $folderName.Length -gt 2) {
                    $installedFolders += $folderName.Trim()
                }
            }
            
            # Dodaj wydawcę (niektóre foldery nazywane po wydawcy)
            if ($_.Publisher -and $_.Publisher.Length -gt 3) {
                $installedPrograms += $_.Publisher.Trim()
            }
        }
    }
}

# Windows Settings (ms-settings:appsfeatures)
Write-Host "   Skanowanie Windows Settings..." -ForegroundColor Gray
Get-AppxPackage | ForEach-Object {
    if ($_.Name) {
        $installedPrograms += $_.Name
        # Wyciągnij pierwszą część nazwy (przed kropką)
        $shortName = $_.Name.Split('.')[0]
        if ($shortName.Length -gt 3) {
            $installedPrograms += $shortName
        }
    }
}

# Usuń duplikaty
$installedPrograms = $installedPrograms | Where-Object { $_ } | Select-Object -Unique | Sort-Object
$installedFolders = $installedFolders | Where-Object { $_ } | Select-Object -Unique | Sort-Object

Write-Host "   ✅ Programy: $($installedPrograms.Count)" -ForegroundColor Green
Write-Host "   ✅ Foldery instalacji: $($installedFolders.Count)" -ForegroundColor Green

# DEBUG: Zapisz listę do pliku
$debugPath = "C:\myAI_System\reports\cleanup\installed-programs-debug.txt"
New-Item -ItemType Directory -Path "C:\myAI_System\reports\cleanup" -Force | Out-Null
@"
ZAINSTALOWANE PROGRAMY ($($installedPrograms.Count)):
$($installedPrograms -join "`n")

FOLDERY INSTALACJI ($($installedFolders.Count)):
$($installedFolders -join "`n")
"@ | Set-Content $debugPath -Encoding UTF8

Write-Host "   📄 Debug: $debugPath`n" -ForegroundColor Cyan

# ============================================================================
# CZĘŚĆ 2: BEZPIECZNA LISTA (NIE USUWAJ)
# ============================================================================

$safeList = @(
    # System
    "Windows*", "Microsoft*", "WindowsApps", "Common Files", "Internet Explorer",
    "Windows Defender*", "Windows Mail", "Windows Media Player", "Windows NT",
    "Windows Photo Viewer", "Windows Sidebar", "Windows PowerShell", "MSBuild",
    "Reference Assemblies", "Uninstall Information", "ModifiableWindowsApps",
    
    # Programowanie i narzędzia
    "Git", "GitHub CLI", "dotnet", "nodejs", "PowerShell", "Python*", "Intel",
    "IIS", "IIS Express", "Application Verifier", "Microsoft SQL Server",
    "Microsoft Visual Studio", "Microsoft SDKs", "Nuget", "Microsoft.NET",
    
    # Hardware
    "NVIDIA Corporation", "HP", "Hewlett-Packard", "CONEXANT", "Bonjour",
    
    # Obecnie używane (sprawdź swoje!)
    "Docker", "Dropbox", "Google", "CCleaner"
)

# ============================================================================
# CZĘŚĆ 3: FUNKCJA DOPASOWANIA (PRECYZYJNA)
# ============================================================================

function Test-ProgramInstalled {
    param([string]$FolderName)
    
    # 1. Safe lista
    foreach ($safe in $safeList) {
        if ($FolderName -like $safe) {
            return $true
        }
    }
    
    # 2. Dokładne dopasowanie do folderu instalacji
    if ($installedFolders -contains $FolderName) {
        return $true
    }
    
    # 3. Dopasowanie do nazw programów
    $cleanFolder = $FolderName -replace '[^a-zA-Z0-9]', '' -replace '\s', ''
    
    foreach ($installed in $installedPrograms) {
        $cleanInstalled = $installed -replace '[^a-zA-Z0-9]', '' -replace '\s', ''
        
        # Dokładne dopasowanie (bez spacji/znaków)
        if ($cleanFolder -eq $cleanInstalled) { 
            return $true 
        }
        
        # Folder jest częścią nazwy programu (min 5 znaków)
        if ($cleanFolder.Length -ge 5 -and $cleanInstalled -like "*$cleanFolder*") { 
            return $true 
        }
        
        # Nazwa programu jest częścią folderu (min 5 znaków)
        if ($cleanInstalled.Length -ge 5 -and $cleanFolder -like "*$cleanInstalled*") { 
            return $true 
        }
    }
    
    return $false
}

# ============================================================================
# CZĘŚĆ 4: SKANUJ PROGRAM FILES
# ============================================================================

$programDirs = @(
    "C:\Program Files",
    "C:\Program Files (x86)"
)

$toDelete = @()
$totalSize = 0

Write-Host "🔍 Skanowanie Program Files..." -ForegroundColor Yellow

$pfOrphans = @()

foreach ($dir in $programDirs) {
    $allFolders = Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue
    Write-Host "   Skanowanie $dir ($($allFolders.Count) folderów)..." -ForegroundColor Gray
    
    foreach ($folder in $allFolders) {
        $folderName = $folder.Name
        
        # Sprawdź czy zainstalowany
        $isInstalled = Test-ProgramInstalled $folderName
        
        if (-not $isInstalled) {
            try {
                # Policz rozmiar
                $items = Get-ChildItem $folder.FullName -Recurse -Force -File -ErrorAction SilentlyContinue
                $size = ($items | Measure-Object -Property Length -Sum).Sum
                
                if ($null -eq $size) { $size = 0 }
                $sizeMB = [math]::Round($size / 1MB, 2)
                
                # Sprawdź czy ma .exe
                $hasExe = Get-ChildItem $folder.FullName -Recurse -Filter "*.exe" -Force -ErrorAction SilentlyContinue | Select-Object -First 1
                
                # Zapisz info o osieroconym folderze
                $pfOrphans += [PSCustomObject]@{
                    Type = if ($dir -like "*x86*") { "Program Files (x86)" } else { "Program Files" }
                    Path = $folder.FullName
                    Name = $folderName
                    SizeMB = $sizeMB
                    FileCount = $items.Count
                    HasExe = [bool]$hasExe
                }
                
                # Dodaj do usuwania TYLKO jeśli spełnia warunki
                if ($Aggressive -or (-not $hasExe -and $sizeMB -lt 10)) {
                    $toDelete += $pfOrphans[-1]
                    $totalSize += $sizeMB
                }
            } catch {
                # Pomiń błędy dostępu
            }
        }
    }
}

Write-Host "   ✅ Osierocone foldery: $($pfOrphans.Count) ($([math]::Round(($pfOrphans | Measure-Object -Property SizeMB -Sum).Sum, 2)) MB)" -ForegroundColor Yellow
Write-Host "   ✅ Do usunięcia: $($toDelete.Count) ($([math]::Round($totalSize, 2)) MB)`n" -ForegroundColor Green

# Zapisz pełną listę osieroconych (nie tylko do usunięcia)
$orphanedPath = "C:\myAI_System\reports\cleanup\program-files-orphaned.txt"
@"
OSIEROCONE FOLDERY W PROGRAM FILES ($($pfOrphans.Count)):

$($pfOrphans | Sort-Object SizeMB -Descending | ForEach-Object { 
    $exeStatus = if ($_.HasExe) { "[EXE]" } else { "     " }
    "$exeStatus $($_.Name) - $($_.SizeMB) MB ($($_.FileCount) plików)"
})
"@ | Set-Content $orphanedPath -Encoding UTF8
Write-Host "   📄 Lista osieroconych: $orphanedPath`n" -ForegroundColor Cyan

# ============================================================================
# CZĘŚĆ 5: SKANUJ PROGRAMDATA
# ============================================================================

Write-Host "🔍 Skanowanie ProgramData..." -ForegroundColor Yellow

$programData = "C:\ProgramData"
$pdSize = 0

Get-ChildItem $programData -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $folder = $_
    $folderName = $folder.Name
    
    # Sprawdź czy zainstalowany
    if (-not (Test-ProgramInstalled $folderName)) {
        try {
            $items = Get-ChildItem $folder.FullName -Recurse -Force -File -ErrorAction SilentlyContinue
            $size = ($items | Measure-Object -Property Length -Sum).Sum
            
            if ($null -eq $size) { $size = 0 }
            $sizeMB = [math]::Round($size / 1MB, 2)
            
            if ($sizeMB -gt 0.5) {  # Min 500KB
                $toDelete += [PSCustomObject]@{
                    Type = "ProgramData"
                    Path = $folder.FullName
                    Name = $folderName
                    SizeMB = $sizeMB
                    FileCount = $items.Count
                    HasExe = $false
                }
                
                $pdSize += $sizeMB
            }
        } catch {
            # Pomiń błędy
        }
    }
}

Write-Host "   ✅ Znaleziono $($toDelete.Where({$_.Type -eq 'ProgramData'}).Count) folderów sierot ($([math]::Round($pdSize, 2)) MB)`n" -ForegroundColor Green

# ============================================================================
# CZĘŚĆ 6: SKANUJ APPDATA
# ============================================================================

Write-Host "🔍 Skanowanie AppData..." -ForegroundColor Yellow

$appDataDirs = @(
    "$env:LOCALAPPDATA",
    "$env:APPDATA"
)

$appSize = 0

foreach ($appData in $appDataDirs) {
    Get-ChildItem $appData -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $folder = $_
        $folderName = $folder.Name
        
        # Sprawdź czy zainstalowany
        if (-not (Test-ProgramInstalled $folderName)) {
            try {
                $items = Get-ChildItem $folder.FullName -Recurse -Force -File -ErrorAction SilentlyContinue
                $size = ($items | Measure-Object -Property Length -Sum).Sum
                
                if ($null -eq $size) { $size = 0 }
                $sizeMB = [math]::Round($size / 1MB, 2)
                
                if ($sizeMB -gt 10) {  # Min 10MB dla AppData
                    $location = if ($appData -like "*Local*") { "AppData\Local" } else { "AppData\Roaming" }
                    
                    $toDelete += [PSCustomObject]@{
                        Type = $location
                        Path = $folder.FullName
                        Name = $folderName
                        SizeMB = $sizeMB
                        FileCount = $items.Count
                        HasExe = $false
                    }
                    
                    $appSize += $sizeMB
                }
            } catch {
                # Pomiń błędy
            }
        }
    }
}

Write-Host "   ✅ Znaleziono $($toDelete.Where({$_.Type -like 'AppData*'}).Count) folderów sierot ($([math]::Round($appSize, 2)) MB)`n" -ForegroundColor Green

# ============================================================================
# CZĘŚĆ 7: POKAŻ PODSUMOWANIE
# ============================================================================

$totalToDelete = $toDelete.Count
$totalMB = ($toDelete | Measure-Object -Property SizeMB -Sum).Sum

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 ZNALEZIONO DO USUNIĘCIA" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "   📦 Łącznie: $totalToDelete folderów ($([math]::Round($totalMB, 2)) MB)" -ForegroundColor Yellow
Write-Host "   📁 Program Files: $($toDelete.Where({$_.Type -eq 'Program Files'}).Count) folderów" -ForegroundColor Gray
Write-Host "   📁 ProgramData: $($toDelete.Where({$_.Type -eq 'ProgramData'}).Count) folderów" -ForegroundColor Gray
Write-Host "   📁 AppData: $($toDelete.Where({$_.Type -like 'AppData*'}).Count) folderów`n" -ForegroundColor Gray

if ($DryRun) {
    Write-Host "📋 LISTA (TOP 50 największych):`n" -ForegroundColor Yellow
    
    $toDelete | Sort-Object SizeMB -Descending | Select-Object -First 50 | ForEach-Object {
        $icon = if ($_.HasExe) { "⚠️" } else { "❌" }
        Write-Host "   $icon [$($_.Type)] $($_.Name) - $($_.SizeMB) MB ($($_.FileCount) plików)" -ForegroundColor Gray
        Write-Host "      $($_.Path)" -ForegroundColor DarkGray
    }
    
    Write-Host "`n💡 Uruchom bez -DryRun aby usunąć`n" -ForegroundColor Cyan
    exit
}

# ============================================================================
# CZĘŚĆ 8: USUŃ (Z POTWIERDZENIEM)
# ============================================================================

Write-Host "⚠️  CZY NA PEWNO USUNĄĆ TE FOLDERY?" -ForegroundColor Yellow
Write-Host "   Wpisz 'TAK' aby potwierdzić: " -ForegroundColor White -NoNewline
$confirm = Read-Host

if ($confirm -ne 'TAK') {
    Write-Host "`n❌ Anulowano" -ForegroundColor Red
    exit
}

# Manifest przed usuwaniem (punkt odniesienia do audytu/odtworzenia)
$reportDir = "C:\myAI_System\reports\cleanup"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$manifestPath = Join-Path $reportDir "cleanup-orphaned-manifest-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
@{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalToDelete = $totalToDelete
    TotalMB = [math]::Round($totalMB, 2)
    Items = $toDelete | Select-Object Type, Name, Path, SizeMB, FileCount, HasExe
} | ConvertTo-Json -Depth 10 | Set-Content $manifestPath -Encoding UTF8
Write-Host "📝 Manifest przed usuwaniem: $manifestPath`n" -ForegroundColor Cyan

Write-Host "`n🗑️  Usuwanie...`n" -ForegroundColor Yellow

$deleted = 0
$freedMB = 0
$errors = @()

foreach ($item in $toDelete | Sort-Object SizeMB -Descending) {
    try {
        Write-Host "   🗑️  $($item.Name) ($($item.SizeMB) MB)..." -NoNewline
        
        Remove-Item $item.Path -Force -Recurse -ErrorAction Stop
        
        $deleted++
        $freedMB += $item.SizeMB
        
        Write-Host " ✅" -ForegroundColor Green
    } catch {
        Write-Host " ❌ $($_.Exception.Message)" -ForegroundColor Red
        $errors += "$($item.Name): $($_.Exception.Message)"
    }
}

# ============================================================================
# CZĘŚĆ 9: RAPORT KOŃCOWY
# ============================================================================

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ ZAKOŃCZONO CZYSZCZENIE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "   ✅ Usunięto: $deleted folderów" -ForegroundColor Green
Write-Host "   💾 Zwolniono: $([math]::Round($freedMB, 2)) MB ($([math]::Round($freedMB/1024, 2)) GB)" -ForegroundColor Green
Write-Host "   ❌ Błędy: $($errors.Count)`n" -ForegroundColor $(if ($errors.Count -gt 0) { "Yellow" } else { "Green" })

if ($errors.Count -gt 0) {
    Write-Host "⚠️  BŁĘDY:" -ForegroundColor Yellow
    $errors | ForEach-Object {
        Write-Host "   $_" -ForegroundColor Gray
    }
    Write-Host ""
}

# Zapisz raport
$reportPath = "C:\myAI_System\reports\cleanup\cleanup-orphaned-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$report = @{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalDeleted = $deleted
    FreedMB = [math]::Round($freedMB, 2)
    FreedGB = [math]::Round($freedMB/1024, 2)
    Errors = $errors
    DeletedItems = $toDelete | Select-Object Type, Name, SizeMB
}

New-Item -ItemType Directory -Path "C:\myAI_System\reports\cleanup" -Force | Out-Null
$report | ConvertTo-Json -Depth 10 | Set-Content $reportPath -Encoding UTF8

Write-Host "📄 Raport zapisany: $reportPath`n" -ForegroundColor Cyan
