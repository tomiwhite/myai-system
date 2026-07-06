# ============================================================================
# ONE-CLICK STARTER - myAI System (C:\)
# ============================================================================
# 
# Ten skrypt uruchamia środowisko C:\myAI_System w VS Code
# Sprawdza zależności, synchronizuje .env, i otwiera workspace
#
# Użycie: Podwójne kliknięcie ikony na pulpicie
# ============================================================================

$ErrorActionPreference = "Stop"

# Kolory
function Write-Header { 
    Write-Host "`n" -NoNewline
    Write-Host "="*80 -ForegroundColor Cyan
    Write-Host " $args" -ForegroundColor Yellow
    Write-Host "="*80 -ForegroundColor Cyan
}
function Write-Success { Write-Host "  ✅ $args" -ForegroundColor Green }
function Write-Info { Write-Host "  ℹ️  $args" -ForegroundColor Cyan }
function Write-Warning { Write-Host "  ⚠️  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "  ❌ $args" -ForegroundColor Red }
function Write-Step { Write-Host "`n🔹 $args" -ForegroundColor Magenta }

function Get-EnvSyncSettings {
    $settings = @{
        MasterEnvPath = "C:\myai\.env"
        GoogleDriveEnvPath = "G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env"
        GoogleDriveEnvPathEnvVar = "MYAI_GDRIVE_ENV"
    }

    $configPath = "C:\myAI_System\config\system-config.json"
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            if ($config.environment.masterEnvPath) {
                $settings.MasterEnvPath = $config.environment.masterEnvPath
            }
            if ($config.environment.googleDriveEnvPath) {
                $settings.GoogleDriveEnvPath = $config.environment.googleDriveEnvPath
            }
            if ($config.environment.googleDriveEnvPathEnvVar) {
                $settings.GoogleDriveEnvPathEnvVar = $config.environment.googleDriveEnvPathEnvVar
            }
        } catch {
            Write-Warning "Nie udało się odczytać config/system-config.json - używam wartości domyślnych"
        }
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

function Get-BuiltInVSCodeExtensions {
    $builtInExtensions = @()

    try {
        $codeCommand = Get-Command code -ErrorAction Stop
        $codeBinPath = Split-Path $codeCommand.Source -Parent
        $codeInstallRoot = Split-Path $codeBinPath -Parent
        $packageFiles = Get-ChildItem -Path $codeInstallRoot -Recurse -Filter "package.json" -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -like "*resources\app\extensions\*" }

        foreach ($packageFile in $packageFiles) {
            try {
                $packageJson = Get-Content $packageFile.FullName -Raw | ConvertFrom-Json
                if ($packageJson.name) {
                    $builtInExtensions += $packageJson.name.ToString().Trim().ToLowerInvariant()
                }
            } catch {
                continue
            }
        }
    } catch {
        return @()
    }

    return @($builtInExtensions | Select-Object -Unique)
}

function Get-InstalledVSCodeExtensions {
    try {
        $cliExtensions = @(
            (& code --list-extensions 2>$null) |
                Where-Object { $_ } |
                ForEach-Object { $_.ToString().Trim().ToLowerInvariant() }
        )

        return @(
            ($cliExtensions + (Get-BuiltInVSCodeExtensions)) |
                Select-Object -Unique
        )
    } catch {
        return @()
    }
}

function Test-VSCodeExtensionAvailable {
    param(
        [string]$ExtensionId,
        [string[]]$AvailableExtensions
    )

    $normalizedId = $ExtensionId.ToLowerInvariant()
    $candidateIds = @($normalizedId)

    switch ($normalizedId) {
        "github.copilot" { $candidateIds += "copilot-chat" }
        "github.copilot-chat" { $candidateIds += "copilot-chat" }
    }

    foreach ($candidateId in $candidateIds | Select-Object -Unique) {
        if ($AvailableExtensions -contains $candidateId) {
            return $true
        }
    }

    return $false
}

Clear-Host

Write-Header "🚀 ONE-CLICK STARTER - myAI System (C:\myAI_System)"

Write-Info "Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info "Użytkownik: $env:USERNAME"
Write-Info "Workspace: C:\myAI_System"

