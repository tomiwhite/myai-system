# myAI System Management

**Główny katalog zarządzania systemem na poziomie C:\**

---

## 🚀 QUICK START - Użytkownik Nietechniczny

### Jak Uruchomić? (ONE-CLICK)

**Na pulpicie znajdziesz 2 ikony:**

1. **🖥️ myAI System (C).lnk**
   - Kliknij gdy chcesz zarządzać systemem Windows
   - Otwiera: C:\myAI_System w VS Code
   - Dokumentacja: `docs/user-guide/ONE-CLICK-STARTER.md`

2. **🤖 myAI Application (D).lnk**
   - Kliknij gdy chcesz pracować z agentami AI
   - Otwiera: D:\myai w VS Code (z Python venv)
   - Wszystko instaluje się automatycznie!

**Brak ikon?** Uruchom: `scripts/startup/create-desktop-shortcuts.vbs`

📖 **Pełna instrukcja**: [ONE-CLICK-STARTER.md](docs/user-guide/ONE-CLICK-STARTER.md)

---

## 🎯 Cel

Ten katalog zawiera narzędzia i agenty odpowiedzialne za:
- 🧹 Czyszczenie i optymalizację systemu Windows
- 📊 Monitoring dysków i zasobów
- 🔧 Zarządzanie instalacjami i konfiguracją
- 📈 Raporty wydajności i diagnostyka
- 💾 Backupy konfiguracji systemowych

## 📁 Struktura

```
myAI_System/
├── agents/                    # Agenci systemowi
│   ├── system-cleaner/        # Agent czyszczący system
│   ├── disk-monitor/          # Agent monitorujący dyski
│   └── performance-optimizer/ # Agent optymalizujący wydajność
├── reports/                   # Raporty diagnostyczne
│   ├── disk-analysis/         # Analizy dysków C:\, D:\, etc.
│   ├── performance/           # Raporty wydajności
│   └── cleanup-logs/          # Logi czyszczenia
├── backups/                   # Backupy konfiguracji
│   ├── path-backups/          # Backupy zmiennej PATH
│   ├── registry-backups/      # Backupy rejestru
│   └── config-backups/        # Backupy konfiguracji
├── scripts/                   # Skrypty automatyzacyjne
│   ├── startup/               # 🚀 ONE-CLICK STARTERS (ikony na pulpicie)
│   ├── config/                # Sync .env, konfiguracje
│   ├── diagnostics/           # Skrypty diagnostyczne
│   ├── cleanup/               # Skrypty czyszczące
│   └── monitoring/            # Skrypty monitorujące
├── config/                    # Konfiguracje agentów
├── logs/                      # Logi operacji
└── docs/                      # 📚 Dokumentacja
    ├── user-guide/            # Instrukcje dla użytkownika
    ├── quickstart/            # Szybki start
    ├── quickref/              # Szybkie odniesienia
    ├── architecture/          # Dokumentacja architektury
    ├── work-logs/             # Historia pracy
    └── diagrams/              # Schematy i diagramy
```

## 🔗 Integracja z ekosystemem myAI

Ten katalog działa równolegle z:
- **D:\myai\** - ekosystem multi-agentowy (agent/multi-agent)
- **Repozytoria i serwisy** - zarządzane przez strukturę na D:\

## 🔑 Zarządzanie Zmiennymi Środowiskowymi

**Hierarchia plików .env**:
```
C:\myai\.env           ← MASTER (✅ 29 zmiennych - wszystkie API keys)
D:\myai\.env           ← APPLICATION (config projektu)
agents/{name}/.env.local ← AGENT (opcjonalne nadpisania)
```

**Quick Start**:
- 📖 Szczegóły: `docs/quickstart/AGENT-STARTUP-ENV.md`
- 🔧 Sync: `scripts/config/sync-env-from-gdrive.ps1`
- 📊 Diagram: `docs/diagrams/ENV-SCHEMA.txt`

## 🤖 Agent Systemowy (System Management Agent)

Agent na poziomie C:\ odpowiada za:
1. **Zarządzanie całą maszyną** - instalacje, konfiguracje, optymalizacje
2. **Monitoring systemu** - dyski, pamięć, CPU, procesy
3. **Automatyczne czyszczenie** - cache, temp, stare pliki
4. **Backupy systemowe** - PATH, rejestry, konfiguracje
5. **Raportowanie** - stan systemu, diagnostyka, rekomendacje

## 🚀 Docelowa replikacja

Struktura jest zaprojektowana do replikacji na:
- Komputery wirtualne (Windows 11)
- Serwery zdalne
- Autonomiczna obsługa systemu myAI

## 📅 Historia

- **2025-11-08**: Utworzenie struktury bazowej
- **2025-11-08**: Diagnostyka dysków C:\ i D:\
- **2025-11-08**: Migracja z SystemCleanup do myAI_System

## 📝 Notatki

- Wszystkie operacje systemowe wykonywane przez AI są logowane
- Backupy tworzone są automatycznie przed zmianami
- Raporty generowane w formacie JSON dla łatwej analizy
