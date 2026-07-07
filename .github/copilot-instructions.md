# GitHub Copilot Instructions - myAI_System

**System Management Agent dla ekosystemu myAI**

## 🎯 Cel Projektu

Ten projekt to **System Management Agent** działający na poziomie C:\ Windows 11. Jego zadaniem jest:
- 🧹 Czyszczenie i optymalizacja systemu Windows
- 📊 Monitoring dysków, pamięci, CPU i zasobów
- 🔧 Zarządzanie instalacjami, konfiguracjami i PATH
- 📈 Automatyczne generowanie raportów diagnostycznych
- 💾 Backupy konfiguracji systemowych przed każdą zmianą
- 🚀 ONE-CLICK STARTER - uproszczone uruchamianie środowiska

## 📁 Struktura Projektu

```
C:\myAI_System/
├── .github/                    # Konfiguracja GitHub (ten plik)
├── agents/                     # Agenci systemowi
│   ├── system-cleaner/         # Czyszczenie cache, temp, node_modules
│   ├── disk-monitor/           # Monitoring dysków C:\, D:\
│   └── performance-optimizer/  # Optymalizacja PATH, rejestru, startup
├── scripts/                    # Skrypty PowerShell
│   ├── startup/                # ONE-CLICK STARTERS
│   │   ├── start-myai-system-c.ps1        # Launcher dla C:\myAI_System
│   │   └── start-myai-application-d.ps1   # Launcher dla D:\myai
│   ├── config/                 # Zarządzanie konfiguracją
│   │   └── sync-env-from-gdrive.ps1       # Sync .env z Google Drive
│   ├── diagnostics/            # Diagnostyka i audyty
│   │   ├── quick-permissions-check.ps1    # Szybkie sprawdzenie uprawnień
│   │   ├── deep-system-audit.ps1          # Głęboki audyt systemu
│   │   ├── audit-permissions.ps1          # Pełny audyt uprawnień (admin)
│   │   ├── auto-fix-issues.ps1            # Automatyczne naprawy
│   │   ├── auto-cleanup.ps1               # Automatyczne czyszczenie
│   │   └── deep-cleanup-admin.ps1         # Głębokie czyszczenie (admin)
│   ├── validation/             # Walidacja projektu
│   │   └── validate-naming-rules.ps1      # Walidator AI_RULES.md
│   ├── cleanup/                # Skrypty czyszczące
│   └── monitoring/             # Skrypty monitorujące
├── config/                     # Konfiguracje JSON/YAML
│   ├── system-config.json      # Konfiguracja główna
│   └── integration-config.json # Integracja z D:\myai
├── docs/                       # Dokumentacja
│   ├── reports/                # Raporty opisowe (MD)
│   ├── work-logs/              # Dzienniki pracy sesji
│   ├── architecture/           # Dokumentacja architektury
│   ├── management/             # Governance, ledger zmian, polityki raportowania
│   ├── quickref/               # Quick reference guides
│   ├── quickstart/             # Quick start guides
│   ├── user-guide/             # Instrukcje użytkownika
│   └── diagrams/               # Diagramy i schematy
├── reports/                    # Raporty techniczne (JSON)
│   ├── disk-analysis/          # Analizy dysków
│   ├── performance/            # Raporty wydajności
│   ├── cleanup-logs/           # Logi czyszczenia
│   └── permissions/            # Raporty uprawnień
├── backups/                    # Backupy konfiguracji
│   ├── path-backups/           # Backupy zmiennej PATH
│   ├── registry-backups/       # Backupy rejestru
│   └── config-backups/         # Backupy konfiguracji
├── logs/                       # Logi operacji (timestamp w nazwie)
├── templates/                  # Szablony plików
├── README.md                   # Główny opis (stały)
├── QUICKSTART.md               # Szybki start (stały)
└── AI_RULES.md                 # 🔴 KRYTYCZNE - Zasady nazewnictwa

```

## 🤖 Zasady AI Agents (AI_RULES.md)

