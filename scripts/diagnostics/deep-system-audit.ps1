# ============================================================================
# DEEP SYSTEM AUDIT - Kompleksowy audyt uprawnień i pozostałości
# ============================================================================

Write-Host "`n🔍 DEEP SYSTEM AUDIT - Szczegółowa analiza`n" -ForegroundColor Cyan

$issues = @()
$warnings = @()

# ============================================================================
# CZĘŚĆ 1: UPRAWNIENIA WINDOWS - SYSTEM PLIKÓW
# ============================================================================

Write-Host "="*80 -ForegroundColor Yellow
Write-Host "📁 CZĘŚĆ 1: UPRAWNIENIA SYSTEMU PLIKÓW" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

# Sprawdź uprawnienia do kluczowych folderów
$userProfileRoot = $env:USERPROFILE
$criticalPaths = @(
    "C:\myAI_System",
    "D:\myai",
    (Join-Path $userProfileRoot "Documents"),
    (Join-Path $userProfileRoot "Desktop"),
    $env:LOCALAPPDATA,
    $env:APPDATA
)

Write-Host "`n1️⃣  Sprawdzam uprawnienia do kluczowych folderów..." -ForegroundColor Cyan

foreach ($path in $criticalPaths) {
    if (Test-Path $path) {
        try {
            $acl = Get-Acl $path
            
            # Sprawdź czy user ma pełne uprawnienia
            $hasFullControl = $false
            foreach ($access in $acl.Access) {
                if ($access.IdentityReference -like "*$env:USERNAME*" -and 
                    $access.FileSystemRights -match "FullControl|Modify") {
                    $hasFullControl = $true
                    break
                }
            }
            
            if ($hasFullControl) {
                Write-Host "   ✅ $path" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  $path - Ograniczone uprawnienia" -ForegroundColor Yellow
                $warnings += "Ograniczone uprawnienia: $path"
            }
        } catch {
            Write-Host "   ❌ $path - Błąd sprawdzania: $_" -ForegroundColor Red
            $issues += "Błąd uprawnień: $path"
        }
    } else {
        Write-Host "   ⚠️  $path - Nie istnieje" -ForegroundColor Gray
    }
}

# Sprawdź czy są pliki z innymi właścicielami
Write-Host "`n2️⃣  Sprawdzam właścicieli plików w C:\myAI_System..." -ForegroundColor Cyan

$currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$foreignFiles = @()

Get-ChildItem "C:\myAI_System" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $acl = Get-Acl $_.FullName
        $owner = $acl.Owner
        
        # Sprawdź czy właściciel to nie current user
        if ($owner -notlike "*$env:USERNAME*" -and $owner -notlike "*Administrators*" -and $owner -notlike "*SYSTEM*") {
            $foreignFiles += [PSCustomObject]@{
                Path = $_.FullName
                Owner = $owner
                Size = $_.Length
            }
        }
    } catch {}
}

if ($foreignFiles.Count -gt 0) {
    Write-Host "   ⚠️  Znaleziono $($foreignFiles.Count) plików z obcymi właścicielami:" -ForegroundColor Yellow
    $foreignFiles | Select-Object -First 10 | ForEach-Object {
        Write-Host "      $($_.Path) (właściciel: $($_.Owner))" -ForegroundColor Gray
    }
    $warnings += "Pliki z obcymi właścicielami: $($foreignFiles.Count)"
} else {
    Write-Host "   ✅ Wszystkie pliki należą do właściwych użytkowników" -ForegroundColor Green
}

# ============================================================================
# CZĘŚĆ 2: POZOSTAŁOŚCI PO STARYCH KONTACH
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Yellow
Write-Host "👤 CZĘŚĆ 2: POZOSTAŁOŚCI PO STARYCH KONTACH" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n3️⃣  Sprawdzam Credential Manager..." -ForegroundColor Cyan

try {
    $creds = cmdkey /list
    $oldAccounts = $creds | Select-String -Pattern "office@oxygenup|myzabka"
    
    if ($oldAccounts) {
        Write-Host "   ⚠️  Znaleziono zapisane dane logowania dla starych kont:" -ForegroundColor Yellow
        $oldAccounts | ForEach-Object {
            Write-Host "      $_" -ForegroundColor Gray
        }
        $issues += "Stare dane w Credential Manager: office@oxygenup lub myzabka"
        Write-Host "`n   💡 Usuń je komendą: cmdkey /delete:<target>" -ForegroundColor Cyan
    } else {
        Write-Host "   ✅ Brak zapisanych danych dla starych kont" -ForegroundColor Green
    }
} catch {
    Write-Host "   ⚠️  Nie można sprawdzić Credential Manager" -ForegroundColor Yellow
}

