# Post-Reload Checklist

Szybka lista kontrolna po restarcie systemu, aktualizacji narzedzi albo przywracaniu konfiguracji.

## 1) PowerShell

- Sprawdz wersje:
  - `pwsh -NoLogo -NoProfile -Command "$PSVersionTable.PSVersion.ToString()"`
- Sprawdz pakiet:
  - `winget list --id Microsoft.PowerShell -e --accept-source-agreements`
- Oczekiwane: `7.6.3` (albo nowsza)

## 2) Ollama backend

- Sprawdz API:
  - `Invoke-RestMethod http://127.0.0.1:11434/api/tags | ConvertTo-Json -Depth 4`
- Oczekiwane: lista modeli zawiera co najmniej jeden wpis (np. `llama3:latest`)

## 3) Ollama E2E

- Test generacji:
  - `C:\Users\tomiw\AppData\Local\Programs\Ollama\ollama.exe run llama3 "Napisz tylko: OK-OLLAMA"`
- Oczekiwane: odpowiedz `OK-OLLAMA`

## 4) PowerToys AdvancedPaste

- Sprawdz modul globalnie:
  - `%LOCALAPPDATA%\Microsoft\PowerToys\settings.json` -> `"AdvancedPaste": true`
- Sprawdz akcje i AI:
  - `%LOCALAPPDATA%\Microsoft\PowerToys\AdvancedPaste\settings.json`
  - musi byc `transcode-to-mp3`
  - endpoint AI: `http://localhost:11434/`

## 5) Open WebUI

- Sprawdz konfiguracje:
  - `P:\_PROJECTS\open-webui\docker-compose.yml`
- Oczekiwane:
  - `OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api`
  - `OLLAMA_BASE_URL=http://host.docker.internal:11434`

## Minimalny flow naprawczy (gdy cos nie dziala)

1. Uruchom Ollama ponownie (proces lub aplikacja) i zweryfikuj API `/api/tags`.
2. Jesli modele zniknely: sprawdz mapowanie `P:\_AI_MODELS\blobs` i `P:\_AI_MODELS\manifests`.
3. Zrestartuj PowerToys i ponownie sprawdz `AdvancedPaste/settings.json`.
4. Jesli `ollama` nie dziala z PATH: uzyj pelnej sciezki do `ollama.exe`.
