# Disk Monitor Agent

Agent odpowiedzialny za monitorowanie dysków systemowych.

## 🎯 Zadania

1. **Monitoring dysków**
   - C:\ (system)
   - D:\ (dane użytkownika)
   - Inne dyski w systemie

2. **Analiza wykorzystania**
   - Największe foldery
   - Duże pliki (>500MB)
   - Stare pliki (>2 lata)
   - Potencjalne duplikaty

3. **Alerty**
   - Ostrzeżenie gdy <20% wolnego miejsca
   - Wykrywanie szybkiego wzrostu
   - Nietypowa aktywność

## 📊 Raporty

Agent generuje raporty w: `C:\myAI_System\reports\disk-analysis\`

Format: JSON + podsumowanie tekstowe

## 📈 Statystyki

Monitorowane metryki:
- Wolne miejsce (GB i %)
- TOP 10 największych folderów
- TOP 15 największych plików
- Typy plików (rozmiar według rozszerzeń)

## 🔄 Harmonogram

- **Co godzinę**: Szybka analiza (miejsce, alerty)
- **Co dzień**: Pełna analiza struktury
- **Co tydzień**: Raport trendów