**⚠️ NAJWAŻNIEJSZY PLIK: `AI_RULES.md`**

### Konwencja nazewnictwa plików

#### ✅ Pliki systemowe (kod, skrypty, konfigi) - NORMALNE NAZWY:
**BEZ timestampów - wszystkie pliki poza docs/:**
- `scripts/*.ps1` - Skrypty PowerShell (np. `validate-naming-rules.ps1`)
- `agents/*/*.py` - Kod agentów (np. `monitor.py`)
- `config/*.json` - Konfiguracje (np. `system-config.json`)
- `templates/*` - Szablony
- `README.md`, `QUICKSTART.md`, `AI_RULES.md` - Główne pliki

#### ✅ Dokumenty w docs/ - Z timestampem YYYYMMDDHHMMSS:
**TYLKO dokumenty MD w docs/ wymagają timestampu:**
- `docs/work-logs/` - Dzienniki pracy (**ZAWSZE timestamp**)
- `docs/reports/` - Raporty opisowe (**ZAWSZE timestamp**)
- `docs/architecture/` - Dokumentacja architektury (**ZAWSZE timestamp**)

**WYJĄTKI docs/ (bez timestampu):**
- `docs/quickref/` - Quick reference guides (stałe)
- `docs/quickstart/` - Quick start guides (stałe)
- `docs/user-guide/` - User guides (stałe)
- `docs/management/` - governance, ledger zmian, polityki raportowania (stałe)
- `docs/diagrams/` - Diagramy i schematy (stałe)

#### Format timestampu (TYLKO dla docs/):
```powershell
# Timestamp TYLKO dla dokumentów MD w docs/
$timestamp = Get-Date -Format "yyyyMMddHHmmss"

# ✅ Prawidłowe (docs/ z timestampem)
docs/work-logs/20251108170530-cleanup-session.md
docs/reports/20251109031412-system-audit.md
docs/architecture/20251108165916-agent-design.md

# ✅ Prawidłowe (pliki systemowe BEZ timestampu)
scripts/validation/validate-naming-rules.ps1
scripts/startup/start-myai-system-c.ps1
config/system-config.json
agents/disk-monitor/monitor.py

# ❌ BŁĄD (timestamp poza docs/)
scripts/20251108-validate-naming-rules.ps1  # ŹLE!
```

### 🚨 Walidacja - AUTOMATYCZNA
Projekt ma **automatyczny walidator**: `scripts/validation/validate-naming-rules.ps1`

```powershell
# Sprawdź czy pliki przestrzegają AI_RULES
.\scripts\validation\validate-naming-rules.ps1

# Ze szczegółami
.\scripts\validation\validate-naming-rules.ps1 -Verbose

# Automatyczne naprawianie
.\scripts\validation\validate-naming-rules.ps1 -Fix
```

**Walidator uruchamia się automatycznie w ONE-CLICK STARTER!**

## 🔧 Technologie i Narzędzia

### Główne:
- **PowerShell 7.5.4** - Język skryptowy (wszystkie automaty)
- **Windows 11** - System docelowy
- **VS Code** - IDE
- **Git 2.51.2** - Kontrola wersji

### Rozszerzenia VS Code:
- `ms-python.python` - Python support
- `ms-python.vscode-pylance` - Python IntelliSense
- `ms-vscode.powershell` - PowerShell support
- `github.copilot` - AI Assistant
- `github.copilot-chat` - AI Chat

### Konfiguracja:
- **Python**: 3.13/3.14 (opcjonalny dla agentów)
- **.NET SDK**: 10.0.100-rc.2.25502.107
- **GitHub Desktop**: Zainstalowany
- **Execution Policy**: RemoteSigned

## 🔑 Zmienne Środowiskowe

### Hierarchia plików .env:
```
C:\myai\.env           ← MASTER (✅ 29 zmiennych - wszystkie API keys)
D:\myai\.env           ← APPLICATION (config projektu)
agents/{name}/.env.local ← AGENT (opcjonalne nadpisania)
```

