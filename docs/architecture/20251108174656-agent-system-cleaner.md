# System Cleaner Agent

Agent odpowiedzialny za czyszczenie systemu Windows.

## 🎯 Zadania

1. **Czyszczenie cache i temp**
   - Windows Temp
   - npm cache
   - pip cache
   - VS Code cache
   - Copilot cache

2. **Usuwanie starych node_modules**
   - Projekty nieużywane >3 miesiące
   - Automatyczne wykrywanie
   - Backup przed usunięciem

3. **Zarządzanie instalacjami**
   - Wykrywanie duplikatów Python
   - Usuwanie starych wersji
   - Czyszczenie nieużywanych pakietów

4. **Optymalizacja PATH**
   - Usuwanie duplikatów
   - Czyszczenie nieistniejących ścieżek
   - Backup przed modyfikacją

## 📊 Raporty

Agent generuje raporty w: `C:\myAI_System\reports\cleanup-logs\`

## 🔄 Harmonogram

- **Codziennie**: Czyszczenie cache
- **Co tydzień**: Analiza node_modules
- **Co miesiąc**: Pełna diagnostyka systemu

## 🛡️ Bezpieczeństwo

- Wszystkie operacje są logowane
- Backupy przed każdą zmianą
- Potwierdzenie przed usunięciem >10GB
