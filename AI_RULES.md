# AI_RULES - Zasady dla AI Agents

**Konstytucja działania AI Agents w myAI_System**

## 📋 Zasady Podstawowe

### 1. Organizacja Plików

#### ✅ Pliki systemowe (skrypty, konfigi) - BEZ timestampów
**Wszystkie pliki poza docs/ - NORMALNE NAZWY:**
- `scripts/*.ps1` - Skrypty PowerShell (validate-naming-rules.ps1)
- `agents/*/` - Kod agentów
- `config/*.json` - Konfiguracje
- `templates/*` - Szablony
- `README.md`, `QUICKSTART.md`, `AI_RULES.md` - Główne pliki ROOT

#### ✅ Dokumenty w docs/ - WIĘKSZOŚĆ z timestampem
**TYLKO dokumenty MD w docs/ wymagają timestampu:**
- `docs/work-logs/` - Dzienniki pracy, sesji (**ZAWSZE timestamp**)
- `docs/reports/` - Raporty opisowe (**ZAWSZE timestamp**)
- `docs/architecture/` - Dokumentacja architektury (**ZAWSZE timestamp**)

**WYJĄTKI docs/ (bez timestampu - stałe reference):**
- `docs/quickref/` - Quick reference guides (bez timestampu)
- `docs/quickstart/` - Quick start guides (bez timestampu)
- `docs/user-guide/` - User guides (bez timestampu)
- `docs/management/` - Polityki governance, ledger zmian, status delivery (bez timestampu)
- `docs/diagrams/` - Diagramy i schematy (bez timestampu)
- `docs/*.txt` - Pliki tekstowe reference (bez timestampu)

### 2. Nazewnictwo Plików

#### ✅ Pliki systemowe - Normalne nazwy (BEZ timestampu):
```
scripts/validation/validate-naming-rules.ps1
scripts/startup/start-myai-system-c.ps1
config/system-config.json
agents/disk-monitor/monitor.py
README.md
QUICKSTART.md
AI_RULES.md
```

#### ✅ Dokumenty MD w docs/ - Z timestampem (TYLKO w docs/):
```
YYYYMMDDHHMMSS-nazwa-opisowa.md

Przykłady:
docs/work-logs/20251108170530-cleanup-session.md
docs/reports/20251108171200-system-diagnostics.md
docs/architecture/20251108172345-agent-design.md
```

### 3. Struktura Katalogów

```
myAI_System/
├── README.md              ← Bez timestampu
├── QUICKSTART.md          ← Bez timestampu
├── AI_RULES.md            ← Bez timestampu
├── agents/                ← Kod agentów (bez timestampu)
│   └── disk-monitor/*.py  ← Normalne nazwy plików
├── scripts/               ← Skrypty (bez timestampu)
│   ├── startup/*.ps1      ← start-myai-system-c.ps1
│   ├── validation/*.ps1   ← validate-naming-rules.ps1
│   └── diagnostics/*.ps1  ← auto-fix-issues.ps1
├── config/                ← Konfiguracje (bez timestampu)
│   └── *.json             ← system-config.json
├── reports/               ← Raporty JSON (bez timestampu w folderze)
├── backups/               ← Backupy (bez timestampu w folderze)
├── logs/                  ← Logi (timestamp w nazwie pliku)
└── docs/                  ← TYLKO TUTAJ timestamp dla MD!
    ├── reports/           ← 20251108-*.md ✅
    ├── work-logs/         ← 20251108-*.md ✅
    ├── architecture/      ← 20251108-*.md ✅
    ├── quickref/          ← ENV-MANAGEMENT.md (bez TS)
    ├── quickstart/        ← AGENT-STARTUP-ENV.md (bez TS)
    ├── management/        ← DELIVERY-LEDGER.md (bez TS)
    └── user-guide/        ← ONE-CLICK-STARTER.md (bez TS)
```

## 🤖 Zasady dla AI Agents

### Podczas tworzenia dokumentów:

