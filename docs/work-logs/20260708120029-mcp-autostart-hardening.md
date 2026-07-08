# Work Log: MCP And Autostart Hardening

**Data**: 2026-07-08 12:00:29
**Zakres**: Stabilizacja autostartu i ograniczenie zrodel bledow MCP/VS Code.

## Cel sesji

- odciazyc startup po logowaniu i usunac niestabilne elementy
- zostawic tylko sprawdzony autostart workspace `C:\myAI_System`
- ograniczyc bledy runtime pochodzace z wadliwego rozszerzenia VS Code

## Co znaleziono

1. W harmonogramie aktywne byly taski:
- `Planned-Restart-MCP-VSCode` (wymuszony restart systemu `/f`)
- `VSCode-AutoRestore-AgentCheck` (uruchamial `code chat --mode agent`)

2. Rozszerzenie `ms-edgedevtools.vscode-edge-devtools` generowalo bledy runtime (`hint package`, `HTMLCanvasElement`), co moglo powodowac zamulanie.

## Dzialania naprawcze

1. Wylaczono niestabilne taski:
- `Planned-Restart-MCP-VSCode` -> Disabled
- `VSCode-AutoRestore-AgentCheck` -> Disabled

2. Utworzono bezpieczny task logowania:
- `myAI-System-SafeAutostart`
- trigger: `AtLogOn`, opoznienie `45s`
- akcja: uruchomienie `C:\myAI_System\scripts\startup\start-myai-system-safe.ps1`

3. Dodano nowy lekki skrypt startup:
- `scripts/startup/start-myai-system-safe.ps1`
- bez auto-agenta (`code chat`), bez restartow, tylko otwarcie workspace + raport

4. Usunieto problematyczne rozszerzenie:
- `code --uninstall-extension ms-edgedevtools.vscode-edge-devtools --force`

## Walidacja

- task `myAI-System-SafeAutostart` istnieje i jest `Ready/Enabled`
- skrypt safe wykonuje sie poprawnie i zapisuje:
  - `reports/post-restart-check.txt`
- raport zawiera:
  - `Mode: SAFE_AUTOSTART`
  - `TaskPolicy: no-auto-chat no-forced-restart`

## Wynik

Autostart zostal uporzadkowany do wersji stabilnej. Wylaczone zostaly mechanizmy, ktore mogly powodowac nadmiarowe obciazenie lub nieprzewidywalne zachowanie po starcie sesji.
