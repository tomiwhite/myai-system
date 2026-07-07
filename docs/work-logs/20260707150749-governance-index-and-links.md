# Work Log: Governance Index And Documentation Links

**Date**: 2026-07-07
**Session Goal**: Ułatwić odnajdywanie warstwy governance i statusu delivery bez przeszukiwania repo.

## Wykonane kroki

1. Dodano stały quickref `GOVERNANCE-INDEX.md` jako punkt wejścia do `docs/management/`.
2. Podłączono indeks do `README.md` oraz `docs/quickref/SCRIPT-MAP.md`.
3. Ujednolicono sekcję struktury dokumentacji w README.
4. Uzupełniono `DELIVERY-LEDGER.md` o wpis tej zmiany.

## Rezultat

- operator widzi od razu, gdzie jest polityka i rejestr zmian projektu
- governance jest rozdzielone od runtime i sesyjnych raportów
- zmiana ma ślad w work-logu i ledgerze zgodnie z aktualnym rygorem

## Walidacja do wykonania

1. Uruchomić `scripts/validation/validate-naming-rules.ps1`.
2. Potwierdzić status Git i opublikować commit.
