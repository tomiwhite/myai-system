# ============================================================================
# SYSTEM PERMISSIONS AUDIT & FIX
# ============================================================================
# 
# Sprawdza i naprawia uprawnienia w całym systemie myAI
# Usuwa martwe linki, naprawia ownership, sprawdza Git/PS7
# 
# Uruchom jako ADMINISTRATOR!
# ============================================================================

param(
    [switch]$Fix,           # Automatyczne naprawianie
    [switch]$Deep,          # Głęboka analiza (wolniej)
    [switch]$Verbose        # Szczegółowe logi
)

#Requires -RunAsAdministrator

$ErrorActionPreference = "Continue"

$recommendedGitEmail = "45501831+tomiwhite@users.noreply.github.com"
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$backupDir = "C:\myAI_System\backups\config-backups"

function Get-EnvSyncSettings {
    $settings = @{
        GoogleDriveEnvPath = "G:\Mój dysk\podreczne - mysite\myoffice 4-0 dokumentation\.env"
        GoogleDriveEnvPathEnvVar = "MYAI_GDRIVE_ENV"
    }

    $configPath = "C:\myAI_System\config\system-config.json"
    if (Test-Path $configPath) {
        try {
            $config = Get-Content $configPath -Raw | ConvertFrom-Json
            if ($config.environment.googleDriveEnvPath) {
                $settings.GoogleDriveEnvPath = $config.environment.googleDriveEnvPath
            }
            if ($config.environment.googleDriveEnvPathEnvVar) {
                $settings.GoogleDriveEnvPathEnvVar = $config.environment.googleDriveEnvPathEnvVar
            }
        } catch {}
    }

    $overrideVarName = $settings.GoogleDriveEnvPathEnvVar
    if ($overrideVarName) {
        $overrideValue = [Environment]::GetEnvironmentVariable($overrideVarName, "Process")
        if (-not $overrideValue) {
            $overrideValue = [Environment]::GetEnvironmentVariable($overrideVarName, "User")
        }
        if (-not $overrideValue) {
            $overrideValue = [Environment]::GetEnvironmentVariable($overrideVarName, "Machine")
        }

        if ($overrideValue) {
            $settings.GoogleDriveEnvPath = $overrideValue
        }
    }

    return $settings
}

function Write-Header { Write-Host "`n$('='*80)" -ForegroundColor Cyan; Write-Host " $args" -ForegroundColor Yellow; Write-Host "$('='*80)" -ForegroundColor Cyan }
function Write-Success { Write-Host "  ✅ $args" -ForegroundColor Green }
function Write-Warning { Write-Host "  ⚠️  $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "  ❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "  ℹ️  $args" -ForegroundColor Cyan }

function Backup-AclState {
    param(
        [string]$TargetPath,
        [string]$Label
    )

    if (-not (Test-Path $backupDir)) {
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
    }

    $sanitizedLabel = $Label -replace '[^a-zA-Z0-9_-]', '-'
    $backupPath = Join-Path $backupDir "$sanitizedLabel-acl-backup-$timestamp.json"
    $aclState = Get-Acl $TargetPath

    @{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        TargetPath = $TargetPath
        Owner = $aclState.Owner
        Access = @(
            $aclState.Access | ForEach-Object {
                @{
                    IdentityReference = $_.IdentityReference.ToString()
                    FileSystemRights = $_.FileSystemRights.ToString()
                    AccessControlType = $_.AccessControlType.ToString()
                    IsInherited = $_.IsInherited
                    InheritanceFlags = $_.InheritanceFlags.ToString()
                    PropagationFlags = $_.PropagationFlags.ToString()
                }
            }
        )
    } | ConvertTo-Json -Depth 6 | Set-Content $backupPath -Encoding UTF8

    return $backupPath
}

Clear-Host
Write-Header "🔐 SYSTEM PERMISSIONS AUDIT - myAI"

$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

Write-Info "Użytkownik: $currentUser"
Write-Info "Administrator: $isAdmin"
Write-Info "Data: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

$issues = @()
$fixes = @()

# ============================================================================
# 1. SPRAWDŹ KONTA UŻYTKOWNIKÓW
# ============================================================================
Write-Header "👤 KROK 1: Sprawdzanie Kont Użytkowników"

Write-Info "Aktualne konto: $env:USERNAME"
Write-Info "User Profile: $env:USERPROFILE"
Write-Info "Domain: $env:USERDOMAIN"

# Sprawdź czy są pozostałości po starych kontach
$oldAccounts = @("office@oxygenup.pl", "office", "oxygenup", "myzabka")
$userProfiles = Get-ChildItem "C:\Users" -ErrorAction SilentlyContinue

