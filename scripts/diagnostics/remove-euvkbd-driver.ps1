#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Usuwa niezgodny sterownik EuVKbd.sys (Avid) z systemu (usługa, Driver Store, pliki)
.DESCRIPTION
  Wykrywa pakiety oem*.inf powiązane z euvkbd.inf / EuVKbd.sys, zatrzymuje usługę EuVKbd,
  odinstalowuje pakiet z Driver Store (pnputil), usuwa pozostałości (\System32\drivers, DriverStore\FileRepository),
  i wykonuje weryfikację. Domyślnie działa w trybie DRY RUN (bez zmian), aby wykazać co zrobi.
.PARAMETER Execute
  Wykonuje operacje usuwania. Bez tej flagi skrypt tylko raportuje (Dry Run).
.PARAMETER Force
  Wymusza /force i kontynuuje mimo ostrzeżeń; podejmie próbę przejęcia uprawnień do plików.
.PARAMETER Reboot
  Jeśli pnputil zgłosi konieczność restartu – wykona restart po zakończeniu.
#>
param(
  [switch]$Execute,
  [switch]$Force,
  [switch]$Reboot
)

$ErrorActionPreference = 'SilentlyContinue'
$runTimestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$backupRoot = "C:\myAI_System\backups\config-backups\euvkbd-backup-$runTimestamp"

Write-Host "`n═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "🛠  REMEDIACJA: EuVKbd.sys (Avid)" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════`n" -ForegroundColor Cyan

$dry = -not $Execute
if ($dry) { Write-Host "DRY RUN – nie wprowadzę zmian. Użyj -Execute aby wykonać." -ForegroundColor Yellow }

# Helpers
function Find-EuVKbdPublishedNames {
  # Budujemy listę bloków pnputil i znajdujemy te, które zawierają euvkbd.inf lub EuVKbd.sys, albo Publisher Avid
  $lines = pnputil /enum-drivers | ForEach-Object { $_ }
  $blocks = @()
  $current = @()
  foreach ($ln in $lines) {
    if ($ln -match '^Published Name\s*:') {
      if ($current.Count) { $blocks += ,@($current); $current = @() }
    }
    $current += $ln
  }
  if ($current.Count) { $blocks += ,@($current) }

  $hits = @()
  foreach ($block in $blocks) {
    $text = ($block -join "`n")
    $pub = ($block | Where-Object { $_ -match '^Published Name\s*:\s*(\S+)' } | ForEach-Object { $matches[1] } | Select-Object -First 1)
    $orig = ($block | Where-Object { $_ -match '^Original Name\s*:\s*(.+)$' } | ForEach-Object { $matches[1].Trim() } | Select-Object -First 1)
    $prov = ($block | Where-Object { $_ -match '^(Driver|Driver package) (Provider|provider)\s*:\s*(.+)$' } | ForEach-Object { $matches[3].Trim() } | Select-Object -First 1)
    $name = ($block | Where-Object { $_ -match '^(Driver|Driver package) (Name|name)\s*:\s*(.+)$' } | ForEach-Object { $matches[3].Trim() } | Select-Object -First 1)
    $ver = ($block | Where-Object { $_ -match '^(Driver )?Version\s*:\s*(.+)$' } | ForEach-Object { $matches[2].Trim() } | Select-Object -First 1)

    $isMatch = $false
    if ($orig -match '(?i)euvkbd\.inf') { $isMatch = $true }
    if ($text -match '(?i)EuVKbd\.sys') { $isMatch = $true }
    if ($prov -match '(?i)Avid') { if ($text -match '(?i)euvkbd') { $isMatch = $true } }

    if ($isMatch -and $pub) {
      $hits += [PSCustomObject]@{
        PublishedName = $pub
        OriginalName  = $orig
        Provider      = $prov
        Name          = $name
        Version       = $ver
        Block         = $text
      }
    }
  }
  return $hits | Sort-Object PublishedName -Unique
}

