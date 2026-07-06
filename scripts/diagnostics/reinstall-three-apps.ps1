#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Odinstaluj i zainstaluj na nowo: Highlight, LM Studio, Audacity
#>

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🔄 REINSTALACJA: Highlight, LM Studio, AC Electron" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$localAppData = $env:LOCALAPPDATA

$apps = @(
    @{
        Name = "Highlight"
        UninstallName = "Highlight"
        DownloadUrl = "https://www.highlight.com/download"
        Updater = (Join-Path $localAppData "highlight-updater")
    },
    @{
        Name = "LM Studio"
        UninstallName = "LM Studio"
        DownloadUrl = "https://lmstudio.ai/download"
        Updater = (Join-Path $localAppData "lm-studio-updater")
    },
    @{
        Name = "AC Electron (Dashboard framework)"
        UninstallName = "ac-electron"
        DownloadUrl = "https://www.electronjs.org/"
        Updater = (Join-Path $localAppData "ac-electron-updater")
        Note = "Framework do dashboardów - sprawdź czy używasz"
    }
)

# ============================================================================
# CZĘŚĆ 1: ODINSTALUJ
# ============================================================================

Write-Host "🗑️  KROK 1: Odinstalowanie starych wersji...`n" -ForegroundColor Yellow

foreach ($app in $apps) {
    Write-Host "   Szukam: $($app.Name)..." -ForegroundColor Gray
    
    # Znajdź w rejestrze
    $regPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    
    $found = $false
    foreach ($regPath in $regPaths) {
        $uninstall = Get-ItemProperty $regPath -ErrorAction SilentlyContinue | 
                     Where-Object { $_.DisplayName -like "*$($app.UninstallName)*" } |
                     Select-Object -First 1
        
        if ($uninstall) {
            $found = $true
            Write-Host "      ✅ Znaleziono: $($uninstall.DisplayName)" -ForegroundColor Green
            
            if ($uninstall.UninstallString) {
                Write-Host "      🗑️  Odinstalowywanie..." -ForegroundColor Yellow
                
                # Uruchom uninstaller (cicho)
                $uninstallCmd = $uninstall.UninstallString -replace '/I', '/X' -replace 'msiexec.exe', ''
                
                try {
                    Start-Process "msiexec.exe" -ArgumentList "/X$uninstallCmd /quiet /norestart" -Wait -NoNewWindow -ErrorAction SilentlyContinue
                    Write-Host "      ✅ Odinstalowano" -ForegroundColor Green
                } catch {
                    # Spróbuj inaczej
                    try {
                        Start-Process $uninstall.UninstallString -ArgumentList "/S" -Wait -ErrorAction Stop
                        Write-Host "      ✅ Odinstalowano" -ForegroundColor Green
                    } catch {
                        Write-Host "      ⚠️  Uruchom ręcznie: $($uninstall.UninstallString)" -ForegroundColor Yellow
                    }
                }
            }
            break
        }
    }
    
    if (-not $found) {
        Write-Host "      ⚠️  Nie znaleziono w Panelu Sterowania" -ForegroundColor Yellow
    }
    
    # Usuń updater
    if (Test-Path $app.Updater) {
        Write-Host "      🗑️  Usuwam updater..." -NoNewline
        Remove-Item $app.Updater -Force -Recurse -ErrorAction SilentlyContinue
        Write-Host " ✅" -ForegroundColor Green
    }
    
    Write-Host ""
}

# ============================================================================
# CZĘŚĆ 2: POBIERZ I ZAINSTALUJ
# ============================================================================

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "📥 KROK 2: Pobieranie i instalacja...`n" -ForegroundColor Yellow

Write-Host "⚠️  UWAGA: Otworzę strony pobierania w przeglądarce" -ForegroundColor Yellow
Write-Host "   Pobierz najnowsze wersje i zainstaluj ręcznie`n" -ForegroundColor Gray

foreach ($app in $apps) {
    Write-Host "   📦 $($app.Name): $($app.DownloadUrl)" -ForegroundColor Cyan
}

Write-Host "`n❓ Otworzyć strony? (T/n): " -ForegroundColor Yellow -NoNewline
$confirm = Read-Host

if ($confirm -ne 'n') {
    foreach ($app in $apps) {
        Start-Process $app.DownloadUrl
        Start-Sleep -Seconds 2
    }
    
    Write-Host "`n✅ Strony otwarte w przeglądarce" -ForegroundColor Green
    Write-Host "   Pobierz i zainstaluj każdy program" -ForegroundColor Gray
    Write-Host "   Nowe wersje będą miały aktualne updatery`n" -ForegroundColor Gray
}

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "✅ GOTOWE" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