1. **Raporty z pracy** → `docs/work-logs/YYYYMMDDHHMMSS-session-name.md`
2. **Raporty techniczne MD** → `docs/reports/YYYYMMDDHHMMSS-report-name.md`
3. **Dokumentacja architektury** → `docs/architecture/YYYYMMDDHHMMSS-doc-name.md`
4. **Raporty JSON** → `reports/disk-analysis/` (bez timestampu w nazwie folderu)
5. **Polityki governance i ledger zmian** → `docs/management/*.md` (bez timestampu)

### Klasy raportowania

1. **`docs/work-logs/`**
    - chronologiczny dziennik sesji AI / operatora
    - co zostalo zmienione, sprawdzone i dlaczego

2. **`docs/reports/`**
    - raporty opisowe z diagnostyki, audytu, cleanup, rolloutu lub aktualizacji
    - dokumenty punktowe, timestampowane, odnoszace sie do konkretnego przebiegu

3. **`docs/management/`**
    - stale dokumenty governance dla rozbudowy i utrzymania projektu
    - polityka raportowania, ledger zmian produkcyjnych, status delivery
    - sluzy do odroznienia prac nad budowa/rozbudowa/aplikacja od raportow runtime/system

### Minimalny rygor raportowania dla AI

1. Kazda nietrywialna sesja zmieniajaca repo wymaga wpisu do `docs/work-logs/`.
2. Kazda zmiana dotyczaca budowy, rozbudowy, aktualizacji, governance albo automatyzacji projektu wymaga tez aktualizacji `docs/management/DELIVERY-LEDGER.md`.
3. Jesli sesja ma wynik diagnostyczny, audytowy lub wdrozeniowy z wnioskami dla operatora, powstaje tez raport w `docs/reports/`.
4. Brak wpisu do work-logu i brak aktualizacji ledgera przy zmianach produkcyjnych traktuj jako niekompletne wykonanie zadania.

### Podczas tworzenia backupów:

```powershell
# Zawsze z timestampem
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backupFile = "backups/path-backups/$timestamp-path-backup.txt"
```

### Podczas logowania:

```powershell
# Logi z timestampem
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$logFile = "logs/$timestamp-operation.log"
```

## 🚫 NIE RÓB TEGO

❌ Nie twórz plików MD w root/ poza README, QUICKSTART, AI_RULES
❌ Nie twórz dokumentów MD w docs/ bez timestampu (oprócz wyjątków)
❌ Nie dodawaj timestampów do skryptów, konfigów, kodu agentów
❌ Nie twórz plików z timestampem poza docs/
❌ Nie mieszaj raportów JSON z MD
❌ Nie twórz folderów ad-hoc bez dokumentacji

## ✅ ZAWSZE RÓB TO

✅ Timestampy YYYYMMDDHHMMSS **TYLKO w docs/** (work-logs, reports, architecture)
✅ Skrypty, konfigi, kod - normalne nazwy (bez timestampu)
✅ Dokumenty robocze → docs/ (z timestampem)
✅ Backupy przed każdą zmianą
✅ Logi wszystkich operacji
✅ Sprawdzaj czy folder istnieje przed zapisem

## 🔄 Workflow Typowy

```powershell
# 1. Rozpocznij sesję - utwórz work-log
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
New-Item "docs/work-logs/$timestamp-cleanup-session.md"

# 2. Wykonaj operację z backupem
$backupFile = "backups/path-backups/$timestamp-before-cleanup.txt"
$env:PATH | Out-File $backupFile

# 3. Loguj operację
$logFile = "logs/$timestamp-cleanup.log"
"[INFO] Starting cleanup..." | Out-File $logFile

# 4. Generuj raport
$reportFile = "docs/reports/$timestamp-cleanup-results.md"
# ... zawartość raportu
```

## 📊 Integracja z ekosystemem myAI

- **C:\myAI_System** - System Management (ten katalog)
- **D:\myai** - Aplikacje, multi-agent, repozytoria

## 🎯 Cel

Utrzymanie porządku i możliwości chronologicznego odtworzenia wszystkich działań.

---

**Wersja:** 1.0
**Data utworzenia:** 2025-11-08
**Ostatnia aktualizacja:** 2025-11-08
