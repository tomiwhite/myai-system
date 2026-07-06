# Work Log: Post-Reload Task List
**Data**: 2026-07-07 01:27:05

## Utworzona lista zadań (4)
1. [DONE] Aktualizacja PowerShell do 7.6.3
2. [DONE] Walidacja instalacji i wersji PowerShell
3. [DONE] Walidacja toru AI (Ollama + modele + E2E prompt)
4. [DONE] Walidacja PowerToys AdvancedPaste i integracji Open WebUI

## Dowody wykonania
- PowerShell:
  - winget list --id Microsoft.PowerShell -e => 7.6.3.0
  - pwsh uruchamiany z WindowsApps raportuje 7.6.3
- Ollama:
  - API http://127.0.0.1:11434/api/tags zwraca modele: mistral:latest, gemma3:1b, llama3:latest
  - E2E: C:\Users\tomiw\AppData\Local\Programs\Ollama\ollama.exe run llama3 "Napisz tylko: OK-OLLAMA" => OK-OLLAMA
- PowerToys AdvancedPaste:
  - AdvancedPaste: true w %LOCALAPPDATA%\Microsoft\PowerToys\settings.json
  - 	ranscode-to-mp3 obecne w %LOCALAPPDATA%\Microsoft\PowerToys\AdvancedPaste\settings.json
  - endpoint AI: http://localhost:11434/
- Open WebUI:
  - P:\_PROJECTS\open-webui\docker-compose.yml ma OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api

## Uwagi
- W aktualnej sesji terminala polecenie ollama może nie być na PATH, ale runtime działa i binarka jest dostępna pod ścieżką lokalną.
