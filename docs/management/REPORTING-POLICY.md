# Reporting Policy

## Cel

Ten katalog rozdziela stale governance projektu od raportow runtime i dziennikow sesji.

## Klasy dokumentow

### 1. docs/work-logs/

- przebieg sesji AI / operatora
- co zostalo zrobione, sprawdzone i zwalidowane
- pliki zawsze z timestampem

### 2. docs/reports/

- raporty wynikowe z diagnostyki, cleanup, rolloutow, aktualizacji i przegladow ryzyk
- dokumenty punktowe dla konkretnego przebiegu
- pliki zawsze z timestampem

### 3. docs/management/

- stale dokumenty governance
- polityki, ledger zmian, statusy delivery, zasady klasyfikacji
- pliki bez timestampu

## Kiedy AI musi zapisac wpis

1. Zmiana nietrywialna w repo:
- wymagany wpis w docs/work-logs/

2. Zmiana produkcyjna, rozbudowa, aktualizacja, governance, automatyzacja:
- wymagany wpis w docs/work-logs/
- wymagany update docs/management/DELIVERY-LEDGER.md

3. Diagnostyka, audit, cleanup, rollout albo update z wnioskami:
- wymagany wpis w docs/reports/

## Zasady rozroznienia

- Jeśli dokument opisuje przebieg pracy: work-log.
- Jeśli dokument opisuje wynik operacyjny lub stan po wykonaniu: report.
- Jeśli dokument ma byc trwala polityka lub rejestrem zmian projektu: management.

## Minimalny standard wpisu do ledgera

- data
- scope
- kategoria zmiany
- najwazniejsze pliki
- walidacja
- status
