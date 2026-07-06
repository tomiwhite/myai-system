# Cross-Layer Integration Guide

**Integracja między C:\myAI_System a D:\myai**

## 🎯 Architektura dwuwarstwowa

### System Layer (C:\myAI_System)
- **Rola:** System Management Agent
- **Zakres:** Infrastruktura, dyski, zasoby systemowe
- **Agent:** System-level automation

### Application Layer (D:\myai)
- **Rola:** Multi-Agent Ecosystem
- **Zakres:** Agenci AI, logika biznesowa, ewaluacja
- **Agenci:** Conversational agents, task agents

## 🔗 Punkty integracji

### 1. Monitoring dysków

**System Layer → Application Layer:**
```powershell
# System Agent monitoruje D:\myai
Get-Content "C:\myAI_System\reports\disk-analysis\latest.json"
# Zawiera: wolne miejsce, duże pliki, rekomendacje
```

**Alertowanie:**
- Gdy D:\ < 50GB → Alert do Application Layer
- Gdy D:\ < 20GB → Critical, zatrzymaj nieistotne procesy

### 2. Czyszczenie cache

**Współpraca:**
```
Application Layer Request:
"Potrzebuję więcej miejsca na D:\myai\data"

System Layer Response:
1. Skanuje D:\myai\**\__pycache__
2. Czyści stare cache (>30 dni)
3. Raportuje ile odzyskano
```

**Automatyzacja:**
- Codziennie: czyszczenie __pycache__
- Co tydzień: czyszczenie D:\myai\data\cache
- Co miesiąc: archiwizacja starych logów

### 3. Backup konfiguracji

**Flow:**
```
D:\myai\shared\config\*.json
        ↓
    (backup)
        ↓
C:\myAI_System\backups\d-drive-configs\YYYYMMDDHHMMSS-*.json
```

**Co jest backupowane:**
- D:\myai\requirements.txt
- D:\myai\shared\config\*.json
- D:\myai\agents\*\config.json
- D:\myai\.env (jeśli istnieje)

### 4. Health Monitoring

**System Agent sprawdza:**
```json
{
  "d_drive_agents": {
    "conversational-agent": {
      "status": "active",
      "last_run": "2025-11-08T18:00:00",
      "errors": 0
    }
  },
  "resources": {
    "disk_d_free_gb": 344.66,
    "disk_d_percent_free": 36.13
  }
}
```

### 5. Cross-Layer Workflows

#### Przed uruchomieniem agenta (D:\myai):
1. System Agent: sprawdź wolne miejsce
2. System Agent: sprawdź dostępną pamięć RAM
3. System Agent: zweryfikuj Python venv
4. Application Layer: uruchom agenta

#### Po zakończeniu agenta:
1. Application Layer: zapisz logi
2. System Agent: cleanup temp files
3. System Agent: archiwizuj logi jeśli >7 dni
4. System Agent: update metrics

#### Periodic Maintenance (co 24h):
1. System Agent: cleanup __pycache__ w D:\myai
2. System Agent: cleanup D:\myai\data\cache (>30 dni)
3. System Agent: backup configs
4. System Agent: generuj raport health

## 📊 Raporty ekosystemu

**Dzienny raport (C:\myAI_System\docs\reports\YYYYMMDDHHMMSS-ecosystem-health.md):**

```markdown
# Ecosystem Health Report

## D:\myai Status
- Disk Space: 344GB free (36%)
- Active Agents: conversational-agent
- Cache Size: 2.3GB
- Last Cleanup: 2025-11-08

## System Resources
- CPU: 23%
- RAM: 62%
- Disk C:\: 345GB free

## Recommendations
- ⚠️ OneDrive zajmuje 809GB - rozważ optymalizację
- ✅ Agent cache w normie
- ✅ Python venv aktualne
```

## 🤖 API komunikacji

### System Layer oferuje:

**Endpoints (pliki JSON):**
```
GET C:\myAI_System\reports\disk-analysis\latest.json
GET C:\myAI_System\reports\performance\latest.json
GET C:\myAI_System\config\integration-config.json
```

**Actions (PowerShell functions):**
```powershell
# Application Layer może wywołać:
Invoke-SystemCleanup -Target "D:\myai\data\cache"
Get-SystemMetrics -Include "disk,memory,cpu"
Request-Backup -Source "D:\myai\shared\config"
```

### Application Layer oferuje:

**Status endpoints:**
```
GET D:\myai\agents\conversational-agent\status.json
GET D:\myai\evaluation\results\latest.json
GET D:\myai\tracing\metrics\latest.json
```

## 🔄 Przykładowy workflow

### Scenario: Agent potrzebuje więcej miejsca

1. **Application Layer (D:\myai):**
   ```python
   disk_status = read_json("C:/myAI_System/reports/disk-analysis/latest.json")
   if disk_status['d_drive_free_gb'] < 10:
       request_cleanup()
   ```

2. **System Layer (C:\myAI_System):**
   ```powershell
   # Otrzymano request_cleanup
   $cleaned = Cleanup-DriveDCache
   Save-Report "docs/reports/$timestamp-cleanup-d-drive.md"
   ```

3. **Confirmation:**
   ```json
   {
     "cleanup_completed": true,
     "space_freed_gb": 5.2,
     "new_free_space_gb": 349.86
   }
   ```

## 📝 Konfiguracja w kodzie

### Python (Application Layer):
```python
# D:\myai\shared\utils\system_integration.py
import json

def get_disk_status():
    with open(r"C:\myAI_System\reports\disk-analysis\latest.json") as f:
        return json.load(f)

def request_cleanup(target="cache"):
    # Tworzy plik żądania
    with open(r"C:\myAI_System\requests\cleanup-request.json", "w") as f:
        json.dump({"target": target, "timestamp": datetime.now()}, f)
```

### PowerShell (System Layer):
```powershell
# C:\myAI_System\scripts\monitoring\watch-d-drive.ps1
function Watch-DMyaiEcosystem {
    $config = Get-Content "C:\myAI_System\config\integration-config.json" | ConvertFrom-Json
    
    # Monitor disk space
    $disk = Get-PSDrive D
    if ($disk.Free -lt ($config.communication.alert_thresholds.d_drive_low_space_gb * 1GB)) {
        Send-Alert "Low disk space on D:\myai"
    }
}
```

## 🎯 Korzyści integracji

✅ **Proaktywne zarządzanie zasobami**
✅ **Automatyczne czyszczenie i optymalizacja**
✅ **Wspólne raporty i monitoring**
✅ **Cross-layer automation**
✅ **Centralized backups**
✅ **Health monitoring całego ekosystemu**

## 📅 Implementacja

**Faza 1 (Teraz):**
- ✅ Konfiguracja integracji
- ✅ Mapowanie D:\myai
- ✅ Podstawowy monitoring

**Faza 2 (Następne):**
- [ ] Automatyczne czyszczenie
- [ ] Backupy konfiguracji
- [ ] Health reports

**Faza 3 (Przyszłość):**
- [ ] API komunikacji
- [ ] Cross-layer workflows
- [ ] Automatyczna optymalizacja

---

**Wersja:** 1.0
**Utworzono:** 2025-11-08
**Ostatnia aktualizacja:** 2025-11-08