function Test-ServiceExists($name) {
  try { $null -ne (Get-Service -Name $name -ErrorAction Stop) } catch { $false }
}

function Backup-Item {
  param(
    [string]$SourcePath,
    [string]$BackupFolder
  )

  if (-not (Test-Path $SourcePath)) { return $null }
  if (-not (Test-Path $BackupFolder)) {
    New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
  }

  $leaf = Split-Path $SourcePath -Leaf
  $destination = Join-Path $BackupFolder $leaf
  Copy-Item -LiteralPath $SourcePath -Destination $destination -Recurse -Force -ErrorAction SilentlyContinue
  return $destination
}

$published = Find-EuVKbdPublishedNames
$sysFile = "$env:SystemRoot\System32\drivers\EuVKbd.sys"
$fileRepo = Join-Path "$env:SystemRoot\System32\DriverStore\FileRepository" "euvkbd.inf_*"
$repoDirs = Get-ChildItem $fileRepo -Directory -ErrorAction SilentlyContinue
$svcExists = Test-ServiceExists 'EuVKbd'

Write-Host "📋 WYKRYTO:" -ForegroundColor Yellow
Write-Host "   Usługa EuVKbd: $(if ($svcExists) { 'TAK' } else { 'NIE' })" -ForegroundColor Gray
Write-Host "   Plik SYS: $(if (Test-Path $sysFile) { 'ISTNIEJE' } else { 'brak' }) - $sysFile" -ForegroundColor Gray
Write-Host "   DriverStore (FileRepository): $(@($repoDirs).Count) katalog(ów)" -ForegroundColor Gray
Write-Host "   Pakiety Published (pnputil): $(@($published).Count) szt." -ForegroundColor Gray

if ($published.Count) {
  Write-Host "\n   Pakiety:" -ForegroundColor Gray
  $published | ForEach-Object {
    Write-Host "   • $($_.PublishedName) | Provider: $($_.Provider) | Version: $($_.Version)" -ForegroundColor DarkGray
  }
}

if ($dry) {
  Write-Host "\nℹ️  DRY RUN. Nic nie usuwam. Uruchom z -Execute aby wykonać." -ForegroundColor Yellow
  Write-Host "   Planowany backup przed usuwaniem: $backupRoot" -ForegroundColor Gray
  exit 0
}

# Backup artefaktów przed usuwaniem
Write-Host "\n💾 Backup przed zmianami..." -ForegroundColor Cyan
if (-not (Test-Path $backupRoot)) {
  New-Item -Path $backupRoot -ItemType Directory -Force | Out-Null
}

$backupManifest = @()
if (Test-Path $sysFile) {
  $sysBackup = Backup-Item -SourcePath $sysFile -BackupFolder $backupRoot
  if ($sysBackup) {
    Write-Host "   ✅ Backup SYS: $sysBackup" -ForegroundColor Green
    $backupManifest += [PSCustomObject]@{ Source = $sysFile; Backup = $sysBackup }
  }
}

foreach ($d in $repoDirs) {
  $repoBackup = Backup-Item -SourcePath $d.FullName -BackupFolder $backupRoot
  if ($repoBackup) {
    Write-Host "   ✅ Backup DriverStore: $repoBackup" -ForegroundColor Green
    $backupManifest += [PSCustomObject]@{ Source = $d.FullName; Backup = $repoBackup }
  }
}

$manifestPath = Join-Path $backupRoot "euvkbd-backup-manifest-$runTimestamp.json"
@{
  Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
  Backups = $backupManifest
  PublishedPackages = @($published | Select-Object PublishedName, OriginalName, Provider, Version)
} | ConvertTo-Json -Depth 6 | Set-Content $manifestPath -Encoding UTF8
Write-Host "   📝 Manifest backupu: $manifestPath" -ForegroundColor Cyan

