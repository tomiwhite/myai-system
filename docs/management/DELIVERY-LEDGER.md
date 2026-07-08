# Delivery Ledger

Stały rejestr zmian projektowych, produkcyjnych i governance dla C:\myAI_System.

## 2026-07-06

### Diagnostics Risk Review And Hardening Direction

- Status: done
- Category: diagnostics, safety, assessment
- Scope:
  - wykonano przegląd ryzyk dla skryptów diagnostycznych i cleanup
  - sklasyfikowano skrypty na bezpieczne, świadome i wysokiego ryzyka
  - zidentyfikowano główne luki: twarde ścieżki użytkownika, słabe heurystyki cleanup i niespójne raportowanie
- Key Files:
  - `docs/reports/20260706225911-diagnostics-risk-review.md`
  - `docs/work-logs/20260706230259-session-roadmap.md`
- Validation:
  - przegląd kodu skryptów
  - publikacja raportu opisowego z rekomendacjami

## 2026-07-07

### Baseline Automation And Functional Mapping

- Status: done
- Category: automation, documentation, operations
- Scope:
  - dodano bezpieczny runner `run-system-baseline-check.ps1`
  - dodano mapę funkcjonalną systemu i szybką dokumentację operatora
  - utrwalono guardraile dla pracy bezpiecznej przed cleanup i zmianami systemowymi
- Key Files:
  - `scripts/startup/run-system-baseline-check.ps1`
  - `docs/quickref/SYSTEM-FUNCTIONALITY-MAP.md`
  - `docs/work-logs/20260707001256-system-functionality-and-automation.md`
- Validation:
  - parser PowerShell
  - walidator nazewnictwa
  - baseline checks w trybach bezpiecznych

### PowerToys Restore, Ollama Recovery And Post-Reload Verification

- Status: done
- Category: recovery, tooling, environment
- Scope:
  - przywrócono konfigurację PowerToys AdvancedPaste z backupu
  - zainstalowano i zweryfikowano Ollama oraz podłączono realny model store z `P:\_AI_MODELS\ollama`
  - zaktualizowano PowerShell do 7.6.3 i spisano checklistę post-reload
- Key Files:
  - `docs/work-logs/20260707012705-post-reload-task-list.md`
  - `docs/quickref/POST-RELOAD-CHECKLIST.md`
  - `docs/quickref/SCRIPT-MAP.md`
- Validation:
  - `winget list --id Microsoft.PowerShell -e`
  - `http://127.0.0.1:11434/api/tags`
  - test E2E `ollama run llama3`

### Repository Hygiene For Local Recovery Artifacts

- Status: done
- Category: repository, hygiene, backup-handling
- Scope:
  - zablokowano przypadkowe commitowanie lokalnych backupów PowerToys
  - dodano regułę ignorowania katalogów `PowerToys-current-*`
- Key Files:
  - `.gitignore`
- Validation:
  - `git status --short`
  - push na `origin/main`

### Reporting Governance Hardening

- Status: done
- Category: governance, documentation, automation
- Scope:
  - dodano trwałą warstwę `docs/management/`
  - zaostrzono politykę raportowania w `AI_RULES.md` i `.github/copilot-instructions.md`
  - rozszerzono walidator nazewnictwa o `docs/management`
  - dopisano widoczne artefakty sesji do work-log i reports
- Key Files:
  - `AI_RULES.md`
  - `.github/copilot-instructions.md`
  - `scripts/validation/validate-naming-rules.ps1`
  - `docs/management/REPORTING-POLICY.md`
  - `docs/management/DELIVERY-LEDGER.md`
- Validation:
  - walidator nazewnictwa
  - przegląd struktury docs i zgodności klas raportowania

### Governance Discoverability Index

- Status: done
- Category: governance, documentation, discoverability
- Scope:
  - dodano stały indeks governance dla szybkiego wejścia operatora
  - podłączono indeks do README i mapy skryptów
  - poprawiono czytelność sekcji struktury docs w README
- Key Files:
  - `docs/quickref/GOVERNANCE-INDEX.md`
  - `README.md`
  - `docs/quickref/SCRIPT-MAP.md`
- Validation:
  - przegląd linków dokumentacyjnych
  - zgodność z polityką raportowania

## 2026-07-08

### Governance Entry Points In Quickstart Layer

- Status: done
- Category: governance, documentation, onboarding
- Scope:
  - dodano widoczne wejście governance do `QUICKSTART.md`
  - dodano sekcję governance do `docs/QUICK-INFO.txt`
  - podłączono `ENV-MANAGEMENT.md` do polityki raportowania
- Key Files:
  - `QUICKSTART.md`
  - `docs/QUICK-INFO.txt`
  - `docs/quickref/ENV-MANAGEMENT.md`
- Validation:
  - walidator nazewnictwa
  - przegląd linków i rozróżnienia warstw dokumentacji

### VS Code Terminal And Docker WSL Recovery

- Status: done
- Category: recovery, environment, operations
- Scope:
  - usunieto glowny trigger odtwarzania sesji VS Code z nieistniejacej sciezki `G:\Moj dysk\myOffice_system\myOffice`
  - przywrocono runtime Docker Desktop i WSL (`docker-desktop`)
  - zweryfikowano aktualny stan danych Dockera na `C:` i `P:`
- Key Files:
  - `docs/work-logs/20260708082618-vscode-docker-wsl-recovery.md`
  - `docs/reports/20260708082618-vscode-docker-wsl-recovery-report.md`
- Validation:
  - `wsl -l -v`
  - `docker context ls`
  - `docker info --format "{{.DockerRootDir}} | {{.OperatingSystem}} | {{.ServerVersion}}"`

### Docker Path Finalization, Git Identity Fallback And PowerToys Recovery

- Status: done
- Category: recovery, configuration, operations
- Scope:
  - przygotowano i utrwalono bezpieczna konfiguracje Docker Engine (`daemon` JSON) dla Desktop 29.6.1
  - dodano instrukcje operacyjne dla `Resources -> Advanced`, `File sharing` i scenariusza konsolidacji danych WSL Dockera
  - zweryfikowano, ze duze obrazy VHDX na `P:` sa duplikatem historycznym i nie nalezy ich scalac na poziomie plikow
  - ustawiono globalny fallback tozsamosci Git (`user.name`, `user.email`) dla repo bez lokalnej konfiguracji
  - wykonano recovery PowerToys/FancyZones (backup stanu, restart modulow, ograniczenie konfliktu drag-hook przez wylaczenie GrabAndMove)
  - dodano automatyczny changelog HTML dla warstwy management
- Key Files:
  - `config/docker-desktop-engine.safe.json`
  - `docs/quickref/DOCKER-DESKTOP-SETTINGS.md`
  - `docs/work-logs/20260708115315-ops-closure-docker-git-powertoys.md`
  - `docs/reports/20260708115315-ops-closure-docker-git-powertoys-report.md`
  - `docs/management/CHANGELOG-AUTO.html`
  - `.instal_files/.instal_mymcp/TASKS.md`
- Validation:
  - `docker info`
  - `wsl --status`
  - `wsl -l -v --all`
  - `git var GIT_AUTHOR_IDENT`
  - `git var GIT_COMMITTER_IDENT`
  - restart PowerToys i potwierdzenie procesu `PowerToys.FancyZones`


