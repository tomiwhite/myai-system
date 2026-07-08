# Work Log: VS Code + Docker + WSL Recovery

**Data**: 2026-07-08 08:26:18
**Zakres**: Diagnostyka i naprawa problemu terminala VS Code (nieprawidlowy cwd) oraz niedostepnego Docker/WSL.

## Cel sesji

- usunac przyczyne startu terminala z nieistniejacej sciezki `G:\Moj dysk\myOffice_system\myOffice`
- przywrocic dzialanie Docker Desktop i WSL2
- zweryfikowac aktualny stan mapowania danych Dockera wzgledem dysku P:

## Wykonane kroki

1. Przejrzano profile VS Code w `%APPDATA%\Code\User\profiles\*\settings.json`.
2. Potwierdzono, ze przyczyna byla zwiazana z przywracaniem starych okien (`window.restoreWindows: all`) i stanem sesji.
3. Utworzono backupy ustawien VS Code do `backups/config-backups/`.
4. Zmieniono ustawienie `window.restoreWindows` na `none` w aktywnym pliku ustawien uzytkownika.
5. Uruchomiono Docker Desktop i zweryfikowano status uslugi `com.docker.service`.
6. Potwierdzono status WSL: `docker-desktop` przechodzi w `Running`.
7. Potwierdzono odpowiedz daemonu Dockera (`docker info`) i wersje serwera.
8. Sprawdzono lokalizacje danych WSL Dockera:
   - `C:\Users\tomiw\AppData\Local\Docker\wsl`
   - `P:\_CACHE\Docker\wsl`

## Wynik

- Srodowisko Docker/WSL zostalo przywrocone do stanu dzialania.
- Problem startu z martwym `G:` zostal ograniczony przez wylaczenie przywracania poprzednich okien.
- Potwierdzono rozjazd lokalizacji danych Dockera miedzy `C:` i `P:` (do dalszego uporzadkowania kontrolowanego).

## Ryzyka / Uwagi

- Przenoszenie VHDX Dockera miedzy `C:` i `P:` podczas aktywnej uslugi niesie ryzyko utraty spojnosci.
- Rekomendowana osobna operacja migracyjna z pelnym shutdown i walidacja po restarcie.

## Artefakty walidacyjne

- `wsl -l -v`
- `docker context ls`
- `docker info --format "{{.DockerRootDir}} | {{.OperatingSystem}} | {{.ServerVersion}}"`
