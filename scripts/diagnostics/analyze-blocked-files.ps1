#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Wyjaśnia zablokowane pliki i oferuje bezpieczne usunięcie
#>

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🔍 ZABLOKOWANE PLIKI - ANALIZA" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$localAppData = $env:LOCALAPPDATA

$blockedFiles = @(
    @{
        Path = "C:\ProgramData\USOShared"
        Service = "UsoSvc"
        ServiceName = "Update Orchestrator Service"
        Description = "Windows Update - cache i logi"
        Safe = "TAK - można wyłączyć tymczasowo"
        Impact = "Brak - cache będzie odtworzony"
    },
    @{
        Path = "C:\ProgramData\USOPrivate"
        Service = "UsoSvc"
        ServiceName = "Update Orchestrator Service"
        Description = "Windows Update - prywatne dane"
        Safe = "TAK - można wyłączyć tymczasowo"
        Impact = "Brak - cache będzie odtworzony"
    },
    @{
        Path = (Join-Path $localAppData "Comms")
        Process = "CrossDeviceService"
        ServiceName = "Microsoft Cross Device Service"
        Description = "Synchronizacja między urządzeniami Windows"
        Safe = "TAK - jeśli nie używasz"
        Impact = "Historia synchronizacji zostanie usunięta"
    },
    @{
        Path = (Join-Path $localAppData "ConnectedDevicesPlatform")
        Process = "PhoneExperienceHost"
        ServiceName = "Microsoft Phone Link"
        Description = "Połączenie z telefonem Android/iPhone"
        Safe = "TAK - jeśli nie używasz Phone Link"
        Impact = "Historia aktywności telefonu zostanie usunięta"
    }
)

Write-Host "📋 ZABLOKOWANE PLIKI:`n" -ForegroundColor Yellow

foreach ($file in $blockedFiles) {
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Gray
    Write-Host "📁 $($file.Path)" -ForegroundColor White
    
    if ($file.Service) {
        $svc = Get-Service -Name $file.Service -ErrorAction SilentlyContinue
        if ($svc) {
            Write-Host "   🔧 Usługa: $($file.ServiceName) ($($file.Service))" -ForegroundColor Cyan
            Write-Host "   📊 Status: $($svc.Status) ($($svc.StartType))" -ForegroundColor $(if ($svc.Status -eq 'Running') { 'Yellow' } else { 'Green' })
        }
    }
    
    if ($file.Process) {
        $proc = Get-Process -Name $file.Process -ErrorAction SilentlyContinue
        if ($proc) {
            Write-Host "   🔧 Proces: $($file.ServiceName) ($($file.Process))" -ForegroundColor Cyan
            Write-Host "   📊 PID: $($proc.Id)" -ForegroundColor Yellow
        }
    }
    
    Write-Host "   📝 Co to: $($file.Description)" -ForegroundColor Gray
    Write-Host "   ✅ Bezpieczne: $($file.Safe)" -ForegroundColor Green
    Write-Host "   ⚠️  Wpływ: $($file.Impact)" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "❓ CO ZROBIĆ?" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "1️⃣  POZOSTAW - to cache systemowy, niewielki rozmiar" -ForegroundColor Gray
Write-Host "2️⃣  USUŃ - zatrzyma usługi, wyczyści, uruchomi ponownie" -ForegroundColor Yellow
Write-Host "3️⃣  ANULUJ - wróć do menu`n" -ForegroundColor White

Write-Host "Wybór (1/2/3): " -ForegroundColor Yellow -NoNewline
$choice = Read-Host

switch ($choice) {
    "1" {
        Write-Host "`n✅ OK - pozostawiam pliki systemowe`n" -ForegroundColor Green
        exit
    }
    "2" {
        Write-Host "`n🗑️  Zatrzymuję usługi i czyszczę...`n" -ForegroundColor Yellow
        
        # Zatrzymaj usługi
        Write-Host "   🛑 Zatrzymuję UsoSvc..." -NoNewline
        Stop-Service -Name "UsoSvc" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host " ✅" -ForegroundColor Green
        
        Write-Host "   🛑 Zatrzymuję CrossDeviceService..." -NoNewline
        Get-Process -Name "CrossDeviceService" -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host " ✅" -ForegroundColor Green
        
        Write-Host "   🛑 Zatrzymuję PhoneExperienceHost..." -NoNewline
        Get-Process -Name "PhoneExperienceHost" -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host " ✅" -ForegroundColor Green
        
        Start-Sleep -Seconds 3
        
        # Usuń foldery
        $totalMB = 0
        foreach ($file in $blockedFiles) {
            if (Test-Path $file.Path) {
                try {
                    $size = (Get-ChildItem $file.Path -Recurse -Force -File -ErrorAction SilentlyContinue | 
                             Measure-Object -Property Length -Sum).Sum / 1MB
                    
                    Write-Host "   🗑️  $(Split-Path $file.Path -Leaf)..." -NoNewline
                    Remove-Item $file.Path -Force -Recurse -ErrorAction Stop
                    Write-Host " ✅ $([math]::Round($size, 2)) MB" -ForegroundColor Green
                    $totalMB += $size
                } catch {
                    Write-Host " ⚠️  Częściowo usunięto" -ForegroundColor Yellow
                }
            }
        }
        
        # Uruchom ponownie usługi
        Write-Host "`n   🔄 Uruchamiam UsoSvc..." -NoNewline
        Start-Service -Name "UsoSvc" -ErrorAction SilentlyContinue
        Write-Host " ✅" -ForegroundColor Green
        
        Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
        Write-Host "✅ ZAKOŃCZONO" -ForegroundColor Cyan
        Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan
        Write-Host "   💾 Zwolniono: $([math]::Round($totalMB, 2)) MB" -ForegroundColor Green
        Write-Host "   📝 Cache systemowy będzie odtworzony automatycznie`n" -ForegroundColor Gray
    }
    default {
        Write-Host "`n❌ Anulowano`n" -ForegroundColor Red
    }
}