Write-Info "`nProfile folders w C:\Users:"
foreach ($userProfileDir in $userProfiles) {
    $isOld = $false
    foreach ($oldAcc in $oldAccounts) {
        if ($userProfileDir.Name -like "*$oldAcc*") {
            $isOld = $true
            break
        }
    }
    
    if ($isOld) {
        Write-Warning "$($userProfileDir.Name) - Stare konto (potencjalny problem)"
        $issues += "Stary profil: $($userProfileDir.FullName)"
    } else {
        Write-Info "$($userProfileDir.Name) - OK"
    }
}

# ============================================================================
# 2. SPRAWDŹ GIT KONFIGURACJĘ
# ============================================================================
Write-Header "🔧 KROK 2: Git Configuration"

$gitPath = Get-Command git -ErrorAction SilentlyContinue
if ($gitPath) {
    Write-Success "Git zainstalowany: $($gitPath.Source)"
    
    # Global config
    $gitUser = git config --global user.name 2>$null
    $gitEmail = git config --global user.email 2>$null
    
    Write-Info "Git user.name: $gitUser"
    Write-Info "Git user.email: $gitEmail"
    
    if (-not $gitEmail) {
        Write-Warning "Git nie ma ustawionego globalnego email"
        $issues += "Git config: brak user.email"
        
        if ($Fix) {
            git config --global user.email $recommendedGitEmail 2>$null
            git config --global user.name "Tomasz Białas" 2>$null
            Write-Success "Ustawiono Git config"
            $fixes += "Git email → $recommendedGitEmail"
        }
    } elseif ($gitEmail -notmatch "@users\.noreply\.github\.com$") {
        Write-Warning "Git email powinien byc GitHub noreply: $recommendedGitEmail"
        $issues += "Git config: niezalecany email ($gitEmail)"
        
        if ($Fix) {
            git config --global user.email $recommendedGitEmail 2>$null
            git config --global user.name "Tomasz Białas" 2>$null
            Write-Success "Naprawiono Git config"
            $fixes += "Git email → $recommendedGitEmail"
        }
    }
    
    # GitHub Desktop
    $ghDesktop = Join-Path $env:USERPROFILE "AppData\Local\GitHubDesktop\GitHubDesktop.exe"
    if (Test-Path $ghDesktop) {
        Write-Success "GitHub Desktop zainstalowany"
    } else {
        Write-Warning "GitHub Desktop nie znaleziony (zainstalowałeś niedawno?)"
    }
} else {
    Write-Error "Git nie znaleziony!"
    $issues += "Git nie zainstalowany"
}

# ============================================================================
# 3. SPRAWDŹ POWERSHELL
# ============================================================================
Write-Header "💻 KROK 3: PowerShell Versions"

Write-Info "Aktualna sesja: $($PSVersionTable.PSVersion)"

# Sprawdź PowerShell 7
$ps7Path = "C:\Program Files\PowerShell\7\pwsh.exe"
if (Test-Path $ps7Path) {
    $ps7Version = & $ps7Path -Command '$PSVersionTable.PSVersion' 2>$null
    Write-Success "PowerShell 7 zainstalowany: $ps7Version"
} else {
    Write-Warning "PowerShell 7 nie znaleziony w standardowej lokalizacji"
}

# Sprawdź Windows PowerShell
$ps5Version = $PSVersionTable.PSVersion
Write-Info "Windows PowerShell: $ps5Version"

# ============================================================================
# 4. SPRAWDŹ .NET SDK
# ============================================================================
Write-Header "🔷 KROK 4: .NET SDK"

$dotnetPath = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnetPath) {
    $dotnetVersion = dotnet --version 2>$null
    Write-Success ".NET SDK zainstalowany: $dotnetVersion"
    
    # Pokaż wszystkie SDKs
    $sdks = dotnet --list-sdks 2>$null
    Write-Info "Zainstalowane SDKs:"
    $sdks | ForEach-Object { Write-Info "  - $_" }
} else {
    Write-Warning ".NET SDK nie znaleziony w PATH"
}

# ============================================================================
# 5. SPRAWDŹ UPRAWNIENIA C:\myAI_System
# ============================================================================
Write-Header "🔐 KROK 5: Uprawnienia C:\myAI_System"

