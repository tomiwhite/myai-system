# myAI_System - Quick Start

**System Management Agent dla ekosystemu myAI**

## 🚀 Szybki Start

### Lokalizacja
```
C:\myAI_System\
```

### Podstawowe komendy

```powershell
# Przejdź do katalogu głównego
cd C:\myAI_System

# Zobacz strukturę
tree /F /A

# Przejdź do raportów
cd reports\disk-analysis

# Przejdź do logów
cd logs

# Przejdź do dokumentacji
cd docs
```

## 📁 Struktura Główna

```
myAI_System/
├── agents/           # Agenci systemowi (skrypty w podfolderach)
├── reports/          # Raporty techniczne (JSON)
├── backups/          # Backupy konfiguracji
├── scripts/          # Skrypty automatyzacyjne
├── config/           # Konfiguracje (JSON, YAML)
├── logs/             # Logi operacji
└── docs/             # Dokumentacja, work-logs, raporty MD
    ├── reports/      # Raporty w formacie Markdown
    ├── work-logs/    # Dzienniki pracy
    └── architecture/ # Dokumentacja architektury
```

## 📝 Zasady Nazewnictwa

### Pliki z timestampem (w docs/):
```
YYYYMMDDHHMMSS-nazwa-opisowa.md
20251108165916-disk-analysis-report.md
20251108170000-cleanup-session.md
```

### Pliki stałe (w root/):
```
README.md
QUICKSTART.md
AI_RULES.md
.env
```

## 🤖 Agenci Systemowi

1. **system-cleaner** - Czyszczenie systemu
2. **disk-monitor** - Monitoring dysków
3. **performance-optimizer** - Optymalizacja wydajności

## 🔗 Integracja z ekosystemem

- **C:\myAI_System** - Zarządzanie maszyną (ten katalog)
- **D:\myai** - Ekosystem multi-agentowy

## � Konfiguracja .env

**WAŻNE**: Przed rozpoczęciem pracy z agentami!

### Hierarchia plików .env:
```
C:\myai\.env           ← MASTER (✅ uzupełniony - 29 zmiennych)
D:\myai\.env           ← APPLICATION (⚠️ utwórz z template)
agents/{name}/.env.local ← AGENT (opcjonalne)
```

### Quick Setup:
```powershell
# 1. Sprawdź MASTER .env (powinien już istnieć)
Test-Path C:\myai\.env

# 2. Utwórz APPLICATION .env
Copy-Item D:\myai\.env.template D:\myai\.env
code D:\myai\.env

# 3. (Opcjonalnie) Sync MASTER z Google Drive
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1
```

### 📖 Szczegółowa instrukcja:
- **docs/quickstart/AGENT-STARTUP-ENV.md** - Kompletny przewodnik
- **docs/quickref/ENV-MANAGEMENT.md** - Quick reference

## �📊 Raporty

- **JSON** → `reports/disk-analysis/`
- **Markdown** → `docs/reports/`
- **Work logs** → `docs/work-logs/`

## 🛡️ Backupy

Przed każdą modyfikacją systemu:
- PATH → `backups/path-backups/`
- Registry → `backups/registry-backups/`
- Config → `backups/config-backups/`

## 📅 Utworzono

2025-11-08 - Inicjalizacja struktury