# ============================================================================
# KROK 1: Sprawdź strukturę katalogów
# ============================================================================
Write-Step "Sprawdzanie struktury katalogów..."

$required_dirs = @(
    "C:\myAI_System\agents",
    "C:\myAI_System\reports",
    "C:\myAI_System\backups",
    "C:\myAI_System\scripts",
    "C:\myAI_System\config",
    "C:\myAI_System\logs",
    "C:\myAI_System\docs"
)

$missing_dirs = @()
foreach ($dir in $required_dirs) {
    if (Test-Path $dir) {
        Write-Success "$(Split-Path $dir -Leaf)"
    } else {
        $missing_dirs += $dir
        Write-Warning "Brak: $(Split-Path $dir -Leaf) - tworzę..."
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
}

if ($missing_dirs.Count -eq 0) {
    Write-Success "Wszystkie katalogi na miejscu"
}

# ============================================================================
# KROK 2: Sprawdź .env (MASTER)
# ============================================================================
Write-Step "Sprawdzanie .env (MASTER)..."

$envSyncSettings = Get-EnvSyncSettings
$master_env = $envSyncSettings.MasterEnvPath
$gdrive_env = $envSyncSettings.GoogleDriveEnvPath

if (Test-Path $master_env) {
    $env_size = (Get-Item $master_env).Length
    $env_date = (Get-Item $master_env).LastWriteTime
    Write-Success "MASTER .env istnieje ($env_size bajtów)"
    Write-Info "Ostatnia modyfikacja: $env_date"
    
    # Sprawdź czy potrzeba sync z Google Drive
    if (Test-Path $gdrive_env) {
        $gdrive_date = (Get-Item $gdrive_env).LastWriteTime
        if ($gdrive_date -gt $env_date) {
            Write-Warning "Google Drive ma nowszą wersję!"
            Write-Info "Synchronizuję z Google Drive..."
            & "C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1" -Force
        }
    }
} else {
    Write-Warning "MASTER .env nie istnieje"
    if (Test-Path $gdrive_env) {
        Write-Info "Synchronizuję z Google Drive..."
        & "C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1"
    } else {
        Write-Error "Brak pliku .env w Google Drive!"
        Write-Info "Utwórz plik: $gdrive_env"
        Write-Info "Lub skopiuj template: C:\myAI_System\templates\.env.master.template"
    }
}

# ============================================================================
# KROK 3: Sprawdź VS Code
# ============================================================================
Write-Step "Sprawdzanie VS Code..."

$vscode_path = Get-Command code -ErrorAction SilentlyContinue
if ($vscode_path) {
    Write-Success "VS Code zainstalowany: $($vscode_path.Source)"
} else {
    Write-Error "VS Code nie znaleziony!"
    Write-Info "Zainstaluj z: https://code.visualstudio.com/"
    Write-Host "`nNaciśnij Enter aby kontynuować..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

# ============================================================================
# KROK 4: Sprawdź rozszerzenia VS Code
# ============================================================================
Write-Step "Sprawdzanie rozszerzeń VS Code..."

$required_extensions = @(
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-vscode.powershell",
    "github.copilot",
    "github.copilot-chat"
)

$installed_extensions = Get-InstalledVSCodeExtensions
$missing_extensions = @()

foreach ($ext in $required_extensions) {
    if (Test-VSCodeExtensionAvailable -ExtensionId $ext -AvailableExtensions $installed_extensions) {
        Write-Success "$ext"
    } else {
        $missing_extensions += $ext
        Write-Warning "Brak rozszerzenia: $ext"
    }
}

if ($missing_extensions.Count -gt 0) {
    Write-Info "Instaluję brakujące rozszerzenia..."
    foreach ($ext in $missing_extensions) {
        Write-Info "Instaluję: $ext"

        $install_output = & code --install-extension $ext --force 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Instalacja nie powiodła się: $ext"
            if ($install_output) {
                Write-Info ($install_output | Select-Object -First 1)
            }
            continue
        }

        $installed_extensions = Get-InstalledVSCodeExtensions
        if (Test-VSCodeExtensionAvailable -ExtensionId $ext -AvailableExtensions $installed_extensions) {
            Write-Success "Zainstalowano: $ext"
        } else {
            Write-Warning "VS Code nie potwierdził instalacji: $ext"
        }
    }

    $remaining_extensions = $required_extensions | Where-Object {
        -not (Test-VSCodeExtensionAvailable -ExtensionId $_ -AvailableExtensions $installed_extensions)
    }

    if ($remaining_extensions.Count -eq 0) {
        Write-Success "Wszystkie wymagane rozszerzenia są dostępne"
    } else {
        Write-Warning "Nadal brakuje: $($remaining_extensions -join ', ')"
    }
}

# ============================================================================
# KROK 5: Sprawdź Python
# ============================================================================
Write-Step "Sprawdzanie Python..."

$python_cmd = Get-Command python -ErrorAction SilentlyContinue
if ($python_cmd) {
    $python_version = & python --version 2>&1
    Write-Success "Python zainstalowany: $python_version"
} else {
    Write-Warning "Python nie znaleziony w PATH"
    Write-Info "Sprawdzam standardowe lokalizacje..."
    
    $python_locations = @(
        "C:\Python313\python.exe",
        "C:\Python314\python.exe",
        "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe"
    )
    
    $found = $false
    foreach ($loc in $python_locations) {
        if (Test-Path $loc) {
            Write-Success "Znaleziono: $loc"
            $found = $true
            break
        }
    }
    
    if (-not $found) {
        Write-Warning "Python nie znaleziony - może być potrzebny dla agentów"
    }
}

# ============================================================================
# KROK 6: Sprawdź Git
# ============================================================================
Write-Step "Sprawdzanie Git..."

$git_cmd = Get-Command git -ErrorAction SilentlyContinue
if ($git_cmd) {
    $git_version = & git --version 2>&1
    Write-Success "Git zainstalowany: $git_version"
} else {
    Write-Warning "Git nie znaleziony - opcjonalny"
}

# ============================================================================
# KROK 7: Walidacja AI_RULES
# ============================================================================
Write-Step "Walidacja AI_RULES..."

$validator = "C:\myAI_System\scripts\validation\validate-naming-rules.ps1"
if (Test-Path $validator) {
    $validationResult = & $validator 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Projekt przestrzega AI_RULES.md"
    } else {
        Write-Warning "Znaleziono problemy z nazewnictwem"
        Write-Info "Uruchom: $validator -Verbose -Fix"
    }
} else {
    Write-Info "Validator nie znaleziony (opcjonalny)"
}