Write-Host "`n4️⃣  Sprawdzam profile Outlook..." -ForegroundColor Cyan

if (Test-Path "HKCU:\Software\Microsoft\Office") {
    $oldOutlook = Get-ChildItem "HKCU:\Software\Microsoft\Office\*\Outlook\Profiles" -Recurse -ErrorAction SilentlyContinue | 
                  Where-Object { $_.Property -match "office@oxygenup|myzabka" }
    
    if ($oldOutlook) {
        Write-Host "   ⚠️  Znaleziono stare profile Outlook" -ForegroundColor Yellow
        $warnings += "Stare profile Outlook"
    } else {
        Write-Host "   ✅ Brak starych profili Outlook" -ForegroundColor Green
    }
} else {
    Write-Host "   ℹ️  Office nie zainstalowany lub brak profili" -ForegroundColor Gray
}

# ============================================================================
# CZĘŚĆ 3: POZOSTAŁOŚCI PO PROGRAMACH
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Yellow
Write-Host "🗑️  CZĘŚĆ 3: POZOSTAŁOŚCI PO PROGRAMACH" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n5️⃣  Sprawdzam puste foldery w Program Files..." -ForegroundColor Cyan

$emptyDirs = @()
$programDirs = @(
    "C:\Program Files",
    "C:\Program Files (x86)"
)

foreach ($dir in $programDirs) {
    Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $items = Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue
        if ($items.Count -eq 0) {
            $emptyDirs += $_.FullName
        }
    }
}

if ($emptyDirs.Count -gt 0) {
    Write-Host "   ⚠️  Znaleziono $($emptyDirs.Count) pustych folderów:" -ForegroundColor Yellow
    $emptyDirs | Select-Object -First 10 | ForEach-Object {
        Write-Host "      $_" -ForegroundColor Gray
    }
    $warnings += "Puste foldery w Program Files: $($emptyDirs.Count)"
} else {
    Write-Host "   ✅ Brak pustych folderów" -ForegroundColor Green
}

Write-Host "`n6️⃣  Sprawdzam AppData dla nieistniejących programów..." -ForegroundColor Cyan

$appDataDirs = @(
    "$env:LOCALAPPDATA",
    "$env:APPDATA"
)

$suspiciousDirs = @()
$commonLegacy = @("Adobe", "Microsoft", "Google", "Dropbox", "NVIDIA", "Intel")

foreach ($appData in $appDataDirs) {
    Get-ChildItem $appData -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $dirName = $_.Name
        
        # Pomiń znane foldery systemowe
        if ($commonLegacy -contains $dirName) { return }
        if ($dirName -match "^(Temp|History|Cache|Cookies)$") { return }
        
        # Sprawdź czy program jest zainstalowany
        $programExists = $false
        foreach ($progDir in $programDirs) {
            if (Test-Path "$progDir\$dirName") {
                $programExists = $true
                break
            }
        }
        
        if (-not $programExists) {
            $size = (Get-ChildItem $_.FullName -Recurse -ErrorAction SilentlyContinue | 
                     Measure-Object -Property Length -Sum).Sum / 1MB
            
            if ($size -gt 0.1) {  # Większe niż 100KB
                $suspiciousDirs += [PSCustomObject]@{
                    Path = $_.FullName
                    SizeMB = [math]::Round($size, 2)
                }
            }
        }
    }
}

if ($suspiciousDirs.Count -gt 0) {
    Write-Host "   ⚠️  Znaleziono $($suspiciousDirs.Count) podejrzanych folderów w AppData:" -ForegroundColor Yellow
    $suspiciousDirs | Sort-Object SizeMB -Descending | Select-Object -First 10 | ForEach-Object {
        Write-Host "      $($_.Path) ($($_.SizeMB) MB)" -ForegroundColor Gray
    }
    $warnings += "Podejrzane foldery AppData: $($suspiciousDirs.Count)"
} else {
    Write-Host "   ✅ AppData wygląda czysto" -ForegroundColor Green
}

Write-Host "`n7️⃣  Sprawdzam klucze rejestru po odinstalowanych programach..." -ForegroundColor Cyan

$uninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$orphanedKeys = @()

