# ============================================================================
# ONE-CLICK STARTER - myAI Application (D:\)
# ============================================================================
# 
# Ten skrypt uruchamia środowisko D:\myai w VS Code
# Sprawdza Python venv, zależności, .env, i otwiera workspace
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

Write-Header "🚀 ONE-CLICK STARTER - myAI Application (D:\myai)"

Write-Info "Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Info "Użytkownik: $env:USERNAME"
Write-Info "Workspace: D:\myai"

# ============================================================================
# KROK 1: Sprawdź strukturę katalogów
# ============================================================================
Write-Step "Sprawdzanie struktury katalogów..."

if (-not (Test-Path "D:\myai")) {
    Write-Error "Katalog D:\myai nie istnieje!"
    Write-Info "Utwórz go najpierw lub zmień lokalizację projektu"
    Write-Host "`nNaciśnij Enter aby zamknąć..." -ForegroundColor Yellow
    Read-Host
    exit 1
}

$required_dirs = @(
    "D:\myai\agents",
    "D:\myai\shared",
    "D:\myai\evaluation",
    "D:\myai\tracing",
    "D:\myai\data",
    "D:\myai\logs",
    "D:\myai\docs"
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
# KROK 1.5: Bezpieczeństwo systemu (HVCI / sterowniki)
# ============================================================================
Write-Step "Bezpieczeństwo systemu (HVCI / sterowniki)..."

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
    Write-Warning "Wykryto plik EuVKbd.sys (niezgodny sterownik)";
    Write-Info "Uruchom: C:\\myAI_System\\scripts\\diagnostics\\remove-euvkbd-driver.ps1 -Execute"
} else {
    Write-Success "EuVKbd.sys: Nieobecny (OK)"
}

# ============================================================================
# KROK 2: Sprawdź .env files
# ============================================================================
Write-Step "Sprawdzanie .env files..."

# MASTER .env (C:\myai)
$master_env = "C:\myai\.env"
if (Test-Path $master_env) {
    $env_size = (Get-Item $master_env).Length
    Write-Success "MASTER .env: C:\myai\.env ($env_size bajtów)"
} else {
    Write-Warning "MASTER .env nie istnieje: C:\myai\.env"
    Write-Info "Uruchom sync: C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1"
}

# APPLICATION .env (D:\myai)
$app_env = "D:\myai\.env"
if (Test-Path $app_env) {
    Write-Success "APPLICATION .env: D:\myai\.env"
} else {
    Write-Warning "APPLICATION .env nie istnieje: D:\myai\.env"
    if (Test-Path "D:\myai\.env.template") {
        Write-Info "Tworzę z template..."
        Copy-Item "D:\myai\.env.template" $app_env
        Write-Success "Utworzono z template - edytuj według potrzeb"
    } else {
        Write-Error "Brak template! Skopiuj z C:\myAI_System\templates\"
    }
}

# ============================================================================
# KROK 3: Sprawdź Python
# ============================================================================
Write-Step "Sprawdzanie Python..."

$python_cmd = Get-Command python -ErrorAction SilentlyContinue
if ($python_cmd) {
    $python_version = & python --version 2>&1
    Write-Success "Python zainstalowany: $python_version"
    
    $python_path = & python -c "import sys; print(sys.executable)" 2>$null
    Write-Info "Lokalizacja: $python_path"
} else {
    Write-Error "Python nie znaleziony w PATH!"
    Write-Info "Zainstaluj Python 3.13+ lub dodaj do PATH"
    Write-Host "`nNaciśnij Enter aby kontynuować..." -ForegroundColor Yellow
    Read-Host
}

# ============================================================================
# KROK 4: Sprawdź Virtual Environment
# ============================================================================
Write-Step "Sprawdzanie Virtual Environment..."

$venv_path = "D:\myai\venv"
$venv_python = "$venv_path\Scripts\python.exe"

