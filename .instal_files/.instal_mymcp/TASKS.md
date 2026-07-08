# Kolejka zadan naprawczych po restarcie (2026-07-08)

## P0 - VS Code: ENOPRO / unknown:/ brak dostawcy systemu plikow
Status: IN_PROGRESS
Objaw: "ENOPRO: Nie znaleziono dostawcy systemu plikow dla zasobu unknown:/.vscode/settings.json"

Kroki:
1. Otworzyc poprawny katalog roboczy zamiast pustego/unknown:
   - File -> Open Folder -> C:\myAI_System
   - albo: code -r C:\myAI_System
2. Zapisac workspace w repo:
   - File -> Save Workspace As -> C:\myAI_System\myai-system.code-workspace
3. Wylaczyc filtry ukrywajace czaty i problemy:
   - panel Chat: wyczysc filtry i ograniczenia widoku
   - panel Problems: pokaz "All" i "Current Workspace"
4. Ustabilizowac autostart:
   - task autostartu ma uruchamiac code z jawna sciezka C:\myAI_System

Postep:
- zaktualizowano skrypt autostartu, aby otwieral C:\myAI_System\myai-system.code-workspace (fallback: C:\myAI_System)
- task VSCode-AutoRestore-AgentCheck jest aktywny (Ready)
- dodano lokalne instrukcje agenta: C:\myAI_System\AGENTS.md

Kryterium Done:
- brak wpisow unknown:/ w Problems
- brak ENOPRO dla unknown:/
- po restarcie VS Code otwiera C:\myAI_System od razu

---

## P1 - WSL / Docker Desktop (bledy po starcie)
Status: IN_PROGRESS
Objawy z logu:
- open /etc/ld.so.conf.d/ld.wsl.conf failed 2
- tzdata missing (Europe/Warsaw)
- serie misc dxg ioctl failed

Diagnoza:
- To glownie dotyczy dystrybucji docker-desktop (technicznej), nie glowniej dystrybucji deweloperskiej.
- Czesc wpisow to ostrzezenia kernelowe i nie blokuje pracy VS Code.

Kroki naprawcze:
1. Aktualizacja WSL i restart uslugi:
   - wsl --update
   - wsl --shutdown
2. Sprawdzenie dystrybucji i wersji:
   - wsl -l -v
3. Jezeli docker-desktop nadal spamuje logami, zrob restart Docker Desktop.
4. Jezeli wymagane: naprawa strefy czasowej w dystrybucji roboczej (nie w docker-desktop):
   - sudo apt update && sudo apt install -y tzdata
5. Dla dxg ostrzezen: jesli nie uzywasz GPU w WSL, zostawic jako low-priority monitorowane.

Postep:
- wykonano: wsl --update (aktualna wersja)
- wykonano: wsl --shutdown
- wykryto tylko docker-desktop jako domyslna dystrybucja
- ustawiono globalnie w C:\Users\tomiw\.wslconfig: dnsTunneling=true, debugConsole=false (mniej szumu i lepsza stabilnosc DNS)

Kryterium Done:
- WSL startuje bez bledow krytycznych
- brak nowych bledow, ktore zatrzymuja terminal lub VS Code
- ewentualne dxg pozostaja tylko jako warningi

---

## P1 - Git identity alert w VS Code (user.name / user.email)
Status: DONE
Objaw:
- VS Code pokazuje popup: "Upewnij się, że skonfigurowano ustawienia user.name i user.email w usłudze Git."

Diagnoza (potwierdzona):
- Git dziala poprawnie w repo `C:\myAI_System`.
- Tozsamosc jest ustawiona lokalnie w `.git/config`:
  - `user.name=Copilot`
  - `user.email=45501831+tomiwhite@users.noreply.github.com`
- Repo jest poprawnie polaczone z `origin` i `ls-remote` działa.

Kroki naprawcze:
1. Sprawdzic, czy alert dotyczy innego folderu/repo otwartego w VS Code (np. poza `C:\myAI_System`).
2. Ustawic globalnie fallback identity (na wypadek nowych repo bez local config):
   - `git config --global user.name "Copilot"`
   - `git config --global user.email "45501831+tomiwhite@users.noreply.github.com"`
3. Zweryfikowac Source Control po restart VS Code:
   - brak popup przy commit z `C:\myAI_System`
   - `git config --show-origin --get-regexp "^user\.(name|email)$"` zwraca global lub local

Kryterium Done:
- brak popupu o `user.name/user.email` podczas commit
- commit testowy przechodzi bez bledu tozsamosci

Wynik:
- ustawiono globalny fallback identity:
   - `git config --global user.name "Copilot"`
   - `git config --global user.email "45501831+tomiwhite@users.noreply.github.com"`
- potwierdzono `GIT_AUTHOR_IDENT` i `GIT_COMMITTER_IDENT`

---

## P1 - 22 problemy w panelu (markdownlint + konfiguracja)
Status: DONE
Zakres:
- Plik: C:\Users\tomiw\Downloads\MAPA_SYSTEMU_MCP_CLAUDE.md
- Reguly: MD022, MD032, MD031, MD060

Kroki:
1. Naprawic format markdown w pliku MAPA_SYSTEMU_MCP_CLAUDE.md:
   - dodac puste linie wokol naglowkow/list/fenced code
   - ujednolicic tabele pod MD060