# 1) Zatrzymanie i usunięcie usługi sterownika
if ($svcExists) {
  Write-Host "\n🛑 Stop EuVKbd..." -NoNewline
  sc.exe stop EuVKbd 1>$null 2>$null | Out-Null
  Start-Sleep -Milliseconds 800
  Write-Host " OK" -ForegroundColor Green

  Write-Host "🗑  Delete EuVKbd service..." -NoNewline
  sc.exe delete EuVKbd 1>$null 2>$null | Out-Null
  Write-Host " OK" -ForegroundColor Green
}

# 2) pnputil – usuń pakiety
$rebootNeeded = $false
foreach ($p in $published) {
  Write-Host "\n📦 pnputil /delete-driver $($p.PublishedName) /uninstall /force" -ForegroundColor Cyan
  $proc = Start-Process -FilePath pnputil -ArgumentList "/delete-driver", $p.PublishedName, "/uninstall", "/force" -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
  if ($proc.ExitCode -ne 0) {
    Write-Host "   ⚠️  pnputil exitcode: $($proc.ExitCode). Kontynuuję..." -ForegroundColor Yellow
  }
  # Heurystyka: jeśli exitcode != 0 lub komunikat sugeruje reboot, zaznacz
  $rebootNeeded = $rebootNeeded -or ($proc.ExitCode -eq 3010 -or $proc.ExitCode -eq 1641)
}

# 3) Usuń plik .sys
if (Test-Path $sysFile) {
  Write-Host "\n🗑  Usuwam $sysFile..." -ForegroundColor Cyan
  try {
    if ($Force) {
      takeown /f $sysFile | Out-Null
      icacls $sysFile /grant Administrators:F /t | Out-Null
    }
    Remove-Item -LiteralPath $sysFile -Force -ErrorAction Stop
    Write-Host "   ✅ Usunięty" -ForegroundColor Green
  } catch {
    Write-Host "   ⚠️  Nie udało się usunąć (plik może być w użyciu)" -ForegroundColor Yellow
  }
}

# 4) Usuń foldery z DriverStore\FileRepository
foreach ($d in $repoDirs) {
  Write-Host "\n🗑  DriverStore: $($d.FullName)" -ForegroundColor Cyan
  try {
    if ($Force) {
      takeown /f $d.FullName /r /d y | Out-Null
      icacls $d.FullName /grant Administrators:F /t | Out-Null
    }
    Remove-Item -LiteralPath $d.FullName -Recurse -Force -ErrorAction Stop
    Write-Host "   ✅ Usunięty" -ForegroundColor Green
  } catch {
    Write-Host "   ⚠️  Nie udało się usunąć (wymaga restartu lub trybu awaryjnego)" -ForegroundColor Yellow
  }
}

# 5) Weryfikacja
Write-Host "\n🔎 Weryfikacja:" -ForegroundColor Cyan
$svcExists2 = Test-ServiceExists 'EuVKbd'
Write-Host "   Usługa EuVKbd: $(if ($svcExists2) { 'ISTNIEJE' } else { 'brak' })" -ForegroundColor Gray
Write-Host "   Plik SYS: $(if (Test-Path $sysFile) { 'ISTNIEJE' } else { 'brak' })" -ForegroundColor Gray

$published2 = Find-EuVKbdPublishedNames
Write-Host "   Pakiety Published (pnputil): $(@($published2).Count)" -ForegroundColor Gray

if ($Reboot -or $rebootNeeded) {
  Write-Host "\n🔁 Wymagany restart aby dokończyć czyszczenie. Wykonać teraz? (T/n)" -NoNewline -ForegroundColor Yellow
  $ans = Read-Host
  if ($ans -ne 'n') {
    Restart-Computer -Force
  }
}

Write-Host "\n✅ Zakończono." -ForegroundColor Green
Write-Host "💾 Backup: $backupRoot" -ForegroundColor Cyan
