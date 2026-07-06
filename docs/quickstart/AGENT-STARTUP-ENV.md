# 🚀 START AGENTA - Konfiguracja .env

**Instrukcja dla nowych agentów**: Gdzie znaleźć pliki `.env` i jak je skonfigurować

---

## 📍 LOKALIZACJE PLIKÓW

### ✅ UZUPEŁNIONE PLIKI (Gotowe do użycia)

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔑 MASTER .env (Wszystkie sekrety i API keys)                  │
│                                                                  │
│ Lokalizacja: C:\myai\.env                                      │
│ Status: ✅ UZUPEŁNIONY (zsynchronizowany z Google Drive)       │
│ Zawiera: 29 zmiennych (API keys, hasła, tokeny)               │
│                                                                  │
│ Źródło (do edycji):                                            │
│ G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env│
│                                                                  │
│ Jak zaktualizować:                                             │
│ C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1        │
└─────────────────────────────────────────────────────────────────┘
```

### 📝 SZABLONY (Do skopiowania i uzupełnienia)

```
┌─────────────────────────────────────────────────────────────────┐
│ 📄 MASTER .env Template                                        │
│                                                                  │
│ Lokalizacja: C:\myAI_System\templates\.env.master.template    │
│ Cel docelowy: C:\myai\.env                                     │
│ Status: ⚠️  Tylko szablon (nie używaj bezpośrednio!)          │
│                                                                  │
│ ℹ️  Ten szablon jest tylko do dokumentacji struktury.         │
│    Prawdziwy plik jest już w C:\myai\.env                     │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│ 📄 APPLICATION .env Template                                   │
│                                                                  │
│ Lokalizacja: D:\myai\.env.template                            │
│ Cel docelowy: D:\myai\.env                                     │
│ Status: ⚠️  DO SKOPIOWANIA I EDYCJI                           │
│                                                                  │
│ Jak użyć:                                                      │
│ 1. cp D:\myai\.env.template D:\myai\.env                      │
│ 2. code D:\myai\.env                                          │
│ 3. Edytuj wartości (NIE edytuj API keys - one są w MASTER)   │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🗺️ SCHEMAT HIERARCHII .env

```
┌─────────────────────────────────────────────────────────────────────┐
│                         EKOSYSTEM myai                              │
└─────────────────────────────────────────────────────────────────────┘
                                │
                                │
                                ▼
        ┌───────────────────────────────────────────┐
        │  POZIOM 1: MASTER .env                   │
        │  📍 C:\myai\.env                         │
        │  🔒 Read-Only                             │
        │  🔑 API Keys: OPENAI, GEMINI, GROK       │
        │  🔑 Hasła: Database, Redis               │
        │  🔑 Tokeny: GitHub, Azure                │
        │                                           │
        │  🔄 Sync z Google Drive                  │
        │  ✅ 29 zmiennych załadowanych            │
        └───────────────────────────────────────────┘
                        │
                        │ override ↓
                        │
        ┌───────────────────────────────────────────┐
        │  POZIOM 2: APPLICATION .env              │
        │  📍 D:\myai\.env                         │
        │  📝 Można edytować i commitować          │
        │  ⚙️  Config: ENVIRONMENT, LOG_LEVEL      │
        │  📁 Ścieżki: SHARED_CONFIG_PATH          │
        │  🚪 Porty: API_PORT, UI_PORT             │
        │                                           │
        │  ⚠️  Szablon: D:\myai\.env.template     │
        │  ℹ️  Placeholdery dla API keys          │
        └───────────────────────────────────────────┘
                        │
                        │ override ↓
                        │
        ┌───────────────────────────────────────────┐
        │  POZIOM 3: AGENT .env.local              │
        │  📍 D:\myai\agents\{name}\.env.local     │
        │  🧪 Tylko dla testów lokalnych           │
        │  🔧 Override: LOG_LEVEL=DEBUG            │
        │  🔧 Eksperymenty: MAX_TOKENS=8000        │
        │                                           │
        │  ❌ NIE commitować                       │
        │  ℹ️  OPCJONALNE                         │
        └───────────────────────────────────────────┘
```

---

## 🚀 INSTRUKCJA STARTOWA DLA NOWEGO AGENTA