2. Uporzadkowac scope Problems:
   - oddzielic bledy workspace od bledow w Downloads
3. Ograniczyc hałas lintera tylko tam, gdzie trzeba:
   - opcjonalnie konfiguracja markdownlint dla katalogu roboczego

Kryterium Done:
- liczba problemow spada do zera lub do akceptowalnego minimum
- brak krytycznych bledow konfiguracji

Wynik:
- MAPA_SYSTEMU_MCP_CLAUDE.md: brak bledow (No errors found)

---

## P2 - Stabilizacja autostartu VS Code + autowolanie agenta
Status: IN_PROGRESS
Cel:
- po restarcie uruchamia sie dokladnie ostatnia sesja C:\myAI_System i odpala automatyczny prompt kontrolny

Kroki:
1. W tasku logowania uruchamiac:
   - code -r C:\myAI_System
   - potem code chat --mode agent --reuse-window --maximize "...prompt kontrolny..."
2. Wyeliminowac restart z /f dla przyszlych testow (zachowac sesje aplikacji)
3. Dodac plik raportu po starcie (opcjonalnie):
   - C:\myAI_System\reports\post-restart-check.txt

Postep:
- skrypt autostartu zapisuje raport do C:\myAI_System\reports\post-restart-check.txt
- skrypt uruchamia auto-verification prompt przez code chat --mode agent

---

## P0 - Docker Engine / WSL storage na P:\
Status: IN_PROGRESS
Cel:
- przeniesc dane Dockera z C:\Users\tomiw\AppData\Local\Docker\wsl na P:\DockerEngine\DockerDesktopWSL

Postep:
- przygotowano pusty katalog docelowy dla Docker Desktop UI: `P:\DockerEngine\DockerDesktopWSL` (folder pusty, gotowy pod Browse/redirect)
- zachowano kopie danych: `P:\DockerEngine\DockerDesktopWSL_old_20260708101340` (2 pliki VHDX, ~35.4 GB)
- stale istnieje dodatkowa duplikata `P:\DockerDesktopWSL` (~35.4 GB), obecnie zablokowana przez proces (nie udalo sie jej przeniesc/zmienic nazwy)
- potwierdzono, ze dwa duze obrazy na P sa duplikatem: identyczny rozmiar `docker_data.vhdx` (37887148032 bytes) i ten sam timestamp
- scalanie dwoch VHDX na poziomie plikow NIE jest bezpieczne; nalezy wybrac 1 obraz kanoniczny i drugi trzymac jako archiwum

Konfiguracja i instrukcja operatora:
- gotowy bezpieczny plik Docker Engine JSON: `C:\myAI_System\config\docker-desktop-engine.safe.json`
- szybka instrukcja Resources/File sharing + konsolidacja: `C:\myAI_System\docs\quickref\DOCKER-DESKTOP-SETTINGS.md`

Kryterium Done:
- redirect w Docker Desktop UI przechodzi bez bledu `Invalid path already exists`
- po redirect: `docker info` dziala stabilnie po restarcie
- pozostaje jedna kanoniczna lokalizacja danych WSL Dockera na P:\

Aktualny status (2026-07-08 09:38):
- WSL odpowiada poprawnie (`wsl --status`, `wsl -l -v --all`).
- `docker-desktop` jest uruchomiony.
- `docker info` dziala: `root=/var/lib/docker`, `ver=29.6.1`.
- Popup `DockerDesktop/Wsl/CommandTimedOut` przestal byc reprodukowalny po naprawie domyslnej dystrybucji WSL.

Pozostalo do domkniecia (kontrolowane):
1. Ustawic docelowe `Disk image location` w Docker Desktop UI przez `Browse` (zgodnie z decyzja operatora: `P:\DockerEngine` lub `P:\DockerDesktopWSL`).
2. Po zmianie przez UI wykonac walidacje:
   - restart Docker Desktop,
   - `wsl -l -v --all`,
   - `docker info`.
3. Jezeli po zmianie wystapi 500/timeout, natychmiast rollback do ostatniego dzialajacego stanu i ponowna migracja przez natywny workflow Docker Desktop.

Aktualizacja operatora (2026-07-08, pozniej):
- operator ustawil `Disk image location` na: `P:\DockerDesktopWSL\DockerDesktopWSL`
- wymagane pozostaje potwierdzenie dlugoterminowej stabilnosci po kolejnym restarcie Docker Desktop

---

## P1 - PowerToys FancyZones blokowanie drag/snap
Status: DONE

Objaw:
- okresowe wrazenie blokowania podczas pracy z FancyZones

Dzialania:
1. Sprawdzono runtime modulow PowerToys i logi FancyZones.
2. Wykonano backup ustawien FancyZones do `backups/config-backups/powertoys-fancyzones-20260708105348/`.
3. Zrestartowano PowerToys.
4. Wylaczono modul `GrabAndMove`, zeby ograniczyc konflikt hookow przeciagania.

Wynik:
- `PowerToys.FancyZones` uruchamia sie poprawnie po restarcie.
- konfiguracja konfliktowa zostala ograniczona bez usuwania glownej konfiguracji PowerToys.

Kryterium Done:
- po restarcie nie trzeba recznie szukac chatu
- agent-check uruchamia sie sam