### Synchronizacja .env:
```powershell
# Sync MASTER .env z Google Drive
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# Lokalizacja Google Drive backup
G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env
```

**Dokumentacja**: `docs/quickstart/AGENT-STARTUP-ENV.md`

## 🚀 Workflow Tworzenia Nowych Plików

### 1. Tworzenie raportu opisowego:
```powershell
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$reportFile = "C:\myAI_System\docs\reports\$timestamp-cleanup-results.md"

@"
# Raport: Cleanup Results
**Data**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Podsumowanie
- Wyczyszczono: 1024 plików
- Zwolniono: 2.5 GB

## Szczegóły
...
"@ | Out-File $reportFile -Encoding UTF8
```

### 2. Tworzenie work-logu:
```powershell
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$worklog = "C:\myAI_System\docs\work-logs\$timestamp-session-name.md"

@"
# Work Log: Session Name
**Data**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Cel sesji
- Diagnostyka dysków
- Czyszczenie cache

## Wykonane kroki
1. ...
"@ | Out-File $worklog -Encoding UTF8
```

### 3. Tworzenie backupu:
```powershell
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backupFile = "C:\myAI_System\backups\path-backups\$timestamp-path-backup.txt"

# Zawsze backup przed zmianą!
$env:PATH | Out-File $backupFile -Encoding UTF8
```

### 4. Logowanie operacji:
```powershell
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFile = "C:\myAI_System\logs\$timestamp-operation.log"

@"
[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] INFO: Starting operation...
[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")] SUCCESS: Completed
"@ | Out-File $logFile -Encoding UTF8
```

## 📊 Konwencje Raportowania

### Raporty JSON (techniczne) → `reports/`
```powershell
$report = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    type = "disk-analysis"
    data = @{
        drive = "C:\"
        totalSize = 512GB
        freeSpace = 128GB
    }
}

$reportFile = "C:\myAI_System\reports\disk-analysis\disk_c_report_$timestamp.json"
$report | ConvertTo-Json -Depth 10 | Out-File $reportFile -Encoding UTF8
```

### Raporty MD (opisowe) → `docs/reports/`
```powershell
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$reportFile = "C:\myAI_System\docs\reports\$timestamp-disk-analysis-summary.md"

@"
# Raport: Analiza Dysków
**Data**: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## C:\ Summary
- Total: 512 GB
- Free: 128 GB
- Used: 384 GB (75%)

## Recommendations
- Cleanup recommended
"@ | Out-File $reportFile -Encoding UTF8
```

### Governance / delivery tracking → `docs/management/`

Pliki stałe, bez timestampu, do rozróżniania zmian projektowych od raportów runtime:
- `docs/management/REPORTING-POLICY.md` - reguły klasyfikacji raportów i wymagany rygor
- `docs/management/DELIVERY-LEDGER.md` - skrócony ledger zmian produkcyjnych, rozbudowy i aktualizacji

## 🧭 Rygor Raportowania Operacyjnego

### Rozróżnienie klas dokumentów

1. **`docs/work-logs/`**
    - dziennik przebiegu sesji AI / operatora
    - obowiązkowy dla każdej nietrywialnej pracy w repo

2. **`docs/reports/`**
    - timestampowane raporty wynikowe z audytów, diagnostyki, cleanup, rolloutów i aktualizacji
    - dla operatora, z wnioskami i walidacją

3. **`docs/management/`**
    - stała warstwa governance
    - polityki, status delivery, ledger prac nad budową / rozbudową / aktualizacją projektu
    - ma być logicznie oddzielona od raportów runtime systemu i działania aplikacji

### Obowiązki AI po zmianach

1. Po każdej nietrywialnej zmianie w repo AI tworzy albo aktualizuje wpis w `docs/work-logs/`.
2. Po każdej zmianie projektowej, produkcyjnej, architektonicznej lub automatyzacyjnej AI aktualizuje `docs/management/DELIVERY-LEDGER.md`.
3. Gdy sesja kończy się wynikiem diagnostycznym, migracyjnym, rolloutem albo przeglądem ryzyk, AI zapisuje też raport do `docs/reports/`.
4. Brak odpowiedniego wpisu dokumentacyjnego oznacza, że praca nie jest domknięta.

