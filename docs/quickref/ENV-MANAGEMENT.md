# 🔑 Zarządzanie .env w Ekosystemie myai

**Quick Reference** - jeden centralny `.env` dla wszystkich agentów

Powiązane governance:

- `docs/quickref/GOVERNANCE-INDEX.md`
- `docs/management/REPORTING-POLICY.md`

Rozróżnienie dokumentacji:

- zmiany projektowe i produkcyjne: `docs/management/`
- przebieg sesji i wynik runtime: `docs/work-logs/`, `docs/reports/`

---

## 📍 Struktura Plików

```
C:\myai\.env                           ← MASTER (klucze API, sekrety)
D:\myai\.env                           ← APPLICATION (config projektu)
D:\myai\agents\{agent-name}\.env.local ← AGENT (opcjonalne nadpisania)

# Źródło prawdy (Google Drive)
G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env
```

---

## ⚡ Quick Start

### 1. Pierwszy Sync z Google Drive

```powershell
# Sync .env z Google Drive do C:\myai
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# Dry run (bez zmian)
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1 -DryRun

# Force sync (nawet jeśli lokalny nowszy)
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1 -Force
```

### 2. Ładowanie w Python Agent

```python
from dotenv import load_dotenv

# Hierarchiczne ładowanie
load_dotenv("C:/myai/.env")           # MASTER - klucze API
load_dotenv("D:/myai/.env")           # APPLICATION - config
load_dotenv(".env.local")             # AGENT - nadpisania (opcjonalne)

# Teraz używaj
import os
api_key = os.getenv("OPENAI_API_KEY")
```

### 3. Ładowanie przez Shared Utility (rekomendowane)

```python
# D:\myai\shared\utils\config_loader.py (do stworzenia)
from shared.utils.config_loader import quick_load

quick_load(agent_name="conversational-agent")

# Wszystko załadowane, używaj os.getenv()
```

---

## 🔄 Hierarchia Ładowania

```
┌─────────────────────────────────────────┐
│ 1. C:\myai\.env (MASTER)               │
│    Priorytet: 1 (najniższy - bazowe)   │
│    Zawiera: API keys, sekrety          │
└─────────────────────────────────────────┘
              ↓ override
┌─────────────────────────────────────────┐
│ 2. D:\myai\.env (APPLICATION)          │
│    Priorytet: 2 (nadpisuje MASTER)     │
│    Zawiera: Config projektu, ścieżki   │
└─────────────────────────────────────────┘
              ↓ override
┌─────────────────────────────────────────┐
│ 3. .env.local (AGENT)                  │
│    Priorytet: 3 (najwyższy - nadpisuje)│
│    Zawiera: Tymczasowe testy           │
└─────────────────────────────────────────┘
```

**Zasada**: Później = ważniejsze (nadpisuje wcześniejsze)

---

## 📝 Co Gdzie?

### C:\myai\.env (MASTER)
✅ **TAK** - Przechowuj tutaj:
- `OPENAI_API_KEY=sk-proj-xxx`
- `GITHUB_TOKEN=ghp_xxx`
- `DATABASE_PASSWORD=xxx`
- `AZURE_SUBSCRIPTION_ID=xxx`

❌ **NIE** - Nie przechowuj:
- Ścieżek (te są w APPLICATION .env)
- Config aplikacji (log levels, porty)
- Tymczasowych testów

### D:\myai\.env (APPLICATION)
✅ **TAK** - Przechowuj tutaj:
- `ENVIRONMENT=development`
- `LOG_LEVEL=INFO`
- `API_PORT=8000`
- `SHARED_CONFIG_PATH=D:\myai\shared\config`

❌ **NIE** - Nie przechowuj:
- API keys (te są w MASTER)
- Prawdziwych haseł

**Można commitować** - używaj placeholderów:
```env
# OPENAI_API_KEY=<set-in-C:\myai\.env>
```

### .env.local (AGENT)
✅ **TAK** - Przechowuj tutaj:
- `LOG_LEVEL=DEBUG` (nadpisanie dla testów)
- `MAX_TOKENS=8000` (eksperyment)
- `MOCK_API_CALLS=true` (dev mode)

❌ **NIE commitować** - to lokalny plik testowy

---

## 🔐 Bezpieczeństwo