$myaiPath = "C:\myAI_System"
if (Test-Path $myaiPath) {
    $acl = Get-Acl $myaiPath
    
    Write-Info "Owner: $($acl.Owner)"
    
    if ($acl.Owner -notlike "*$env:USERNAME*" -and $acl.Owner -notlike "*Administrators*") {
        Write-Warning "Owner nie jest aktualnym użytkownikiem!"
        $issues += "C:\myAI_System owner: $($acl.Owner)"
        
        if ($Fix) {
            try {
                $ownerBackup = Backup-AclState -TargetPath $myaiPath -Label "myai-system-owner"
                $newOwner = New-Object System.Security.Principal.NTAccount($env:USERNAME)
                $acl.SetOwner($newOwner)
                Set-Acl $myaiPath $acl
                Write-Success "Naprawiono owner → $env:USERNAME"
                Write-Info "Backup ACL: $ownerBackup"
                $fixes += "C:\myAI_System owner → $env:USERNAME"
            } catch {
                Write-Error "Nie udało się zmienić owner: $_"
            }
        }
    } else {
        Write-Success "Owner OK: $($acl.Owner)"
    }
    
    # Sprawdź permissions
    $hasFullControl = $false
    foreach ($access in $acl.Access) {
        if ($access.IdentityReference -like "*$env:USERNAME*" -or $access.IdentityReference -like "*Administrators*") {
            if ($access.FileSystemRights -match "FullControl") {
                $hasFullControl = $true
                break
            }
        }
    }
    
    if ($hasFullControl) {
        Write-Success "Masz pełną kontrolę"
    } else {
        Write-Warning "Brak pełnej kontroli!"
        $issues += "C:\myAI_System: brak FullControl"
        
        if ($Fix) {
            try {
                $permissionsBackup = Backup-AclState -TargetPath $myaiPath -Label "myai-system-permissions"
                $rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
                    $env:USERNAME, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
                )
                $acl.AddAccessRule($rule)
                Set-Acl $myaiPath $acl
                Write-Success "Dodano FullControl dla $env:USERNAME"
                Write-Info "Backup ACL: $permissionsBackup"
                $fixes += "Dodano FullControl dla C:\myAI_System"
            } catch {
                Write-Error "Nie udało się dodać uprawnień: $_"
            }
        }
    }
} else {
    Write-Error "C:\myAI_System nie istnieje!"
    $issues += "C:\myAI_System nie istnieje"
}

# ============================================================================
# 6. SPRAWDŹ MARTWE LINKI (SHORTCUTS)
# ============================================================================
Write-Header "🔗 KROK 6: Sprawdzanie Martwych Linków"

$desktop = [Environment]::GetFolderPath("Desktop")
$shortcuts = Get-ChildItem $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue

Write-Info "Sprawdzam skróty na pulpicie..."
$deadLinks = @()

foreach ($shortcut in $shortcuts) {
    try {
        $shell = New-Object -ComObject WScript.Shell
        $link = $shell.CreateShortcut($shortcut.FullName)
        $target = $link.TargetPath
        
        if ($target -and (Test-Path $target)) {
            if ($Verbose) { Write-Success "$($shortcut.Name) → $target" }
        } else {
            Write-Warning "$($shortcut.Name) → MARTWY LINK ($target)"
            $deadLinks += $shortcut
            $issues += "Martwy link: $($shortcut.Name) → $target"
            
            if ($Fix) {
                Remove-Item $shortcut.FullName -Force
                Write-Info "  Usunięto martwy link"
                $fixes += "Usunięto: $($shortcut.Name)"
            }
        }
        
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($shell) | Out-Null
    } catch {
        Write-Error "$($shortcut.Name) - Błąd: $_"
    }
}

Write-Info "Znaleziono martwych linków: $($deadLinks.Count)"

# ============================================================================
# 7. SPRAWDŹ C:\myai\.env
# ============================================================================
Write-Header "🔑 KROK 7: Sprawdzanie .env Files"

$masterEnv = "C:\myai\.env"
if (Test-Path $masterEnv) {
    $envAcl = Get-Acl $masterEnv
    Write-Info "C:\myai\.env owner: $($envAcl.Owner)"
    
    # Sprawdź czy jest read-only
    $envItem = Get-Item $masterEnv
    if ($envItem.IsReadOnly) {
        Write-Success ".env jest read-only (bezpieczeństwo)"
    } else {
        Write-Warning ".env NIE jest read-only!"
        if ($Fix) {
            Set-ItemProperty -Path $masterEnv -Name IsReadOnly -Value $true
            Write-Success "Ustawiono read-only"
            $fixes += "C:\myai\.env → read-only"
        }
    }
    
    # Rozmiar
    Write-Info "Rozmiar: $($envItem.Length) bajtów"
    Write-Info "Data modyfikacji: $($envItem.LastWriteTime)"
} else {
    Write-Warning "C:\myai\.env nie istnieje!"
    $issues += "MASTER .env brakuje"
}