if (Test-Path $venv_python) {
    Write-Success "Venv istnieje: $venv_path"
    
    # Sprawdź wersję Python w venv
    $venv_version = & $venv_python --version 2>&1
    Write-Info "Python w venv: $venv_version"
    
    # Sprawdź zainstalowane pakiety
    $pip_list = & "$venv_path\Scripts\pip.exe" list 2>$null
    if ($pip_list) {
        $package_count = ($pip_list | Measure-Object -Line).Lines - 2  # Pomijamy nagłówek
        Write-Info "Zainstalowanych pakietów: $package_count"
    }
} else {
    Write-Warning "Venv nie istnieje - tworzę..."
    
    if ($python_cmd) {
        Write-Info "Tworzę virtual environment..."
        & python -m venv "D:\myai\venv" 2>$null
        
        if (Test-Path $venv_python) {
            Write-Success "Venv utworzony"
            
            # Sprawdź czy są requirements
            if (Test-Path "D:\myai\requirements.txt") {
                Write-Info "Instaluję zależności z requirements.txt..."
                & "$venv_path\Scripts\pip.exe" install -r "D:\myai\requirements.txt" 2>$null
                Write-Success "Zależności zainstalowane"
            }
        } else {
            Write-Error "Nie udało się utworzyć venv"
        }
    }
}

# ============================================================================
# KROK 5: Sprawdź VS Code
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
# KROK 6: Sprawdź rozszerzenia VS Code
# ============================================================================
Write-Step "Sprawdzanie rozszerzeń VS Code..."

$required_extensions = @(
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.debugpy",
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
# KROK 7: Status ostatniej sesji
# ============================================================================
Write-Step "Status ostatniej sesji..."

# Sprawdź ostatnie logi
if (Test-Path "D:\myai\logs") {
    $last_log = Get-ChildItem "D:\myai\logs" -Filter "*.log" | 
        Sort-Object LastWriteTime -Descending | 
        Select-Object -First 1
    
    if ($last_log) {
        Write-Info "Ostatni log: $($last_log.Name) ($($last_log.LastWriteTime))"
    }
}

# Sprawdź README dla kontekstu
if (Test-Path "D:\myai\README.md") {
    $readme_first_line = Get-Content "D:\myai\README.md" -First 1
    Write-Info "Projekt: $readme_first_line"
}

# ============================================================================
# KROK 8: Otwórz VS Code
# ============================================================================
Write-Step "Uruchamianie VS Code..."

$workspace_file = "D:\myai\myai-application.code-workspace"

# Utwórz workspace file jeśli nie istnieje
if (-not (Test-Path $workspace_file)) {
    Write-Info "Tworzę plik workspace..."
    
    $workspace_content = @{
        "folders" = @(
            @{
                "path" = "D:\myai"
                "name" = "🤖 myAI Application (D:)"
            }
        )
        "settings" = @{
            "python.defaultInterpreterPath" = "D:\myai\venv\Scripts\python.exe"
            "python.terminal.activateEnvironment" = $true
            "files.exclude" = @{
                "**/__pycache__" = $true
                "**/.pytest_cache" = $true
                "**/venv" = $false
            }
            "terminal.integrated.defaultProfile.windows" = "PowerShell"
            "python.analysis.typeCheckingMode" = "basic"
        }
        "extensions" = @{
            "recommendations" = @(
                "ms-python.python",
                "ms-python.vscode-pylance",
                "github.copilot",
                "github.copilot-chat"
            )
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
Write-Host "  1. VS Code otworzył się z workspace D:\myai" -ForegroundColor White
Write-Host "  2. Python venv jest aktywny automatycznie" -ForegroundColor White
Write-Host "  3. Możesz uruchamiać agentów i skrypty" -ForegroundColor White
Write-Host "  4. Dokumentacja: D:\myai\docs\" -ForegroundColor White

Write-Host "`n🔍 Struktura projektu:" -ForegroundColor Yellow
Write-Host "  📁 agents/         - Twoje agenty AI" -ForegroundColor White
Write-Host "  📁 shared/         - Współdzielone narzędzia" -ForegroundColor White
Write-Host "  📁 evaluation/     - Testy i ewaluacja" -ForegroundColor White
Write-Host "  📁 tracing/        - Śledzenie wykonania" -ForegroundColor White

Write-Host "`n💡 Przydatne komendy (w terminalu VS Code):" -ForegroundColor Yellow
Write-Host "  - Aktywuj venv: .\venv\Scripts\Activate.ps1" -ForegroundColor Cyan
Write-Host "  - Uruchom agenta: python -m agents.conversational-agent.main" -ForegroundColor Cyan
Write-Host "  - Testy: pytest" -ForegroundColor Cyan

Write-Host "`n🚀 Workspace D:\myai gotowy do pracy!" -ForegroundColor Green
Write-Host "="*80 -ForegroundColor Cyan

# Poczekaj 5 sekund przed zamknięciem
Write-Host "`nOkno zamknie się za 5 sekund..." -ForegroundColor Gray
Start-Sleep -Seconds 5
