# Raport: Recovery terminala VS Code + Docker/WSL

**Data**: 2026-07-08 08:26:18
**Typ**: operational-recovery
**Srodowisko**: Windows 11, VS Code, Docker Desktop, WSL2

## Podsumowanie

Wykonano interwencje przywracajaca dostepnosc terminala i daemonu Docker. Glowne symptomy to start sesji z nieistniejacej sciezki Google Drive oraz brak pipe `dockerDesktopLinuxEngine`.

## Symptomy wejsciowe

- terminal VS Code probowal uruchamiac sesje z `G:\Moj dysk\myOffice_system\myOffice` (sciezka nieistniejaca lokalnie)
- `wsl -l -v`: `docker-desktop` w stanie `Stopped`
- `docker info`: brak polaczenia z daemonem (`dockerDesktopLinuxEngine`)

## Root cause (operacyjny)

1. Odtwarzanie poprzednich okien VS Code powodowalo probę odtworzenia starego kontekstu sesji.
2. Docker Desktop/WSL nie byly aktywnie uruchomione po zmianach srodowiskowych.
3. Dane WSL Dockera nie sa jednoznacznie zunifikowane na `P:` (rownolegle widoczne struktury na `C:` i `P:`).

## Dzialania naprawcze

1. Backup ustawien VS Code wykonany do `backups/config-backups/`.
2. Ustawienie `window.restoreWindows` zmienione na `none`.
3. Uruchomiony Docker Desktop i zweryfikowana usluga `com.docker.service`.
4. Walidacja runtime Docker/WSL po starcie.

## Wynik walidacji

- `wsl -l -v`: `docker-desktop` -> `Running`
- `docker context ls`: kontekst `desktop-linux` aktywny
- `docker info`: poprawna odpowiedz (`/var/lib/docker | Docker Desktop | 29.6.1`)

## Stan po interwencji

- Krytyczna funkcjonalnosc Docker/WSL przywrocona.
- Ryzyko terminala z martwym `G:` istotnie zredukowane przez wyłączenie restore windows.
- Pozostaje temat porzadkowania mapowania danych Dockera na `P:` jako osobna, kontrolowana migracja.

## Zalecenie nastepne

Przeprowadzic dedykowany maintenance window na migracje/ujednolicenie `C:\Users\tomiw\AppData\Local\Docker\wsl` -> `P:\_CACHE\Docker\wsl` z pelnym shutdown (`wsl --shutdown`, stop uslugi Docker) i walidacja po restarcie.