# ============================================================================
# KROK 8: Status ostatniej sesji
# ============================================================================
Write-Step "Status ostatniej sesji..."

# Sprawdź ostatni work-log
$last_worklog = Get-ChildItem "C:\myAI_System\docs\work-logs\" -Filter "*.md" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

if ($last_worklog) {
    Write-Success "Ostatni work-log: $($last_worklog.Name)"
    Write-Info "Data: $($last_worklog.LastWriteTime)"
    
    # Pokaż pierwsze kilka linii
    $content = Get-Content $last_worklog.FullName -First 10
    $title = $content | Where-Object { $_ -match "^# " } | Select-Object -First 1
    if ($title) {
        Write-Info "Temat: $($title -replace '^# ', '')"
    }
}

# Sprawdź ostatnie raporty
$last_report = Get-ChildItem "C:\myAI_System\reports\" -Recurse -Filter "*.json" | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object -First 1

if ($last_report) {
    Write-Info "Ostatni raport: $($last_report.Name) ($($last_report.LastWriteTime))"
}

# ============================================================================
# KROK 9: Bezpieczeństwo systemu (HVCI / sterowniki / cleanup)
# ============================================================================
Write-Step "Bezpieczeństwo systemu (HVCI / sterowniki / cleanup)..."

# Memory Integrity (HVCI)
try {
    $hvciKey = 'HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'
    $hvciEnabled = (Get-ItemProperty -Path $hvciKey -Name Enabled -ErrorAction SilentlyContinue).Enabled
    if ($hvciEnabled -eq 1) {
        Write-Success "Memory Integrity (HVCI): Włączona"
    } elseif ($hvciEnabled -eq 0) {
        Write-Warning "Memory Integrity (HVCI): Wyłączona"
    } else {
        Write-Info "Memory Integrity (HVCI): Nieznany status"
    }
} catch {
    Write-Warning "Nie udało się odczytać statusu HVCI"
}