## 🎯 Wzorce Architektoniczne

### 1. Agent Pattern
Każdy agent w `agents/` to niezależny moduł odpowiedzialny za konkretną funkcję:
- **system-cleaner** - Czyszczenie (cache, temp, node_modules, Python __pycache__)
- **disk-monitor** - Monitoring dysków (analiza rozmiaru, wolnego miejsca)
- **performance-optimizer** - Optymalizacja (PATH cleanup, registry, startup programs)

### 2. ONE-CLICK STARTER Pattern
Uproszczone uruchamianie przez ikony na pulpicie:
- **myAI System (C).lnk** → `scripts/startup/start-myai-system-c.ps1`
- **myAI Application (D).lnk** → `scripts/startup/start-myai-application-d.ps1`

Każdy starter:
1. Sprawdza strukturę katalogów
2. Waliduje .env (MASTER)
3. Sprawdza zależności (VS Code, Python, Git)
4. Instaluje brakujące rozszerzenia VS Code
5. Synchronizuje .env z Google Drive (jeśli nowszy)
6. **Uruchamia validator AI_RULES** ✅
7. Pokazuje ostatnią sesję i raporty
8. Otwiera VS Code z workspace

### 3. Backup-Before-Change Pattern
**ZAWSZE twórz backup przed modyfikacją systemu:**
```powershell
# Przed zmianą PATH
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backupFile = "backups/path-backups/$timestamp-before-cleanup.txt"
$env:PATH | Out-File $backupFile
```

### 4. Diagnostic-First Pattern
Przed każdą operacją - diagnostyka:
```powershell
# 1. Diagnoza
.\scripts\diagnostics\quick-permissions-check.ps1

# 2. Backup
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
# ... backup ...

# 3. Operacja
# ... wykonaj zmianę ...

# 4. Raport
$reportFile = "docs/reports/$timestamp-operation-results.md"
# ... wygeneruj raport ...
```

## 🔒 Bezpieczeństwo i Uprawnienia

### Poziomy uprawnień:
1. **Bez admin** - Większość operacji (diagnostyka, raporty, monitoring)
2. **Z admin** - Operacje systemowe (czyszczenie Program Files, rejestr)

### Skrypty diagnostyczne:
```powershell
# Szybkie sprawdzenie (bez admin)
.\scripts\diagnostics\quick-permissions-check.ps1

# Pełny audyt (wymaga admin)
.\scripts\diagnostics\audit-permissions.ps1

# Głęboka analiza systemu (wymaga admin)
.\scripts\diagnostics\deep-system-audit.ps1
```

### Auto-fix:
```powershell
# Automatyczne naprawy (częściowo wymaga admin)
.\scripts\diagnostics\auto-fix-issues.ps1

# Głębokie czyszczenie (wymaga admin)
Start-Process pwsh -Verb RunAs -ArgumentList '-File', 'C:\myAI_System\scripts\diagnostics\deep-cleanup-admin.ps1'
```

## 🔗 Integracja z Ekosystemem myAI

Ten projekt (C:\myAI_System) działa równolegle z:
- **D:\myai** - Ekosystem multi-agentowy (agent/multi-agent)
- **Repozytoria GitHub** - Kod aplikacji i agentów

### Podział odpowiedzialności:
- **C:\myAI_System** - Zarządzanie maszyną (poziom systemu Windows)
- **D:\myai** - Aplikacje, agenty AI, projekty

### Replikacja:
Struktura zaprojektowana do replikacji na:
- Komputery wirtualne (Windows 11 VM)
- Serwery zdalne
- Autonomiczna obsługa systemu myAI

## 🎨 Style Guide dla PowerShell

