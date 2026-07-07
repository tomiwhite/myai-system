# Raport: Reporting Governance Update

**Data**: 2026-07-07
**Zakres**: dokumentacja governance, polityka raportowania, automatyzacja walidacji

## Problem

Projekt nie miał czytelnej, trwałej warstwy dokumentowania zmian produkcyjnych i rozwojowych wykonywanych przez AI. Istniały work-logi i raporty diagnostyczne, ale brakowało stałego ledgera i jawnych reguł klasyfikacji wpisów.

## Zmiana

1. Dodano warstwę `docs/management/` dla governance i ledgera zmian.
2. Doprecyzowano obowiązki AI w `.github/copilot-instructions.md`.
3. Doprecyzowano reguły repo w `AI_RULES.md`.
4. Rozszerzono walidator, aby znał `docs/management/` jako katalog dokumentów stałych.

## Nowy podział odpowiedzialności dokumentów

- `docs/work-logs/` - przebieg sesji
- `docs/reports/` - raporty wynikowe i operacyjne
- `docs/management/` - governance, polityki, ledger zmian produkcyjnych i rozwojowych

## Efekt operacyjny

- łatwiej odróżnić prace nad budową / rozbudową projektu od diagnostyki runtime
- zmiany AI stają się widoczne bez przeszukiwania całego repo
- reguły raportowania są już spięte z automatyzacją i walidacją