# ============================================================================
# 8. SPRAWDŹ D:\myai
# ============================================================================
Write-Header "🤖 KROK 8: Sprawdzanie D:\myai"

if (Test-Path "D:\myai") {
    $dmyaiAcl = Get-Acl "D:\myai"
    Write-Info "D:\myai owner: $($dmyaiAcl.Owner)"
    
    # Sprawdź czy masz dostęp
    try {
        $testFile = "D:\myai\.permission-test"
        "test" | Out-File $testFile -Force
        Remove-Item $testFile -Force
        Write-Success "Masz dostęp do zapisu w D:\myai"
    } catch {
        Write-Error "Brak dostępu do zapisu w D:\myai!"
        $issues += "D:\myai: brak dostępu do zapisu"
    }
} else {
    Write-Warning "D:\myai nie istnieje"
}

# ============================================================================
# 9. SPRAWDŹ EXECUTION POLICY
# ============================================================================
Write-Header "⚙️ KROK 9: PowerShell Execution Policy"

$execPolicy = Get-ExecutionPolicy -Scope CurrentUser
Write-Info "CurrentUser: $execPolicy"

if ($execPolicy -eq "Restricted") {
    Write-Warning "Execution Policy jest Restricted - może blokować skrypty!"
    $issues += "PowerShell Execution Policy: Restricted"
    
    if ($Fix) {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
        Write-Success "Zmieniono na RemoteSigned"
        $fixes += "Execution Policy → RemoteSigned"
    }
}

# ============================================================================
# 10. SPRAWDŹ GOOGLE DRIVE
# ============================================================================
Write-Header "☁️ KROK 10: Google Drive Path"

$gdrivePath = (Get-EnvSyncSettings).GoogleDriveEnvPath
if (Test-Path $gdrivePath) {
    Write-Success "Google Drive .env dostępny"
    $gdriveItem = Get-Item $gdrivePath
    Write-Info "Rozmiar: $($gdriveItem.Length) bajtów"
    Write-Info "Data modyfikacji: $($gdriveItem.LastWriteTime)"
} else {
    Write-Warning "Google Drive .env niedostępny!"
    Write-Info "Ścieżka: $gdrivePath"
    $issues += "Google Drive .env niedostępny"
}

# ============================================================================
# PODSUMOWANIE
# ============================================================================
Write-Header "📊 PODSUMOWANIE AUDYTU"

Write-Host "`n🔴 PROBLEMY: $($issues.Count)" -ForegroundColor $(if ($issues.Count -eq 0) { "Green" } else { "Red" })
foreach ($issue in $issues) {
    Write-Host "   - $issue" -ForegroundColor Red
}

if ($Fix -and $fixes.Count -gt 0) {
    Write-Host "`n🔧 NAPRAWIONE: $($fixes.Count)" -ForegroundColor Cyan
    foreach ($fix in $fixes) {
        Write-Host "   - $fix" -ForegroundColor Cyan
    }
}

# Rekomendacje
Write-Host "`n💡 REKOMENDACJE:" -ForegroundColor Yellow

if ($issues.Count -gt 0 -and -not $Fix) {
    Write-Host "  1. Uruchom ponownie z -Fix aby naprawić automatycznie" -ForegroundColor White
}

if (-not $gitEmail -or $gitEmail -notmatch "@users\.noreply\.github\.com$") {
    Write-Host "  2. Zmień Git config:" -ForegroundColor White
    Write-Host "     git config --global user.email '$recommendedGitEmail'" -ForegroundColor Cyan
}

if ($deadLinks.Count -gt 0) {
    Write-Host "  3. Usuń martwe linki z pulpitu" -ForegroundColor White
}

Write-Host "`n📝 Raport zapisany do:" -ForegroundColor Yellow
$reportPath = "C:\myAI_System\reports\permissions\$(Get-Date -Format 'yyyyMMddHHmmss')-permissions-audit.json"
$reportDir = Split-Path $reportPath
if (-not (Test-Path $reportDir)) {
    New-Item -Path $reportDir -ItemType Directory -Force | Out-Null
}

$report = @{
    timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    user = $currentUser
    issues = $issues
    fixes = $fixes
    git_email = $gitEmail
    dead_links = $deadLinks.Count
}

$report | ConvertTo-Json -Depth 10 | Out-File $reportPath -Encoding utf8
Write-Info $reportPath

Write-Host ""
