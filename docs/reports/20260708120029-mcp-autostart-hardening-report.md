# Raport: MCP And Autostart Hardening

**Data**: 2026-07-08 12:00:29
**Typ**: operational-stability
**Srodowisko**: Windows 11, VS Code, Task Scheduler, myAI_System

## Podsumowanie

Przeprowadzono twarde uporzadkowanie autostartu i zrodel bledow obciazajacych sesje. Pozostawiono tylko jeden stabilny task uruchamiajacy workspace `C:\myAI_System` bez automatycznego uruchamiania agent-chat i bez wymuszonych restartow.

## Symptomy

- powtarzajace sie bledy i spowolnienia po starcie VS Code
- task wymuszajacy restart systemu
- task uruchamiajacy automatycznie `code chat --mode agent`
- bledy runtime rozszerzenia Microsoft Edge Tools

## Wykonane dzialania

1. Wylaczenie taskow niestabilnych:
- `Planned-Restart-MCP-VSCode`
- `VSCode-AutoRestore-AgentCheck`

2. Wdrozenie bezpiecznego autostartu:
- nowy task: `myAI-System-SafeAutostart` (AtLogOn + 45s)
- nowy skrypt: `scripts/startup/start-myai-system-safe.ps1`

3. Czyszczenie rozszerzen:
- odinstalowano `ms-edgedevtools.vscode-edge-devtools`

## Walidacja

- `myAI-System-SafeAutostart` -> `Ready`, `Enabled=True`
- test uruchomienia safe script -> `Safe autostart completed`
- `reports/post-restart-check.txt` utworzony i zawiera polityke:
  - `no-auto-chat`
  - `no-forced-restart`

## Ryzyka rezydualne

- czesc bledow MCP moze pochodzic z zewnetrznych konfiguracji per-user/per-profile poza repo
- po stronie operatora pozostaje decyzja, ktore narzedzia/serwery MCP maja byc uruchamiane recznie tylko na zadanie

## Rekomendacja

Utrzymac obecny model: autostart tylko workspace i narzedzia bazowe, a serwery MCP uruchamiac selektywnie po potwierdzonej konfiguracji.
