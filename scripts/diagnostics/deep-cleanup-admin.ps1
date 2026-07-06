# ============================================================================
# DEEP CLEANUP WITH ADMIN - Głębokie czyszczenie z uprawnieniami administratora
# ============================================================================

#Requires -RunAsAdministrator

Write-Host "`n🧹 DEEP CLEANUP - Głębokie czyszczenie systemu (ADMIN)`n" -ForegroundColor Cyan

$cleaned = @()
$freedSpace = 0

# ============================================================================
# CZĘŚĆ 1: PROGRAM FILES - Puste foldery i pozostałości
# ============================================================================

Write-Host "="*80 -ForegroundColor Yellow
Write-Host "📁 CZĘŚĆ 1: PROGRAM FILES" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n1️⃣  Szukam pustych folderów..." -ForegroundColor Cyan

$programDirs = @(
    "C:\Program Files",
    "C:\Program Files (x86)"
)

$emptyDirs = @()

foreach ($dir in $programDirs) {
    Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $folder = $_
        $items = Get-ChildItem $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
        
        if ($items.Count -eq 0) {
            $emptyDirs += $folder.FullName
        }
    }
}

Write-Host "   Znaleziono $($emptyDirs.Count) pustych folderów`n" -ForegroundColor Cyan

foreach ($empty in $emptyDirs) {
    Write-Host "   ❌ $empty" -ForegroundColor Gray
    try {
        Remove-Item $empty -Force -Recurse -ErrorAction Stop
        Write-Host "      ✅ Usunięto" -ForegroundColor Green
        $cleaned += "Pusty folder: $empty"
    } catch {
        Write-Host "      ⚠️  Błąd: $_" -ForegroundColor Yellow
    }
}

# ============================================================================
# CZĘŚĆ 2: PROGRAM FILES - Małe foldery (prawdopodobnie śmieci)
# ============================================================================

Write-Host "`n2️⃣  Szukam małych folderów (<5MB, prawdopodobnie śmieci)..." -ForegroundColor Cyan

$smallDirs = @()

foreach ($dir in $programDirs) {
    Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $folder = $_
        
        try {
            $items = Get-ChildItem $folder.FullName -Recurse -Force -File -ErrorAction SilentlyContinue
            $size = ($items | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            
            if ($null -eq $size) { $size = 0 }
            $sizeMB = [math]::Round($size / 1MB, 2)
            
            # Foldery < 5MB które nie zawierają .exe
            if ($sizeMB -lt 5) {
                $hasExe = Get-ChildItem $folder.FullName -Recurse -Filter "*.exe" -Force -ErrorAction SilentlyContinue
                if (-not $hasExe) {
                    $smallDirs += [PSCustomObject]@{
                        Path = $folder.FullName
                        Name = $folder.Name
                        SizeMB = $sizeMB
                        FileCount = $items.Count
                    }
                }
            }
        } catch {
            # Pomiń foldery bez dostępu
        }
    }
}

Write-Host "   Znaleziono $($smallDirs.Count) małych folderów bez plików exe`n" -ForegroundColor Cyan

