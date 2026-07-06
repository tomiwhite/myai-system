# ============================================================================
# QUICK PERMISSIONS CHECK (bez admin)
# ============================================================================

$ErrorActionPreference = "Continue"

$recommendedGitEmail = "45501831+tomiwhite@users.noreply.github.com"

function Get-EnvSyncSettings {
    $settings = @{
        GoogleDriveEnvPath = "G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env"
        GoogleDriveEnvPathEnvVar = "MYAI_GDRIVE_ENV"
    }

    $configPath = "C:\myAI_System\config\system-config.json"
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            if ($config.environment.googleDriveEnvPath) {
                $settings.GoogleDriveEnvPath = $config.environment.googleDriveEnvPath
            }
            if ($config.environment.googleDriveEnvPathEnvVar) {
                $settings.GoogleDriveEnvPathEnvVar = $config.environment.googleDriveEnvPathEnvVar
            }
        } catch {}
    }

    $overrideVarName = $settings.GoogleDriveEnvPathEnvVar
    if ($overrideVarName) {
        $overrideValue = [Environment]::GetEnvironmentVariable($overrideVarName, "Process")
        if (-not $overrideValue) {
            $overrideValue = [Environment]::GetEnvironmentVariable($overrideVarName, "User")
        }
        if (-not $overrideValue) {
            $overrideValue = [Environment]::GetEnvironmentVariable($overrideVarName, "Machine")
        }

        if ($overrideValue) {
            $settings.GoogleDriveEnvPath = $overrideValue
        }
    }

    return $settings
}

Write-Host "`n🔍 SZYBKIE SPRAWDZENIE UPRAWNIEŃ I KONFIGURACJI" -ForegroundColor Cyan
Write-Host "="*80 -ForegroundColor Cyan

# 1. Git Config
Write-Host "`n1️⃣  GIT CONFIGURATION:" -ForegroundColor Yellow
$gitUser = git config --global user.name 2>$null
$gitEmail = git config --global user.email 2>$null
Write-Host "  User:  $gitUser" -ForegroundColor White
Write-Host "  Email: $gitEmail" -ForegroundColor White

if (-not $gitEmail) {
    Write-Host "  ⚠️  Brak Git email w konfiguracji globalnej" -ForegroundColor Red
    Write-Host "  Komenda: git config --global user.email '$recommendedGitEmail'" -ForegroundColor Cyan
} elseif ($gitEmail -notmatch "@users\.noreply\.github\.com$") {
    Write-Host "  ⚠️  Email powinien byc GitHub noreply: $recommendedGitEmail" -ForegroundColor Red
    Write-Host "  Komenda: git config --global user.email '$recommendedGitEmail'" -ForegroundColor Cyan
} else {
    Write-Host "  ✅ Email OK (GitHub noreply)" -ForegroundColor Green
}

# 2. PowerShell Version
Write-Host "`n2️⃣  POWERSHELL:" -ForegroundColor Yellow
Write-Host "  Wersja: $($PSVersionTable.PSVersion)" -ForegroundColor White
Write-Host "  Edycja: $($PSVersionTable.PSEdition)" -ForegroundColor White

# 3. .NET SDK
Write-Host "`n3️⃣  .NET SDK:" -ForegroundColor Yellow
$dotnetVersion = dotnet --version 2>$null
if ($dotnetVersion) {
    Write-Host "  ✅ Zainstalowany: $dotnetVersion" -ForegroundColor Green
} else {
    Write-Host "  ❌ Nie znaleziony w PATH" -ForegroundColor Red
}

# 4. GitHub Desktop
Write-Host "`n4️⃣  GITHUB DESKTOP:" -ForegroundColor Yellow
$ghDesktop = Join-Path $env:USERPROFILE "AppData\Local\GitHubDesktop\GitHubDesktop.exe"
if (Test-Path $ghDesktop) {
    Write-Host "  ✅ Zainstalowany: $ghDesktop" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Nie znaleziony w standardowej lokalizacji" -ForegroundColor Yellow
}

# 5. Martwe linki na pulpicie
Write-Host "`n5️⃣  SKRÓTY NA PULPICIE:" -ForegroundColor Yellow
$desktop = [Environment]::GetFolderPath("Desktop")
$shortcuts = Get-ChildItem $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue
$deadCount = 0