### Naming Conventions:
```powershell
# Funkcje: Verb-Noun
function Get-DiskInfo { }
function Remove-CacheFiles { }

# Zmienne: camelCase
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$reportFile = "path/to/file"
$cleanedCount = 0

# Stałe: UPPER_SNAKE_CASE
$MASTER_ENV = "C:\myai\.env"
$PROJECT_ROOT = "C:\myAI_System"
```

### Komentarze:
```powershell
# ============================================================================
# SEKCJA GŁÓWNA
# ============================================================================

# 1. Krok pierwszy
# 2. Krok drugi

# Pojedyncza operacja
```

### Output Formatting:
```powershell
function Write-Header { Write-Host "`n$('='*80)" -ForegroundColor Cyan; Write-Host " $args" -ForegroundColor Yellow; Write-Host "$('='*80)" -ForegroundColor Cyan }
function Write-Success { Write-Host "  ✅ $args" -ForegroundColor Green }
function Write-Warning { Write-Host "  ⚠️  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "  ❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "  ℹ️  $args" -ForegroundColor Cyan }
function Write-Step { Write-Host "`n🔹 $args" -ForegroundColor Magenta }
```

## 🚫 NIE RÓB TEGO (Common Mistakes)

❌ **Nie dodawaj timestampów do skryptów, konfigów, kodu** (tylko docs/)
❌ **Nie twórz plików MD w ROOT** (poza README, QUICKSTART, AI_RULES)
❌ **Nie twórz dokumentów MD w docs/ bez timestampu** (oprócz wyjątków: quickref, user-guide, quickstart, diagrams)
❌ **Nie twórz plików z timestampem poza docs/**
❌ **Nie mieszaj raportów JSON (reports/) z MD (docs/reports/)**
❌ **Nie twórz folderów ad-hoc bez dokumentacji**
❌ **Nie modyfikuj systemu bez backupu**
❌ **Nie uruchamiaj operacji bez diagnostyki**
❌ **Nie pomijaj validatora przed commitem**

## ✅ ZAWSZE RÓB TO (Best Practices)

✅ **Timestampy YYYYMMDDHHMMSS TYLKO w docs/** (work-logs, reports, architecture)
✅ **Skrypty, konfigi, kod - normalne nazwy** (BEZ timestampu)
✅ **Dokumenty robocze → docs/ (z timestampem)**
✅ **Backupy przed każdą zmianą**
✅ **Logi wszystkich operacji**
✅ **Uruchom validator przed commitem**: `.\scripts\validation\validate-naming-rules.ps1`
✅ **Diagnostyka przed operacją**: `quick-permissions-check.ps1`
✅ **Używaj ONE-CLICK STARTER do uruchamiania**
✅ **Sprawdzaj .env MASTER (C:\myai\.env) przed pracą z agentami**
✅ **Synchronizuj .env z Google Drive regularnie**

## 📚 Dokumentacja - Gdzie Szukać?

| Pytanie | Dokument |
|---------|----------|
| Jak uruchomić system? | `docs/user-guide/ONE-CLICK-STARTER.md` |
| Jak działa .env? | `docs/quickstart/AGENT-STARTUP-ENV.md` |
| Jak nazywać pliki? | `AI_RULES.md` (KRYTYCZNE) |
| Quick reference .env | `docs/quickref/ENV-MANAGEMENT.md` |
| Szybki start | `QUICKSTART.md` |
| Główny opis | `README.md` |
| Architektura agentów | `docs/architecture/YYYYMMDDHHMMSS-agent-*.md` |

## 🏗️ Rozwój Projektu

### Dodawanie nowego agenta:
```powershell
# 1. Utwórz folder
New-Item -Path "C:\myAI_System\agents\new-agent" -ItemType Directory

# 2. Utwórz konfigurację
$config = @{
    name = "new-agent"
    description = "Agent description"
    version = "1.0.0"
}
$config | ConvertTo-Json | Out-File "agents/new-agent/config.json"

# 3. Dodaj do system-config.json
# ... aktualizuj agents sekcję ...

# 4. Utwórz dokumentację
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$doc = "docs/architecture/$timestamp-agent-new-agent.md"
# ... napisz dokumentację ...