foreach ($small in $smallDirs | Sort-Object SizeMB -Descending) {
    Write-Host "   ❌ $($small.Name) ($($small.SizeMB) MB, $($small.FileCount) plików)" -ForegroundColor Gray
    Write-Host "      $($small.Path)" -ForegroundColor DarkGray
    
    $confirm = Read-Host "      Usunąć? (T/n/s=skip all)"
    if ($confirm -eq 's') { 
        Write-Host "      ⏭️  Pominięto resztę małych folderów" -ForegroundColor Cyan
        break 
    }
    if ($confirm -ne 'n') {
        try {
            Remove-Item $small.Path -Force -Recurse -ErrorAction Stop
            $freedSpace += $small.SizeMB
            Write-Host "      ✅ Usunięto ($($small.SizeMB) MB)" -ForegroundColor Green
            $cleaned += "Śmieć Program Files: $($small.Name) ($($small.SizeMB) MB)"
        } catch {
            Write-Host "      ⚠️  Błąd: $_" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
# CZĘŚĆ 3: PROGRAMDATA - Śmieci
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Yellow
Write-Host "📦 CZĘŚĆ 2: PROGRAMDATA" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n3️⃣  Szukam śmieci w ProgramData..." -ForegroundColor Cyan

$programData = "C:\ProgramData"
$pdDirs = @()

# Lista znanych bezpiecznych folderów (nie usuwać)
$safeList = @(
    "Microsoft", "Package Cache", "Packages", "Windows", "Application Data",
    "Desktop", "Documents", "Favorites", "Start Menu", "Templates",
    "Intel", "NVIDIA", "AMD", "ssh", "Docker", "Git", "GitHub CLI",
    "chocolatey", "npm", "pip", "Python", "Anaconda"
)

Get-ChildItem $programData -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $folder = $_
    
    # Pomiń bezpieczne foldery
    if ($safeList -contains $folder.Name) { return }
    
    try {
        $items = Get-ChildItem $folder.FullName -Recurse -Force -File -ErrorAction SilentlyContinue
        $size = ($items | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        
        if ($null -eq $size) { $size = 0 }
        $sizeMB = [math]::Round($size / 1MB, 2)
        
        # Sprawdź czy program jest zainstalowany
        $programExists = $false
        foreach ($progDir in $programDirs) {
            if (Test-Path "$progDir\$($folder.Name)") {
                $programExists = $true
                break
            }
        }
        
        if (-not $programExists -and $sizeMB -gt 0.1) {
            $pdDirs += [PSCustomObject]@{
                Path = $folder.FullName
                Name = $folder.Name
                SizeMB = $sizeMB
                FileCount = $items.Count
            }
        }
    } catch {
        # Pomiń foldery bez dostępu
    }
}

Write-Host "   Znaleziono $($pdDirs.Count) podejrzanych folderów`n" -ForegroundColor Cyan

foreach ($pd in $pdDirs | Sort-Object SizeMB -Descending) {
    Write-Host "   ❌ $($pd.Name) ($($pd.SizeMB) MB, $($pd.FileCount) plików)" -ForegroundColor Gray
    
    $confirm = Read-Host "      Usunąć? (T/n/s=skip all)"
    if ($confirm -eq 's') {
        Write-Host "      ⏭️  Pominięto resztę ProgramData" -ForegroundColor Cyan
        break
    }
    if ($confirm -ne 'n') {
        try {
            Remove-Item $pd.Path -Force -Recurse -ErrorAction Stop
            $freedSpace += $pd.SizeMB
            Write-Host "      ✅ Usunięto ($($pd.SizeMB) MB)" -ForegroundColor Green
            $cleaned += "Śmieć ProgramData: $($pd.Name) ($($pd.SizeMB) MB)"
        } catch {
            Write-Host "      ⚠️  Błąd: $_" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
# CZĘŚĆ 4: APPDATA - Śmieci dla nieistniejących programów
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Yellow
Write-Host "👤 CZĘŚĆ 3: APPDATA" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n4️⃣  Szukam śmieci w AppData..." -ForegroundColor Cyan

$appDataDirs = @(
    "$env:LOCALAPPDATA",
    "$env:APPDATA"
)

$safeAppData = @(
    "Microsoft", "Google", "Adobe", "Dropbox", "NVIDIA", "Intel",
    "Temp", "Programs", "Packages", "ConnectedDevicesPlatform",
    "Docker", "Git", "GitHub", "npm", "pip", "PowerShell"
)

$appDataJunk = @()

foreach ($appData in $appDataDirs) {
    Get-ChildItem $appData -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $folder = $_
        
        # Pomiń bezpieczne
        if ($safeAppData -contains $folder.Name) { return }
        
        try {
            $items = Get-ChildItem $folder.FullName -Recurse -Force -File -ErrorAction SilentlyContinue
            $size = ($items | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
            
            if ($null -eq $size) { $size = 0 }
            $sizeMB = [math]::Round($size / 1MB, 2)
            
            # Sprawdź czy program istnieje
            $programExists = $false
            foreach ($progDir in $programDirs) {
                if (Test-Path "$progDir\$($folder.Name)") {
                    $programExists = $true
                    break
                }
            }
            
            # Sprawdź czy folder w ProgramData
            if (Test-Path "$programData\$($folder.Name)") {
                $programExists = $true
            }
            
            if (-not $programExists -and $sizeMB -gt 5) {  # Większe niż 5MB
                $appDataJunk += [PSCustomObject]@{
                    Path = $folder.FullName
                    Name = $folder.Name
                    Location = if ($appData -like "*Local*") { "Local" } else { "Roaming" }
                    SizeMB = $sizeMB
                    FileCount = $items.Count
                }
            }
        } catch {
            # Pomiń foldery bez dostępu
        }
    }
}

Write-Host "   Znaleziono $($appDataJunk.Count) dużych folderów bez programu (>5MB)`n" -ForegroundColor Cyan

foreach ($junk in $appDataJunk | Sort-Object SizeMB -Descending | Select-Object -First 20) {
    Write-Host "   ❌ $($junk.Name) [$($junk.Location)] ($($junk.SizeMB) MB, $($junk.FileCount) plików)" -ForegroundColor Gray
    
    $confirm = Read-Host "      Usunąć? (T/n/s=skip all)"
    if ($confirm -eq 's') { 
        Write-Host "      ⏭️  Pominięto resztę AppData" -ForegroundColor Cyan
        break 
    }
    if ($confirm -ne 'n') {
        try {
            Remove-Item $junk.Path -Force -Recurse -ErrorAction Stop
            $freedSpace += $junk.SizeMB
            Write-Host "      ✅ Usunięto ($($junk.SizeMB) MB)" -ForegroundColor Green
            $cleaned += "Śmieć AppData: $($junk.Name) ($($junk.SizeMB) MB)"
        } catch {
            Write-Host "      ⚠️  Błąd: $_" -ForegroundColor Yellow
        }
    }
}

# ============================================================================
# CZĘŚĆ 5: REJESTR - Osierocone wpisy
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Yellow
Write-Host "📝 CZĘŚĆ 4: REJESTR" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n5️⃣  Czyszczę osierocone wpisy rejestru..." -ForegroundColor Cyan

$uninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$orphaned = 0

foreach ($keyPath in $uninstallKeys) {
    Get-ChildItem $keyPath -ErrorAction SilentlyContinue | ForEach-Object {
        $props = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue
        
        if ($props.InstallLocation -and -not (Test-Path $props.InstallLocation)) {
            Write-Host "   ❌ $($props.DisplayName)" -ForegroundColor Gray
            Write-Host "      → $($props.InstallLocation)" -ForegroundColor DarkGray
            
            try {
                Remove-Item $_.PSPath -Force -Recurse
                Write-Host "      ✅ Usunięto z rejestru" -ForegroundColor Green
                $orphaned++
                $cleaned += "Rejestr: $($props.DisplayName)"
            } catch {
                Write-Host "      ⚠️  Błąd: $_" -ForegroundColor Yellow
            }
        }
    }
}

if ($orphaned -gt 0) {
    Write-Host "`n   ✅ Usunięto $orphaned osieroconych wpisów" -ForegroundColor Green
}

# ============================================================================
# PODSUMOWANIE
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE DEEP CLEANUP" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Cyan

Write-Host "`n🧹 Wyczyszczono: $($cleaned.Count) elementów" -ForegroundColor Green
Write-Host "💾 Zwolniono: $([math]::Round($freedSpace, 2)) MB ($([math]::Round($freedSpace/1024, 2)) GB)" -ForegroundColor Cyan

if ($cleaned.Count -gt 0) {
    Write-Host "`n📋 Szczegóły:" -ForegroundColor Yellow
    foreach ($item in $cleaned) {
        Write-Host "   • $item" -ForegroundColor White
    }
}

# Zapisz raport
$reportDir = "C:\myAI_System\reports\cleanup"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$reportPath = Join-Path $reportDir "deep-cleanup-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    CleanedCount = $cleaned.Count
    FreedSpaceMB = [math]::Round($freedSpace, 2)
    FreedSpaceGB = [math]::Round($freedSpace/1024, 2)
    Items = $cleaned
}

$report | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding UTF8
Write-Host "`n💾 Raport zapisany: $reportPath" -ForegroundColor Cyan

Write-Host "`n✅ Deep cleanup zakończony!`n" -ForegroundColor Green