foreach ($keyPath in $uninstallKeys) {
    Get-ItemProperty $keyPath -ErrorAction SilentlyContinue | ForEach-Object {
        $installLocation = $_.InstallLocation

        $installLocationExists = $false
        if ($installLocation) {
            try {
                $installLocationExists = Test-Path -LiteralPath $installLocation -ErrorAction Stop
            } catch {
                $installLocationExists = $false
            }
        }

        if ($installLocation -and -not $installLocationExists) {
            $orphanedKeys += [PSCustomObject]@{
                DisplayName = $_.DisplayName
                InstallLocation = $installLocation
            }
        }
    }
}

if ($orphanedKeys.Count -gt 0) {
    Write-Host "   ⚠️  Znaleziono $($orphanedKeys.Count) osieroconych wpisów rejestru:" -ForegroundColor Yellow
    $orphanedKeys | Select-Object -First 10 | ForEach-Object {
        Write-Host "      $($_.DisplayName) → $($_.InstallLocation)" -ForegroundColor Gray
    }
    $warnings += "Osierocone wpisy rejestru: $($orphanedKeys.Count)"
} else {
    Write-Host "   ✅ Brak osieroconych wpisów" -ForegroundColor Green
}

# ============================================================================
# CZĘŚĆ 4: SPRAWDZENIE USŁUG I DRIVERS
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Yellow
Write-Host "⚙️  CZĘŚĆ 4: USŁUGI I STEROWNIKI" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Yellow

Write-Host "`n8️⃣  Sprawdzam usługi z nieistniejącymi plikami wykonywalnymi..." -ForegroundColor Cyan

$brokenServices = @()

Get-Service -ErrorAction SilentlyContinue | ForEach-Object {
    try {
        $service = Get-WmiObject -Class Win32_Service -Filter "Name='$($_.Name)'" -ErrorAction SilentlyContinue
        if ($service -and $service.PathName) {
            # Wyciągnij ścieżkę (bez parametrów)
            $exePath = ($service.PathName -split '"')[1]
            if (-not $exePath) { $exePath = ($service.PathName -split ' ')[0] }
            
            if ($exePath -and -not (Test-Path $exePath)) {
                $brokenServices += [PSCustomObject]@{
                    Name = $_.Name
                    DisplayName = $_.DisplayName
                    Path = $exePath
                    Status = $_.Status
                }
            }
        }
    } catch {}
}

if ($brokenServices.Count -gt 0) {
    Write-Host "   ⚠️  Znaleziono $($brokenServices.Count) usług z nieistniejącymi plikami:" -ForegroundColor Yellow
    $brokenServices | Select-Object -First 10 | ForEach-Object {
        Write-Host "      $($_.DisplayName) ($($_.Status))" -ForegroundColor Gray
        Write-Host "         → $($_.Path)" -ForegroundColor DarkGray
    }
    $warnings += "Usługi z nieistniejącymi plikami: $($brokenServices.Count)"
} else {
    Write-Host "   ✅ Wszystkie usługi mają poprawne ścieżki" -ForegroundColor Green
}

# ============================================================================
# PODSUMOWANIE
# ============================================================================

Write-Host "`n"
Write-Host "="*80 -ForegroundColor Cyan
Write-Host "📊 PODSUMOWANIE AUDYTU" -ForegroundColor Yellow
Write-Host "="*80 -ForegroundColor Cyan

Write-Host "`n🔴 KRYTYCZNE PROBLEMY: $($issues.Count)" -ForegroundColor Red
if ($issues.Count -gt 0) {
    $issues | ForEach-Object { Write-Host "   • $_" -ForegroundColor Red }
}

Write-Host "`n⚠️  OSTRZEŻENIA: $($warnings.Count)" -ForegroundColor Yellow
if ($warnings.Count -gt 0) {
    $warnings | ForEach-Object { Write-Host "   • $_" -ForegroundColor Yellow }
}

if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "`n✅ System czysty! Brak problemów." -ForegroundColor Green
}

# Zapisz raport
$reportDir = "C:\myAI_System\reports\permissions"
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$reportPath = Join-Path $reportDir "system-audit-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
$report = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Issues = $issues
    Warnings = $warnings
    Details = @{
        ForeignFiles = $foreignFiles.Count
        EmptyDirs = $emptyDirs.Count
        SuspiciousDirs = $suspiciousDirs.Count
        OrphanedKeys = $orphanedKeys.Count
        BrokenServices = $brokenServices.Count
    }
}

$report | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding UTF8
Write-Host "`n💾 Raport zapisany: $reportPath" -ForegroundColor Cyan

Write-Host "`n✅ Audyt zakończony!`n" -ForegroundColor Green