### Krok 1: Sprawdź MASTER .env

```powershell
# Czy MASTER .env istnieje?
Test-Path C:\myai\.env

# Jeśli NIE, zsynchronizuj z Google Drive
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# Weryfikuj ile zmiennych
(Get-Content C:\myai\.env | Where-Object {$_ -match "^[A-Z_]+=" -and $_ -notmatch "^#"}).Count
# Powinno być: 29 zmiennych
```

**Status**: ✅ Już gotowe (zsynchronizowane)

---

### Krok 2: Utwórz APPLICATION .env

```powershell
# Skopiuj szablon
Copy-Item "D:\myai\.env.template" "D:\myai\.env"

# Edytuj config projektu
code "D:\myai\.env"
```

**Co edytować w D:\myai\.env**:
```env
# ✅ EDYTUJ te wartości (config projektu)
ENVIRONMENT=development          # lub production
DEBUG=true                       # true/false
LOG_LEVEL=INFO                   # DEBUG/INFO/WARNING/ERROR
API_PORT=8000                    # Wybierz wolny port

# ❌ NIE EDYTUJ tych linii (tylko placeholdery)
# OPENAI_API_KEY=<set-in-C:\myai\.env>
# Te sekrety są już w C:\myai\.env (MASTER)
```

---

### Krok 3: (Opcjonalnie) Utwórz AGENT .env.local

```powershell
# Tylko jeśli potrzebujesz lokalnych nadpisań dla testów
New-Item "D:\myai\agents\my-agent\.env.local" -ItemType File

# Przykład zawartości
@"
# Lokalne nadpisania dla testów
LOG_LEVEL=DEBUG
MAX_TOKENS=8000
TEMPERATURE=0.9
DEV_MODE=true
"@ | Set-Content "D:\myai\agents\my-agent\.env.local"
```

**Kiedy używać**: Tylko dla tymczasowych eksperymentów. Usuń po zakończeniu.

---

### Krok 4: Załaduj w Kodzie Agenta

```python
# Metoda 1: Ręczne ładowanie
from dotenv import load_dotenv

load_dotenv("C:/myai/.env")           # MASTER - sekrety
load_dotenv("D:/myai/.env")           # APPLICATION - config
load_dotenv(".env.local")             # AGENT - nadpisania (opcjonalne)

# Metoda 2: Przez utility (REKOMENDOWANE - do stworzenia)
from shared.utils.config_loader import quick_load
quick_load(agent_name="my-agent")

# Teraz używaj os.getenv()
import os
api_key = os.getenv("OPENAI_API_KEY")
log_level = os.getenv("LOG_LEVEL")
```

---

### Krok 5: Walidacja

```python
# Sprawdź czy wszystkie wymagane zmienne są załadowane
required_vars = [
    "OPENAI_API_KEY",      # z C:\myai\.env
    "LOG_LEVEL",           # z D:\myai\.env
    "SHARED_CONFIG_PATH"   # z D:\myai\.env
]

missing = [var for var in required_vars if not os.getenv(var)]
if missing:
    raise ValueError(f"Missing env vars: {missing}")

print("✅ All required env vars loaded!")
```

---

## 📋 CHECKLIST STARTOWA

```
🚀 START NOWEGO AGENTA - Checklist

□ 1. MASTER .env istnieje w C:\myai\.env
     └─ Jeśli nie: C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

□ 2. APPLICATION .env utworzony w D:\myai\.env
     └─ cp D:\myai\.env.template D:\myai\.env
     └─ Edytuj wartości config (NIE API keys)

□ 3. (Opcjonalnie) AGENT .env.local dla testów
     └─ D:\myai\agents\{name}\.env.local

□ 4. Kod agenta ładuje .env w kolejności:
     └─ load_dotenv("C:/myai/.env")
     └─ load_dotenv("D:/myai/.env")
     └─ load_dotenv(".env.local")

□ 5. Walidacja wymaganych zmiennych
     └─ OPENAI_API_KEY, LOG_LEVEL, SHARED_CONFIG_PATH

□ 6. Test - uruchom agenta
     └─ python D:\myai\agents\{name}\main.py
```

---

## 🔍 SZYBKA WERYFIKACJA