# 5. Uruchom validator
.\scripts\validation\validate-naming-rules.ps1
```

### Dodawanie nowego skryptu:
```powershell
# 1. Wybierz odpowiedni folder
#    - scripts/startup/ - launchers
#    - scripts/config/ - zarządzanie konfiguracją
#    - scripts/diagnostics/ - diagnostyka i audyty
#    - scripts/validation/ - walidatory
#    - scripts/cleanup/ - czyszczenie
#    - scripts/monitoring/ - monitoring

# 2. Utwórz skrypt z nagłówkiem
@"
# ============================================================================
# NAZWA SKRYPTU
# ============================================================================
# 
# Opis co robi skrypt
#
# Użycie: .\scripts\folder\script-name.ps1
# ============================================================================

`$ErrorActionPreference = "Stop"

# ... kod ...
"@ | Out-File "scripts/folder/script-name.ps1" -Encoding UTF8

# 3. Przetestuj
.\scripts\folder\script-name.ps1

# 4. Dokumentacja
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$doc = "docs/reports/$timestamp-script-name-documentation.md"
# ... napisz dokumentację ...
```

## 🧪 Testing i Walidacja

### Przed każdym commitem:
```powershell
# 1. Walidacja nazewnictwa
.\scripts\validation\validate-naming-rules.ps1 -Verbose

# 2. Szybka diagnostyka
.\scripts\diagnostics\quick-permissions-check.ps1

# 3. Sprawdź .env
Test-Path C:\myai\.env  # Powinno być True

# 4. Git status
git status

# 5. Commit z opisem
git add .
git commit -m "feat: dodano nową funkcjonalność"
```

## 🔄 Historia i Changelog

- **2025-11-08**: Inicjalizacja projektu myAI_System
- **2025-11-08**: Utworzenie struktury katalogów
- **2025-11-08**: Diagnostyka dysków C:\ i D:\
- **2025-11-08**: Migracja z SystemCleanup → myAI_System
- **2025-11-08**: Utworzenie AI_RULES.md
- **2025-11-08**: Validator validate-naming-rules.ps1
- **2025-11-08**: ONE-CLICK STARTER system
- **2025-11-09**: Diagnostyka uprawnień Windows
- **2025-11-09**: Auto-fix i deep-cleanup tools
- **2025-11-09**: **Utworzenie .github/copilot-instructions.md** ✅

## 📞 Kontakt i Wsparcie

**Twórca**: Tomasz Białas (OxygenUp)
**GitHub**: https://github.com/tomiwhite
**Email**: 45501831+tomiwhite@users.noreply.github.com

---

**Wersja**: 1.0.0
**Data utworzenia**: 2025-11-09
**Ostatnia aktualizacja**: 2025-11-09

---

## 💡 Wskazówki dla AI Assistants

Pracując z tym projektem:
1. **ZAWSZE czytaj AI_RULES.md przed utworzeniem pliku**
2. **Timestamp TYLKO dla dokumentów MD w docs/** (work-logs, reports, architecture)
3. **NIE dodawaj timestampów do skryptów, konfigów, kodu agentów**
4. **ZAWSZE uruchom validator po zmianach**
5. **ZAWSZE twórz backup przed modyfikacją systemu**
6. **ZAWSZE loguj operacje do logs/**
7. **ZAWSZE używaj funkcji Write-* do outputu**
8. **ZAWSZE sprawdzaj .env MASTER przed pracą z agentami**
9. **ZAWSZE dokumentuj work-log dla sesji (z timestampem w docs/)**
10. **ZAWSZE aktualizuj docs/management/DELIVERY-LEDGER.md przy zmianach produkcyjnych, rozbudowie, aktualizacjach i governance**

**Priorytet 1**: Zgodność z AI_RULES.md (timestamp TYLKO w docs/)
**Priorytet 2**: Backup przed zmianą
**Priorytet 3**: Diagnostyka przed operacją
**Priorytet 4**: Dokumentacja, ledger i raporty
