# Script Map

## Start i workspace

- `scripts/startup/start-myai-system-c.ps1` - glowny starter dla `C:\myAI_System`; sprawdza katalogi, `.env`, VS Code, rozszerzenia, Python, Git, walidator i otwiera workspace.
- `scripts/startup/start-myai-application-d.ps1` - starter dla `D:\myai`; sprawdza `.env`, Python, `venv`, rozszerzenia VS Code i otwiera workspace aplikacyjny.
- `scripts/startup/create-desktop-shortcuts.vbs` - tworzy skroty pulpitu do obu starterow oraz skrot Docker.

## Konfiguracja `.env`

- `scripts/config/sync-env-from-gdrive.ps1` - synchronizacja `.env` do `C:\myai\.env`; sciezka Google Drive czytana z `config/system-config.json` (override przez `MYAI_GDRIVE_ENV`); obsluguje `-DryRun`, robi backup i ustawia plik jako read-only.

## Bezpieczna diagnostyka

- `scripts/validation/validate-naming-rules.ps1` - najpierw uruchamiaj po zmianach w repo; sprawdza zgodnosc z `AI_RULES.md`.
- `scripts/diagnostics/quick-permissions-check.ps1` - najtanszy check srodowiska; Git, PowerShell, .NET, skroty, zapis do repo, `.env`, `D:\myai`, Google Drive.
- `scripts/diagnostics/deep-system-audit.ps1` - szeroki odczyt stanu systemu, uprawnien i pozostalosci po programach; bez automatycznych napraw; raport techniczny JSON zapisuje do `reports/permissions/`.
- `scripts/diagnostics/audit-permissions.ps1` - audyt uprawnien z opcjonalnym `-Fix`; przed zmianami ACL zapisuje backup do `backups/config-backups/`; uruchamiac tylko swiadomie jako admin.

## Naprawy i zmiany konfiguracji

- `scripts/diagnostics/auto-fix-issues.ps1` - szybkie automatyczne poprawki lokalnego srodowiska, np. execution policy, martwe skroty, `.env`; obsluguje `-WhatIf`, backupuje execution policy i loguje zmiany do `logs/`.
- `scripts/diagnostics/remove-euvkbd-driver.ps1` - targetowana remediacja sterownika `EuVKbd.sys`; domyslnie dry run, wykonanie tylko z `-Execute`; przed usuwaniem tworzy backup artefaktow i manifest w `backups/config-backups/euvkbd-backup-*`.
- `scripts/diagnostics/reinstall-three-apps.ps1` - odinstalowanie i ponowne otwarcie stron instalacyjnych dla wskazanych aplikacji.

## Cleanup o nizszym ryzyku

- `scripts/diagnostics/analyze-blocked-files.ps1` - analizuje blokowane cache systemowe i pyta, czy je czyscic.
- `scripts/diagnostics/cleanup-safe-junk.ps1` - interaktywne czyszczenie wskazanych folderow cache/updaterow; tylko jako admin; obsluguje `-DryRun` i zapisuje manifest przed usuwaniem.

## Cleanup o wyzszym ryzyku

- `scripts/diagnostics/auto-cleanup.ps1` - modyfikuje ACL, usuwa wybrane foldery i wpisy rejestru; wymaga admina; obsluguje `-DryRun`, zapisuje manifest planowanych akcji i backupuje klucz rejestru (reg export) przed usunieciem.
- `scripts/diagnostics/auto-cleanup-orphaned.ps1` - heurystycznie usuwa foldery po odinstalowanych programach; obsluguje `-DryRun` i zapisuje manifest celow przed usuwaniem.
- `scripts/diagnostics/deep-cleanup-admin.ps1` - najbardziej inwazyjny cleanup; interaktywnie usuwa katalogi z `Program Files`, `ProgramData`, `AppData` i wpisy rejestru; raport JSON zapisywany do `reports/cleanup/`.

## Kolejnosc pracy

1. `scripts/validation/validate-naming-rules.ps1`
2. `scripts/diagnostics/quick-permissions-check.ps1`
3. `scripts/diagnostics/deep-system-audit.ps1` albo `scripts/diagnostics/audit-permissions.ps1`
4. Dopiero potem wybrany cleanup lub skrypt naprawczy

## Czego nie uruchamiac w ciemno

- Nie uruchamiaj `deep-cleanup-admin.ps1`, `auto-cleanup.ps1`, `auto-cleanup-orphaned.ps1` ani `remove-euvkbd-driver.ps1 -Execute` bez backupu i bez sprawdzenia listy zmian.
- Nie uruchamiaj startera `D:\myai`, jesli katalog `D:\myai` i jego `.env` nie istnieja.