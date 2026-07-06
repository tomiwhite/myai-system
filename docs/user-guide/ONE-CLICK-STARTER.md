# 🚀 ONE-CLICK STARTER - Instrukcja Użytkownika

**Dla użytkownika nietechnicznego** - Jak uruchomić myAI jednym kliknięciem

---

## 📋 Pierwsza Konfiguracja (RAZ NA ZAWSZE)

### Krok 1: Utwórz ikony na pulpicie

1. Otwórz **Eksplorator Windows**
2. Przejdź do: `C:\myAI_System\scripts\startup\`
3. **Kliknij dwukrotnie** plik: `create-desktop-shortcuts.vbs`
4. Zobaczysz komunikat: "✅ Utworzono: 🖥️ myAI System (C).lnk"
5. Zobaczysz komunikat: "✅ Utworzono: 🤖 myAI Application (D).lnk"

✅ **GOTOWE!** Na pulpicie pojawiły się 2 nowe ikony.

---

## 🖱️ Codzienne Używanie (PROSTE)

### Ikona 1: 🖥️ myAI System (C)

**Kiedy kliknąć:**
- Gdy chcesz zarządzać systemem Windows (czyszczenie, monitoring, diagnostyka)
- Gdy chcesz sprawdzić raporty i logi systemu
- Gdy chcesz skonfigurować `.env` lub backupy

**Co się stanie:**
1. Otworzy się **kolorowe okno PowerShell** (nie zamykaj!)
2. Zobaczyć sprawdzanie:
   - ✅ Katalogi
   - ✅ Plik .env
   - ✅ VS Code
   - ✅ Rozszerzenia
   - ✅ Python
3. Po 5-10 sekundach otworzy się **VS Code**
4. Workspace: `C:\myAI_System`

**Co dalej:**
- Możesz pracować z AI Asysentem (GitHub Copilot / Windsurf)
- Plik aktualny: Tam gdzie skończyłeś ostatnio
- Terminal gotowy: Na dole VS Code

---

### Ikona 2: 🤖 myAI Application (D)

**Kiedy kliknąć:**
- Gdy chcesz pracować z agentami AI (conversational, evaluation, etc.)
- Gdy chcesz uruchamiać kod Python
- Gdy chcesz rozwijać aplikację myAI

**Co się stanie:**
1. Otworzy się **kolorowe okno PowerShell** (nie zamykaj!)
2. Zobaczyć sprawdzanie:
   - ✅ Katalogi projektu
   - ✅ Pliki .env (MASTER i APPLICATION)
   - ✅ Python i Virtual Environment
   - ✅ VS Code i rozszerzenia
3. Jeśli **brakuje venv** - zostanie utworzony automatycznie
4. Jeśli **brakują pakiety** - zostaną zainstalowane z requirements.txt
5. Po 5-10 sekundach otworzy się **VS Code**
6. Workspace: `D:\myai`

**Co dalej:**
- Python venv jest **automatycznie aktywowany**
- Możesz uruchamiać agentów i kod Python
- AI Asystent jest gotowy do pracy

---

## 💡 Co Robi Każda Ikona (Pod Maską)

### 🖥️ myAI System (C)
```
1. Sprawdza strukturę C:\myAI_System
2. Synchronizuje .env z Google Drive (jeśli nowszy)
3. Sprawdza VS Code, rozszerzenia, Python, Git
4. Pokazuje status ostatniej sesji (work-log, raporty)
5. Otwiera VS Code z workspace C:\myAI_System
6. Wyświetla powitanie z instrukcjami
```

### 🤖 myAI Application (D)
```
1. Sprawdza strukturę D:\myai
2. Sprawdza oba .env (C:\myai i D:\myai)
3. Sprawdza Python i tworzy venv jeśli brakuje
4. Instaluje pakiety z requirements.txt
5. Sprawdza VS Code i rozszerzenia Python
6. Otwiera VS Code z workspace D:\myai + aktywny venv
7. Wyświetla powitanie z instrukcjami
```

---

## 🔧 Co Jeśli Coś Pójdzie Nie Tak?

### Problem: "VS Code nie znaleziony"
**Rozwiązanie:**
1. Zainstaluj VS Code: https://code.visualstudio.com/
2. Uruchom ponownie ikonę

### Problem: "Python nie znaleziony"
**Rozwiązanie:**
1. Zainstaluj Python 3.13+: https://www.python.org/downloads/
2. Przy instalacji **ZAZNACZ**: "Add Python to PATH"
3. Uruchom ponownie ikonę

### Problem: "Google Drive .env not found"
**Rozwiązanie:**
1. Sprawdź czy Google Drive jest włączony
2. Sprawdź czy plik istnieje: `G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env`
3. Jeśli brakuje, skopiuj template: `C:\myAI_System\templates\.env.master.template`

### Problem: "Brakuje rozszerzenia w VS Code"
**Nie martw się!** Starter zainstaluje je automatycznie przy pierwszym uruchomieniu.

---

## 📚 Gdzie Znaleźć Pomoc?

### W VS Code (po uruchomieniu):
- **C:\myAI_System\QUICKSTART.md** - Szybki start
- **C:\myAI_System\docs\** - Pełna dokumentacja
- **D:\myai\README.md** - O projekcie aplikacji

### Pliki pomocy:
- `C:\myAI_System\docs\quickstart\AGENT-STARTUP-ENV.md` - Jak działa .env
- `C:\myAI_System\docs\quickref\ENV-MANAGEMENT.md` - Zarządzanie zmiennymi
- `C:\myAI_System\docs\diagrams\ENV-SCHEMA.txt` - Schemat .env

### AI Asystent:
Po uruchomieniu VS Code możesz zapytać AI Asystenta:
- "Pokaż mi co robimy w tym projekcie"
- "Co znajduje się w ostatnim work-log?"
- "Jak uruchomić agenta?"
- "Wyjaśnij strukturę projektu"

---

## 🎯 Typowy Dzień Pracy

### Rano:
1. **Kliknij ikonę** (C lub D, w zależności co robisz)
2. **Poczekaj 10 sekund** na sprawdzenie i otwarcie VS Code
3. **Zapytaj AI Asystenta**: "Gdzie skończyliśmy ostatnio?"
4. **Kontynuuj pracę**

### Podczas pracy:
- AI Asystent podpowiada i pisze kod
- Wszystko zapisuje się automatycznie
- Logi i raporty trafiają do właściwych miejsc

### Wieczorem:
- Po prostu **zamknij VS Code**
- Następnego dnia wszystko będzie czekało gdzie zostawiłeś

---

## ⚙️ Automatyka (Co Się Dzieje Samo)

✅ **Synchronizacja .env** - Jeśli Google Drive ma nowszą wersję
✅ **Tworzenie venv** - Jeśli jeszcze nie istnieje
✅ **Instalacja pakietów** - Z requirements.txt automatycznie
✅ **Instalacja rozszerzeń VS Code** - Przy pierwszym uruchomieniu
✅ **Aktywacja Python venv** - W terminalu VS Code
✅ **Backupy .env** - Codziennie automatycznie (przez System Layer)

---

## 🎨 Co Oznaczają Kolory w Oknie PowerShell?

- **🟢 Zielony (✅)** - Wszystko OK
- **🔵 Niebieski (ℹ️)** - Informacja
- **🟡 Żółty (⚠️)** - Ostrzeżenie (coś można poprawić, ale działa)
- **🔴 Czerwony (❌)** - Błąd (wymaga działania)

---

## 🚀 Pro Tips

1. **Nie zamykaj okna PowerShell** podczas sprawdzania - zamknie się samo po 5 sekundach
2. **Czytaj komunikaty** - pokazują co się dzieje
3. **Jeśli coś czerwone** - przeczytaj komunikat, często podaje rozwiązanie
4. **Używaj AI Asystenta** w VS Code - on wie co robić
5. **Work-logi** - zawsze pokazują gdzie skończyłeś ostatnio

---

## 📞 Emergency Plan

Jeśli **wszystko się sypie**:

1. Zamknij VS Code
2. Kliknij ponownie ikonę
3. Przeczytaj komunikaty w oknie PowerShell
4. Zapytaj AI Asystenta: "System mi nie działa, co robić?"

Jeśli **dalej nie działa**:

1. Otwórz: `C:\myAI_System\docs\work-logs\`
2. Zobacz ostatni work-log (najnowsza data)
3. Tam jest zapisane co robiłeś ostatnio

---

## ✅ Checklist Przed Pierwszym Użyciem

- [ ] VS Code zainstalowany
- [ ] Python 3.13+ zainstalowany (z "Add to PATH")
- [ ] Google Drive włączony i zsynchronizowany
- [ ] Plik .env istnieje: `G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env`
- [ ] Ikony utworzone na pulpicie (run `create-desktop-shortcuts.vbs`)

Jeśli wszystko ✅ - **GOTOWE DO PRACY!** 🚀

---

**Pytania?** Zapytaj AI Asystenta w VS Code po uruchomieniu! 🤖
