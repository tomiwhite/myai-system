# ============================================================================
# AI_RULES VALIDATOR - Wersja 2.0
# ============================================================================
# 
# Sprawdza czy pliki w projekcie przestrzegają zasad z AI_RULES.md
# 
# ZASADY:
# - Timestamp TYLKO dla dokumentów MD w docs/ (work-logs, reports, architecture)
# - Skrypty, konfigi, kod agentów - NORMALNE NAZWY (bez timestampu)
# - Wyjątki docs/: quickref, quickstart, user-guide, diagrams (bez timestampu)
#
# Uruchom: .\scripts\validation\validate-naming-rules.ps1
# ============================================================================

param(
    [switch]$Fix,           # Automatyczne naprawianie błędów
    [switch]$Verbose        # Szczegółowe logi
)

$ErrorActionPreference = "Stop"

function Write-Header { Write-Host "`n$('='*80)" -ForegroundColor Cyan; Write-Host " $args" -ForegroundColor Yellow; Write-Host "$('='*80)" -ForegroundColor Cyan }
function Write-Success { Write-Host "  ✅ $args" -ForegroundColor Green }
function Write-Warning { Write-Host "  ⚠️  $args" -ForegroundColor Yellow }
function Write-ErrorMsg { Write-Host "  ❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "  ℹ️  $args" -ForegroundColor Cyan }

Clear-Host
Write-Header "🔍 AI_RULES VALIDATOR v2.0 - Sprawdzanie Nazewnictwa"

$projectRoot = "C:\myAI_System"
$errors = @()
$warnings = @()
$fixes = @()

# ============================================================================
# REGUŁA 1: ROOT - Tylko pliki systemowe, BEZ timestampów
# ============================================================================
Write-Host "`n📋 REGUŁA 1: Pliki w ROOT (bez timestampów)" -ForegroundColor Magenta

$allowedRoot = @("README.md", "QUICKSTART.md", "AI_RULES.md", ".gitignore", ".env")
$rootFiles = Get-ChildItem -Path $projectRoot -File -Filter "*.md"

foreach ($file in $rootFiles) {
    if ($file.Name -in $allowedRoot) {
        if ($Verbose) { Write-Success "$($file.Name) - OK" }
    } elseif ($file.Name -match '^\d{14}-') {
        Write-ErrorMsg "$($file.Name) - Timestamp w ROOT! Dokumenty MD tylko w docs/"
        $errors += "ROOT: $($file.Name) ma timestamp (przenieś do docs/)"
        
        if ($Fix) {
            $targetDir = "$projectRoot\docs\reports"
            if (-not (Test-Path $targetDir)) {
                New-Item $targetDir -ItemType Directory -Force | Out-Null
            }
            $targetPath = Join-Path $targetDir $file.Name
            Move-Item $file.FullName $targetPath -Force
            Write-Info "  → Przeniesiono do docs/reports/"
            $fixes += "Przeniesiono $($file.Name) → docs/reports/"
        }
    } else {
        Write-Warning "$($file.Name) - Nieznany plik w ROOT"
        $warnings += "ROOT: $($file.Name) nie jest w liście dozwolonych"
    }
}

# ============================================================================
# REGUŁA 1b: Skrypty, konfigi, kod - BEZ timestampów (!)
# ============================================================================
Write-Host "`n📋 REGUŁA 1b: Skrypty i kod - NORMALNE NAZWY (bez timestampów)" -ForegroundColor Magenta

$systemDirs = @("scripts", "agents", "config", "templates", "reports", "backups", "logs")
$foundTimestampsInCode = 0

foreach ($dir in $systemDirs) {
    $dirPath = Join-Path $projectRoot $dir
    if (Test-Path $dirPath) {
        # Sprawdź wszystkie pliki (nie tylko MD)
        $filesWithTimestamp = Get-ChildItem $dirPath -Recurse -File | Where-Object { 
            $_.Name -match '^\d{14}-' 
        }
        
        foreach ($file in $filesWithTimestamp) {
            $relativePath = $file.FullName -replace [regex]::Escape($projectRoot + "\"), ''
            Write-ErrorMsg "$relativePath - Skrypty/kod NIE MOGĄ mieć timestampów!"
            $errors += "Timestamp w kodzie: $relativePath (usuń YYYYMMDDHHMMSS- z nazwy)"
            $foundTimestampsInCode++
        }
    }
}

if ($foundTimestampsInCode -eq 0) {
    Write-Success "Wszystkie skrypty i kod mają normalne nazwy (bez timestampów)"
}

# ============================================================================
# REGUŁA 2: docs/ - TYLKO dokumenty MD wymagają timestampu
# ============================================================================
Write-Host "`n📋 REGUŁA 2: Dokumenty MD w docs/ (timestamp TYLKO tutaj)" -ForegroundColor Magenta

$docsRoot = "$projectRoot\docs"
if (Test-Path $docsRoot) {
    $docsFiles = Get-ChildItem -Path $docsRoot -Recurse -File -Filter "*.md"
    
    # Katalogi wyjątków (reference docs - bez timestampu)
    $exceptionDirs = @("quickref", "quickstart", "user-guide", "diagrams")
    
    # Katalogi WYMAGAJĄCE timestampu
    $requiredTimestampDirs = @("work-logs", "reports", "architecture")
    
    foreach ($file in $docsFiles) {
        $relativePath = $file.FullName.Replace("$docsRoot\", "")
        
        # Sprawdź czy plik jest w katalogu wyjątków (bez timestampu OK)
        $isException = $false
        foreach ($exDir in $exceptionDirs) {
            if ($relativePath -like "$exDir\*" -or $relativePath -like "$exDir") {
                $isException = $true
                break
            }
        }
        
        # Sprawdź czy plik jest w katalogu wymagającym timestampu
        $requiresTimestamp = $false
        foreach ($reqDir in $requiredTimestampDirs) {
            if ($relativePath -like "$reqDir\*") {
                $requiresTimestamp = $true
                break
            }
        }
        
        $hasTimestamp = $file.Name -match '^\d{14}-'
        
        if ($isException) {
            # Wyjątek - może nie mieć timestampu
            if ($hasTimestamp) {
                Write-Warning "$relativePath - Wyjątek (reference doc) ma timestamp (może go nie mieć)"
                $warnings += "docs/: $relativePath - reference doc z timestampem (opcjonalne)"
            } else {
                if ($Verbose) { Write-Success "$relativePath - OK (wyjątek, bez timestampu)" }
            }
        } elseif ($requiresTimestamp) {
            # Wymagany timestamp
            if ($hasTimestamp) {
                if ($Verbose) { Write-Success "$relativePath - OK (ma timestamp)" }
            } else {
                Write-ErrorMsg "$relativePath - BRAK TIMESTAMPU!"
                $errors += "docs/: $relativePath - brak timestampu YYYYMMDDHHMMSS-"
                
                if ($Fix) {
                    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
                    $newName = "$timestamp-$($file.Name)"
                    $newPath = Join-Path $file.Directory $newName
                    Rename-Item $file.FullName $newName -Force
                    Write-Info "  → Zmieniono na: $newName"
                    $fixes += "Zmieniono $($file.Name) → $newName"
                }
            }
        } else {
            # Inne katalogi w docs/ - domyślnie bez timestampu
            if ($hasTimestamp) {
                Write-Warning "$relativePath - Ma timestamp ale nie w folderze wymagającym"
                $warnings += "docs/: $relativePath - timestamp w nieoczekiwanym miejscu"
            } else {
                if ($Verbose) { Write-Success "$relativePath - OK (domyślnie bez timestampu)" }
            }
        }
    }
} else {
    Write-Warning "Katalog docs/ nie istnieje!"
}

# ============================================================================
# REGUŁA 3: Sprawdź format timestampu (jeśli jest)
# ============================================================================
Write-Host "`n📋 REGUŁA 3: Format timestampu (YYYYMMDDHHMMSS)" -ForegroundColor Magenta

if (Test-Path $docsRoot) {
    $filesWithTimestamp = Get-ChildItem -Path $docsRoot -Recurse -File | Where-Object { 
        $_.Name -match '^\d+-'
    }
    
    foreach ($file in $filesWithTimestamp) {
        $relativePath = $file.FullName.Replace("$docsRoot\", "")
        
        if ($file.Name -match '^\d{14}-') {
            if ($Verbose) { Write-Success "$relativePath - Format OK (14 cyfr)" }
        } else {
            Write-ErrorMsg "$relativePath - Zły format timestampu!"
            $errors += "docs/: $relativePath - timestamp musi być YYYYMMDDHHMMSS (14 cyfr)"
        }
    }
}

# ============================================================================
# PODSUMOWANIE
# ============================================================================
Write-Header "📊 PODSUMOWANIE WALIDACJI"

Write-Host "`n🔴 BŁĘDY: $($errors.Count)" -ForegroundColor $(if ($errors.Count -gt 0) { "Red" } else { "Green" })
if ($errors.Count -gt 0) {
    foreach ($err in $errors) {
        Write-Host "   • $err" -ForegroundColor Red
    }
}

Write-Host "`n⚠️  OSTRZEŻENIA: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -gt 0) { "Yellow" } else { "Green" })
if ($warnings.Count -gt 0) {
    foreach ($warn in $warnings) {
        Write-Host "   • $warn" -ForegroundColor Yellow
    }
}

if ($Fix -and $fixes.Count -gt 0) {
    Write-Host "`n🔧 NAPRAWY: $($fixes.Count)" -ForegroundColor Cyan
    foreach ($fix in $fixes) {
        Write-Host "   • $fix" -ForegroundColor Cyan
    }
}

if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "`n✅ Projekt w 100% przestrzega AI_RULES.md!" -ForegroundColor Green
    Write-Host "   Timestamp TYLKO w docs/ (work-logs, reports, architecture)" -ForegroundColor Green
    Write-Host "   Skrypty, konfigi, kod - normalne nazwy ✅" -ForegroundColor Green
    exit 0
} else {
    if ($errors.Count -gt 0) {
        Write-Host "`n❌ Znaleziono błędy! Uruchom z -Fix aby naprawić automatycznie." -ForegroundColor Red
        Write-Host "   .\scripts\validation\validate-naming-rules.ps1 -Fix" -ForegroundColor Cyan
        exit 1
    } else {
        Write-Host "`n⚠️  Tylko ostrzeżenia (projekt OK, ale sprawdź powyższe)" -ForegroundColor Yellow
        exit 0
    }
}
