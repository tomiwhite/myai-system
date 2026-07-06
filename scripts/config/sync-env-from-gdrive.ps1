# Sync .env from Google Drive to C:\myai
# 
# Synchronizuje MASTER .env z Google Drive do lokalnego ekosystemu myai
# Źródło: G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env
# Cel: C:\myai\.env

param(
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Kolory
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

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

Write-Info "`n🔄 SYNC .env - Google Drive → C:\myai"
Write-Info "=" * 70

# Ścieżki
$envSettings = Get-EnvSyncSettings
$gdrive_env = $envSettings.GoogleDriveEnvPath
$master_env = $envSettings.MasterEnvPath
$backup_dir = "C:\myAI_System\backups\config-backups"

if ($DryRun) {
    Write-Info "`n🔍 DRY RUN - Konfiguracja sync (bez zmian):"
    Write-Info "   Źródło: $gdrive_env"
    Write-Info "   Cel:    $master_env"
    Write-Info "   Override ENV: $($envSettings.GoogleDriveEnvPathEnvVar)"
    Write-Info "   Źródło istnieje: $(Test-Path $gdrive_env)"
    Write-Info "   Cel istnieje:    $(Test-Path $master_env)"
    exit 0
}

# Sprawdź czy Google Drive jest dostępny
Write-Info "`n1️⃣  Sprawdzanie źródła..."
if (-not (Test-Path $gdrive_env)) {
    Write-Error "❌ BŁĄD: Plik źródłowy nie istnieje!"
    Write-Error "   Szukano: $gdrive_env"
    Write-Error "   Czy Google Drive jest zamontowany?"
    exit 1
}
Write-Success "   ✅ Źródło znalezione: $gdrive_env"

$gdrive_size = (Get-Item $gdrive_env).Length
$gdrive_date = (Get-Item $gdrive_env).LastWriteTime
Write-Info "   Rozmiar: $gdrive_size bajtów"
Write-Info "   Data modyfikacji: $gdrive_date"

# Sprawdź czy cel już istnieje
Write-Info "`n2️⃣  Sprawdzanie celu..."
if (Test-Path $master_env) {
    $master_size = (Get-Item $master_env).Length
    $master_date = (Get-Item $master_env).LastWriteTime
    Write-Info "   ℹ️  Cel już istnieje: $master_env"
    Write-Info "   Rozmiar: $master_size bajtów"
    Write-Info "   Data modyfikacji: $master_date"
    
    # Porównaj daty
    if ($gdrive_date -le $master_date -and -not $Force) {
        Write-Warning "`n⚠️  Źródło nie jest nowsze niż cel!"
        Write-Warning "   Źródło (GDrive): $gdrive_date"
        Write-Warning "   Cel (C:\myai): $master_date"
        Write-Warning "`n   Użyj -Force aby wymusić sync"
        exit 0
    }
} else {
    Write-Info "   ℹ️  Cel nie istnieje - zostanie utworzony"
    
    # Utwórz katalog C:\myai jeśli nie istnieje
    if (-not (Test-Path "C:\myai")) {
        Write-Info "   Tworzę katalog C:\myai..."
        New-Item -Path "C:\myai" -ItemType Directory -Force | Out-Null
    }
}

# Backup istniejącego pliku
Write-Info "`n3️⃣  Backup istniejącego .env..."
if (Test-Path $master_env) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup_file = Join-Path $backup_dir "$timestamp-.env.master.backup"
    
    # Utwórz katalog backupów jeśli nie istnieje
    if (-not (Test-Path $backup_dir)) {
        New-Item -Path $backup_dir -ItemType Directory -Force | Out-Null
    }
    
    Copy-Item $master_env $backup_file
    Write-Success "   ✅ Backup utworzony: $backup_file"
} else {
    Write-Info "   ℹ️  Brak pliku do backupu (pierwszy sync)"
}

# Kopiuj
Write-Info "`n4️⃣  Kopiowanie pliku..."
try {
    Copy-Item $gdrive_env $master_env -Force
    Write-Success "   ✅ Plik skopiowany pomyślnie!"
} catch {
    Write-Error "❌ BŁĄD podczas kopiowania: $_"
    exit 1
}

# Weryfikacja
Write-Info "`n5️⃣  Weryfikacja..."
if (Test-Path $master_env) {
    $new_size = (Get-Item $master_env).Length
    $new_date = (Get-Item $master_env).LastWriteTime
    
    if ($new_size -eq $gdrive_size) {
        Write-Success "   ✅ Rozmiar pliku zgodny: $new_size bajtów"
    } else {
        Write-Warning "   ⚠️  Rozmiar różni się!"
        Write-Warning "   Źródło: $gdrive_size bajtów"
        Write-Warning "   Cel: $new_size bajtów"
    }
    
    Write-Info "   Data modyfikacji: $new_date"
} else {
    Write-Error "❌ BŁĄD: Plik docelowy nie istnieje po kopiowaniu!"
    exit 1
}

# Sprawdź uprawnienia (powinien być read-only dla bezpieczeństwa)
Write-Info "`n6️⃣  Ustawianie uprawnień..."
try {
    # Ustaw read-only attribute
    Set-ItemProperty -Path $master_env -Name IsReadOnly -Value $true
    Write-Success "   ✅ Plik ustawiony jako read-only (bezpieczeństwo)"
} catch {
    Write-Warning "   ⚠️  Nie udało się ustawić read-only: $_"
}

# Podsumowanie
Write-Success "`n✅ SYNC ZAKOŃCZONY POMYŚLNIE!"
Write-Info "=" * 70
Write-Info "Źródło: $gdrive_env"
Write-Info "Cel:    $master_env"
Write-Info "Backup: $backup_file"
Write-Info "`nAgenci mogą teraz ładować zmienne z C:\myai\.env"
Write-Info ""

# Opcjonalnie: Pokaż czy są jakieś ważne zmienne
Write-Info "🔍 Szybka weryfikacja zawartości (bez pokazywania sekretów):"
$env_content = Get-Content $master_env
$key_vars = $env_content | Where-Object { $_ -match "^[A-Z_]+=" -and $_ -notmatch "^#" } | ForEach-Object { ($_ -split "=")[0] }
Write-Info "   Znalezionych zmiennych: $($key_vars.Count)"
Write-Info "   Przykłady: $($key_vars[0..4] -join ', ')..."