```powershell
# Sprawdź wszystkie pliki .env
Write-Host "`n📋 Status plików .env:" -ForegroundColor Cyan

$files = @(
    @{Path="C:\myai\.env"; Name="MASTER"; Required=$true},
    @{Path="D:\myai\.env"; Name="APPLICATION"; Required=$true},
    @{Path="D:\myai\agents\conversational-agent\.env.local"; Name="AGENT"; Required=$false}
)

foreach ($file in $files) {
    $exists = Test-Path $file.Path
    $status = if ($exists) { "✅" } elseif ($file.Required) { "❌" } else { "➖" }
    
    Write-Host "$status $($file.Name): $($file.Path)" -ForegroundColor $(
        if ($exists) { "Green" } 
        elseif ($file.Required) { "Red" } 
        else { "Gray" }
    )
    
    if ($exists) {
        $size = (Get-Item $file.Path).Length
        $count = (Get-Content $file.Path | Where-Object {$_ -match "^[A-Z_]+=" -and $_ -notmatch "^#"}).Count
        Write-Host "   Rozmiar: $size bajtów, Zmiennych: $count" -ForegroundColor Gray
    }
}
```

---

## 🆘 TROUBLESHOOTING

### Problem 1: "Missing OPENAI_API_KEY"

```powershell
# Sprawdź czy MASTER .env istnieje
Test-Path C:\myai\.env

# Jeśli NIE, sync z Google Drive
C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1

# Sprawdź czy zmienna jest w pliku
Select-String -Path "C:\myai\.env" -Pattern "OPENAI_API_KEY"
```

### Problem 2: "Google Drive .env not found"

```powershell
# Sprawdź czy Google Drive jest zamontowany
Test-Path "G:\Mój dysk"

# Sprawdź dokładną ścieżkę
Test-Path "G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env"
```

### Problem 3: "D:\myai\.env not found"

```powershell
# Skopiuj szablon
Copy-Item "D:\myai\.env.template" "D:\myai\.env"

# Edytuj
code "D:\myai\.env"
```

### Problem 4: Agent nie widzi zmiennych

```python
# Debug - sprawdź co jest załadowane
import os
from pathlib import Path

print(f"C:\\myai\\.env exists: {Path('C:/myai/.env').exists()}")
print(f"D:\\myai\\.env exists: {Path('D:/myai/.env').exists()}")
print(f"OPENAI_API_KEY: {'SET' if os.getenv('OPENAI_API_KEY') else 'NOT SET'}")

# Przeładuj
from dotenv import load_dotenv
load_dotenv("C:/myai/.env", override=True)
load_dotenv("D:/myai/.env", override=True)
```

---

## 📚 DOKUMENTACJA

Pełna dokumentacja:
- 📖 **C:\myAI_System\docs\quickref\ENV-MANAGEMENT.md** - Quick reference
- 📖 **C:\myAI_System\docs\architecture\20251108182000-env-management.md** - Szczegółowa dokumentacja
- 🔧 **C:\myAI_System\scripts\config\sync-env-from-gdrive.ps1** - Skrypt synchronizacji

Szablony:
- 📄 **C:\myAI_System\templates\.env.master.template** - Szablon MASTER (tylko do dokumentacji)
- 📄 **D:\myai\.env.template** - Szablon APPLICATION (skopiuj do D:\myai\.env)

Config:
- ⚙️  **C:\myAI_System\config\integration-config.json** - Konfiguracja integracji

---

## 🎯 PODSUMOWANIE

```
✅ UZUPEŁNIONE (Gotowe):
   C:\myai\.env (MASTER)
   - 29 zmiennych
   - Wszystkie API keys, hasła, tokeny
   - Zsynchronizowany z Google Drive

📝 DO UTWORZENIA (Raz na projekt):
   D:\myai\.env (APPLICATION)
   - Skopiuj z D:\myai\.env.template
   - Edytuj config (porty, ścieżki, log levels)
   - Można commitować

🧪 OPCJONALNE (Na potrzeby):
   D:\myai\agents\{name}\.env.local (AGENT)
   - Tylko dla lokalnych testów
   - NIE commitować
```

---

**Status**: ✅ System gotowy do użycia  
**Next**: Stwórz D:\myai\.env z template i rozpocznij pracę!