foreach ($shortcut in $shortcuts) {
    try {
        $shell = New-Object -ComObject WScript.Shell
        $link = $shell.CreateShortcut($shortcut.FullName)
        $target = $link.TargetPath
        
        if ($target -and -not (Test-Path $target)) {
            Write-Host "  ❌ $($shortcut.Name) → MARTWY ($target)" -ForegroundColor Red
            $deadCount++
        }
        
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    } catch {}
}

if ($deadCount -eq 0) {
    Write-Host "  ✅ Wszystkie linki działają" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  Znaleziono $deadCount martwych linków" -ForegroundColor Yellow
}

# 6. C:\myAI_System dostęp
Write-Host "`n6️⃣  C:\myAI_System:" -ForegroundColor Yellow
try {
    $testFile = "C:\myAI_System\.permission-test"
    "test" | Out-File $testFile -Force 2>$null
    Remove-Item $testFile -Force 2>$null
    Write-Host "  ✅ Masz dostęp do zapisu" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Brak dostępu do zapisu!" -ForegroundColor Red
}

# 7. D:\myai dostęp
Write-Host "`n7️⃣  D:\myai:" -ForegroundColor Yellow
if (Test-Path "D:\myai") {
    try {
        $testFile = "D:\myai\.permission-test"
        "test" | Out-File $testFile -Force 2>$null
        Remove-Item $testFile -Force 2>$null
        Write-Host "  ✅ Masz dostęp do zapisu" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Brak dostępu do zapisu!" -ForegroundColor Red
    }
} else {
    Write-Host "  ⚠️  Katalog nie istnieje" -ForegroundColor Yellow
}

# 8. .env files
Write-Host "`n8️⃣  .ENV FILES:" -ForegroundColor Yellow
if (Test-Path "C:\myai\.env") {
    $env = Get-Item "C:\myai\.env"
    Write-Host "  ✅ C:\myai\.env ($($env.Length) bajtów)" -ForegroundColor Green
    if ($env.IsReadOnly) {
        Write-Host "     Read-only: ✅" -ForegroundColor Green
    } else {
        Write-Host "     Read-only: ⚠️  NIE" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ❌ C:\myai\.env BRAK!" -ForegroundColor Red
}

if (Test-Path "D:\myai\.env") {
    Write-Host "  ✅ D:\myai\.env" -ForegroundColor Green
} else {
    Write-Host "  ⚠️  D:\myai\.env brak (OK jeśli nie utworzony)" -ForegroundColor Yellow
}

# 9. Google Drive
Write-Host "`n9️⃣  GOOGLE DRIVE .env:" -ForegroundColor Yellow
$gdrive = (Get-EnvSyncSettings).GoogleDriveEnvPath
if (Test-Path $gdrive) {
    $gd = Get-Item $gdrive
    Write-Host "  ✅ Dostępny ($($gd.Length) bajtów)" -ForegroundColor Green
} else {
    Write-Host "  ❌ Niedostępny!" -ForegroundColor Red
    Write-Host "     Ścieżka: $gdrive" -ForegroundColor Gray
}

# 10. Execution Policy
Write-Host "`n🔟 EXECUTION POLICY:" -ForegroundColor Yellow
$policy = Get-ExecutionPolicy -Scope CurrentUser
Write-Host "  CurrentUser: $policy" -ForegroundColor White
if ($policy -eq "Restricted") {
    Write-Host "  ⚠️  RESTRICTED może blokować skrypty!" -ForegroundColor Yellow
    Write-Host "  Komenda: Set-ExecutionPolicy -Scope CurrentUser RemoteSigned" -ForegroundColor Cyan
}

# Podsumowanie
Write-Host "`n" -NoNewline
Write-Host "="*80 -ForegroundColor Cyan
Write-Host "💡 PODSUMOWANIE:" -ForegroundColor Yellow

if (-not $gitEmail -or $gitEmail -notmatch "@users\.noreply\.github\.com$") {
    Write-Host "  🔴 PILNE: Ustaw Git email na $recommendedGitEmail" -ForegroundColor Red
}

if ($deadCount -gt 0) {
    Write-Host "  🟡 Usuń $deadCount martwych linków z pulpitu" -ForegroundColor Yellow
}

Write-Host "`n✅ Sprawdzenie zakończone`n" -ForegroundColor Green
