# Raport: Diagnostics And Cleanup Risk Review

**Data**: 2026-07-06
**Zakres**: `scripts/diagnostics/*`, pomocniczo `scripts/config/*` i `scripts/startup/*`

## Najwazniejsze wnioski

- Projekt ma dobry podzial na skrypty odczytowe i modyfikujace, ale granica bezpieczenstwa nie zawsze jest wystarczajaco twarda.
- Najwieksze ryzyko nie wynika z pojedynczego `Remove-Item`, tylko z heurystyk: dopasowanie po nazwie katalogu, brak wspolnej safelisty i twarde sciezki do profilu uzytkownika.
- Launchery byly czesciowo nieaktualne wzgledem nowej dystrybucji VS Code z wbudowanym Copilotem; poprawione w tej sesji.

## Findings

### Krytyczne

1. `auto-cleanup-orphaned.ps1` i `deep-cleanup-admin.ps1` usuwaja katalogi na podstawie slabych heurystyk, a nie na podstawie jawnej listy zatwierdzonych celow.
   Miejsca: `scripts/diagnostics/auto-cleanup-orphaned.ps1:382`, `scripts/diagnostics/deep-cleanup-admin.ps1:103`, `scripts/diagnostics/deep-cleanup-admin.ps1:182`, `scripts/diagnostics/deep-cleanup-admin.ps1:271`, `scripts/diagnostics/deep-cleanup-admin.ps1:308`.
   Ryzyko: falszywie dodatnie rozpoznanie osieroconego katalogu i usuniecie nadal potrzebnych danych aplikacji lub wpisow rejestru.

2. Kilka skryptow jest twardo zwiazanych z profilem `C:\Users\tomiw`, przez co repo nie jest bezpiecznie przenaszalne na innego uzytkownika lub maszyne.
   Miejsca: `scripts/diagnostics/cleanup-safe-junk.ps1:17-57`, `scripts/diagnostics/analyze-blocked-files.ps1:29`, `scripts/diagnostics/analyze-blocked-files.ps1:37`, `scripts/diagnostics/reinstall-three-apps.ps1:16-28`, `scripts/diagnostics/deep-system-audit.ps1:21-25`.
   Ryzyko: brak efektu na innym koncie albo usuniecie danych nie tego profilu, ktory byl zamierzony.

### Wysokie

1. `auto-cleanup.ps1` i `audit-permissions.ps1` modyfikuja ACL, ownership i execution policy bez wspolnego dry-run lub wspolnej warstwy potwierdzenia.
   Miejsca: `scripts/diagnostics/auto-cleanup.ps1:61`, `scripts/diagnostics/auto-cleanup.ps1:79-80`, `scripts/diagnostics/audit-permissions.ps1:168-169`, `scripts/diagnostics/audit-permissions.ps1:203`, `scripts/diagnostics/audit-permissions.ps1:322`, `scripts/diagnostics/auto-fix-issues.ps1:25`.
   Ryzyko: nadpisanie lokalnej polityki bezpieczenstwa lub niezamierzona eskalacja uprawnien w katalogach roboczych.

2. `remove-euvkbd-driver.ps1` ma dobry tryb dry run, ale w trybie wykonania uzywa `takeown`, `icacls`, `Remove-Item` i opcjonalnie `Restart-Computer -Force`.
   Miejsca: `scripts/diagnostics/remove-euvkbd-driver.ps1:130-148`, `scripts/diagnostics/remove-euvkbd-driver.ps1:168`.
   Ryzyko: trudne do odwrocenia zmiany w sterownikach i mozliwy restart w zlym momencie.

3. `reinstall-three-apps.ps1` probuje budowac ciche odinstalowanie na podstawie `UninstallString`, co nie jest uniwersalnie poprawne dla wszystkich instalatorow.
   Miejsca: `scripts/diagnostics/reinstall-three-apps.ps1:52-66`.
   Ryzyko: nieskuteczna deinstalacja albo uruchomienie zlych parametrow uninstallera.

### Srednie

1. `audit-permissions.ps1` i `quick-permissions-check.ps1` zawieraja sprzeczne zalozenia co do poprawnego adresu Git email.
   Miejsca: `scripts/diagnostics/audit-permissions.ps1:89-96`, `scripts/diagnostics/quick-permissions-check.ps1:18-19`, `scripts/diagnostics/auto-fix-issues.ps1:40-42`.
   Ryzyko: automatyczne poprawianie Git config w zlym kierunku.

2. `deep-cleanup-admin.ps1` zapisuje raport `.json` do `docs/reports/`, chociaz konwencja projektu rozdziela opisowe MD do `docs/reports/` i techniczne JSON do `reports/`.
   Miejsce: `scripts/diagnostics/deep-cleanup-admin.ps1:337`.
   Ryzyko: rozjazd z `AI_RULES.md` i niejednoznacznosc, gdzie szukac raportow technicznych.

3. `sync-env-from-gdrive.ps1` jest poprawny funkcjonalnie, ale zalezy od jednej stalej sciezki Google Drive i loguje nazwy pierwszych zmiennych po synchronizacji.
   Miejsca: `scripts/config/sync-env-from-gdrive.ps1:19-21`, `scripts/config/sync-env-from-gdrive.ps1:136-139`.
   Ryzyko: slabiej przenaszalna konfiguracja i ujawnienie nazw kluczy konfiguracyjnych w logu terminala.

### Niskie

1. `create-desktop-shortcuts.vbs` tworzy skrot do `C:\myAI`, ktorego nie ma w tym workspace.
   Miejsce: `scripts/startup/create-desktop-shortcuts.vbs:47-63`.
   Ryzyko: martwy skrot po instalacji na maszynie bez tego katalogu.

2. `start-myai-application-d.ps1` nadal zalezy od istnienia `D:\myai`; w tym srodowisku nie moglem wykonac pelnego testu end-to-end.
   Ryzyko: brak walidacji praktycznej drugiego launchera na tej maszynie.

## Co jest bezpieczne do regularnego uruchamiania

- `scripts/validation/validate-naming-rules.ps1`
- `scripts/diagnostics/quick-permissions-check.ps1`
- `scripts/diagnostics/deep-system-audit.ps1`
- `scripts/diagnostics/remove-euvkbd-driver.ps1` bez `-Execute`

## Co uruchamiac tylko swiadomie

- `scripts/diagnostics/auto-fix-issues.ps1`
- `scripts/diagnostics/audit-permissions.ps1 -Fix`
- `scripts/diagnostics/cleanup-safe-junk.ps1`
- `scripts/diagnostics/analyze-blocked-files.ps1`

## Co traktowac jako skrypty wysokiego ryzyka

- `scripts/diagnostics/auto-cleanup.ps1`
- `scripts/diagnostics/auto-cleanup-orphaned.ps1`
- `scripts/diagnostics/deep-cleanup-admin.ps1`
- `scripts/diagnostics/remove-euvkbd-driver.ps1 -Execute`

## Rekomendowane nastepne kroki

1. Ujednolicic polityke Git email w `quick-permissions-check.ps1`, `audit-permissions.ps1` i `auto-fix-issues.ps1`.
2. Wyniesc wszystkie sciezki `C:\Users\tomiw\...` do jednej warstwy konfiguracji opartej o `$env:USERPROFILE`.
3. Dodac wspolny `-DryRun` i wspolny logger do skryptow cleanup.
4. Zmienic raport JSON z `deep-cleanup-admin.ps1` tak, aby trafial do `reports/cleanup/` zamiast do `docs/reports/`.