### MASTER .env (`C:\myai\.env`)
```powershell
# 1. Sync z Google Drive (źródło prawdy)
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# 2. Plik jest read-only (automatycznie po sync)
Get-ItemProperty C:\myai\.env | Select-Object IsReadOnly

# 3. Dodaj do .gitignore (WSZĘDZIE)
echo ".env" >> C:\myai\.gitignore
echo ".env" >> D:\myai\.gitignore
```

### APPLICATION .env (`D:\myai\.env`)
```powershell
# Można commitować (bez sekretów!)
# Używaj placeholderów dla wszystkich API keys
```

### Backup Strategy
```powershell
# Automatyczne codzienne backupy przez System Layer
# Backup do: C:\myAI_System\backups\config-backups\
# Format: YYYYMMDD-HHMMSS-.env.master.backup
# Retencja: 90 dni
```

---

## 🛠️ Operacje

### Edycja MASTER .env
```powershell
# 1. Edytuj ŹRÓDŁO w Google Drive
code "G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env"

# 2. Sync do C:\myai
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# 3. Restart agentów aby załadowały nowe wartości
```

### Dodanie Nowej Zmiennej
```powershell
# Jeśli to SEKRET:
# 1. Dodaj do Google Drive .env
# 2. Sync do C:\myai\.env
# 3. Dodaj placeholder do D:\myai\.env (dla dokumentacji)

# Jeśli to CONFIG:
# Dodaj bezpośrednio do D:\myai\.env (można commitować)
```

### Weryfikacja Co Jest Załadowane
```python
import os
from pathlib import Path

# Sprawdź czy pliki istnieją
print(f"C:\\myai\\.env exists: {Path('C:/myai/.env').exists()}")
print(f"D:\\myai\\.env exists: {Path('D:/myai/.env').exists()}")

# Sprawdź czy zmienna jest załadowana
print(f"OPENAI_API_KEY: {'SET' if os.getenv('OPENAI_API_KEY') else 'NOT SET'}")
print(f"LOG_LEVEL: {os.getenv('LOG_LEVEL', 'NOT SET')}")
```

---

## 🚨 Troubleshooting

### Problem: "Missing required env vars"
```powershell
# Sprawdź czy MASTER .env istnieje
Test-Path C:\myai\.env

# Jeśli nie, sync z Google Drive
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# Jeśli dalej błąd, sprawdź czy zmienna jest w pliku
Select-String -Path "C:\myai\.env" -Pattern "OPENAI_API_KEY"
```

### Problem: "Google Drive .env not found"
```powershell
# Sprawdź czy Google Drive jest zamontowany
Test-Path "G:\Mój dysk"

# Sprawdź dokładną ścieżkę
Get-ChildItem "G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation"
```

### Problem: Agent nie widzi nowych zmiennych
```python
# Restart agenta lub przeładuj .env
from shared.utils.config_loader import ConfigLoader
config = ConfigLoader()
config.reload()  # Przeładuj wszystkie pliki
```

---

## 📊 Monitoring (przez C:\myAI_System)

System Layer automatycznie:
- ✅ Sprawdza czy `C:\myai\.env` istnieje
- ✅ Backupuje codziennie
- ✅ Sync z Google Drive (opcjonalnie automatyczny)
- ✅ Alertuje o brakujących zmiennych
- ✅ Sprawdza uprawnienia plików

---

## 🎯 Best Practices

1. **Źródło Prawdy = Google Drive**
   - Edytuj tam, sync do C:\myai
   - Nie edytuj bezpośrednio C:\myai\.env

2. **Jeden MASTER dla Całego Ekosystemu**
   - `C:\myai\.env` - współdzielony przez C:\ i D:\ projekty
   - Nie duplikuj sekretów

3. **APPLICATION .env = Dokumentacja**
   - Lista wszystkich używanych zmiennych
   - Placeholdery dla sekretów

4. **Never Commit Secrets**
   - `.env` w `.gitignore`
   - Skanuj repo przed commit

5. **Validate at Agent Startup**
   ```python
   config.validate_required([
       "OPENAI_API_KEY",
       "LOG_LEVEL",
       "SHARED_CONFIG_PATH"
   ])
   ```

---

**Status**: ✅ System gotowy  
**Next**: Implementuj `shared/utils/config_loader.py` w D:\myai