# EuVKbd sterownik (powinien być usunięty)
$euvkbdPath = "C:\\Windows\\System32\\drivers\\EuVKbd.sys"
if (Test-Path $euvkbdPath) {
    Write-Warning "Wykryto plik EuVKbd.sys (niezgodny sterownik)"
    Write-Info "Uruchom: C:\\myAI_System\\scripts\\diagnostics\\remove-euvkbd-driver.ps1 -Execute"
} else {
    Write-Success "EuVKbd.sys: Nieobecny (OK)"
}

# Ostatni raport cleanup (cleanup-safe-junk-report / orphan-report)
$cleanupReports = @()
if (Test-Path 'C:\\myAI_System\\reports') {
    $cleanupReports = Get-ChildItem 'C:\\myAI_System\\reports' -Recurse -Include 'cleanup-safe-junk-report*.json','orphan-report*.json' -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending
}
if ($cleanupReports -and $cleanupReports.Count -gt 0) {
    $lastCleanup = $cleanupReports | Select-Object -First 1
    Write-Info "Ostatni raport cleanup: $($lastCleanup.Name) ($($lastCleanup.LastWriteTime))"
} else {
    Write-Info "Brak raportów cleanup (opcjonalne)"
}

# ============================================================================
# KROK 10: Otwórz VS Code
# ============================================================================
Write-Step "Uruchamianie VS Code..."

$workspace_file = "C:\myAI_System\myai-system.code-workspace"

# Utwórz workspace file jeśli nie istnieje
if (-not (Test-Path $workspace_file)) {
    Write-Info "Tworzę plik workspace..."
    
    $workspace_content = @{
        "folders" = @(
            @{
                "path" = "C:\myAI_System"
                "name" = "🖥️ myAI System (C:)"
            }
        )
        "settings" = @{
            "files.exclude" = @{
                "**/__pycache__" = $true
                "**/.pytest_cache" = $true
            }
            "terminal.integrated.defaultProfile.windows" = "PowerShell"
        }
    } | ConvertTo-Json -Depth 10
    
    $workspace_content | Out-File -FilePath $workspace_file -Encoding utf8
}

Write-Success "Otwieranie workspace w VS Code..."
Write-Info "Workspace: $workspace_file"

Start-Process "code" -ArgumentList $workspace_file -NoNewWindow

# ============================================================================
# PODSUMOWANIE
# ============================================================================
Write-Header "✅ GOTOWE - VS Code uruchomiony!"

Write-Host "`n📌 Co dalej?" -ForegroundColor Yellow
Write-Host "  1. VS Code otworzył się z workspace C:\myAI_System" -ForegroundColor White
Write-Host "  2. Możesz zacząć pracę z AI Asystentem (Copilot/Windsurf)" -ForegroundColor White
Write-Host "  3. Dokumentacja: C:\myAI_System\docs\" -ForegroundColor White
Write-Host "  4. Quick start: C:\myAI_System\QUICKSTART.md" -ForegroundColor White

Write-Host "`n🔍 Ostatnia sesja:" -ForegroundColor Yellow
if ($last_worklog) {
    Write-Host "  📝 $($last_worklog.Name)" -ForegroundColor White
    Write-Host "  📅 $($last_worklog.LastWriteTime)" -ForegroundColor White
}

Write-Host "`n💡 Przydatne komendy:" -ForegroundColor Yellow
Write-Host "  - Sync .env: C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1" -ForegroundColor Cyan
Write-Host "  - Diagnostyka: C:\myAI_System\scripts\diagnostics\quick-permissions-check.ps1" -ForegroundColor Cyan

Write-Host "`n🚀 Workspace C:\myAI_System gotowy do pracy!" -ForegroundColor Green
Write-Host "="*80 -ForegroundColor Cyan

# Poczekaj 5 sekund przed zamknięciem
Write-Host "`nOkno zamknie się za 5 sekund..." -ForegroundColor Gray
Start-Sleep -Seconds 5
