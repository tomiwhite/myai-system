# ============================================================================
# AI_RULES VALIDATOR
# ============================================================================
# 
# Sprawdza czy pliki w projekcie przestrzegają zasad z AI_RULES.md
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
function Write-Error { Write-Host "  ❌ $args" -ForegroundColor Red }
function Write-Info { Write-Host "  ℹ️  $args" -ForegroundColor Cyan }

Clear-Host
Write-Header "🔍 AI_RULES VALIDATOR - Sprawdzanie Nazewnictwa"

$projectRoot = "C:\myAI_System"
$errors = @()
$warnings = @()
$fixes = @()

# ============================================================================
# REGUŁA 1: ROOT - Tylko pliki systemowe bez timestampów
# ============================================================================
Write-Host "`n📋 REGUŁA 1: Pliki w ROOT (bez timestampów)" -ForegroundColor Magenta

$allowedRoot = @("README.md", "QUICKSTART.md", "AI_RULES.md", ".gitignore", ".env")
$rootFiles = Get-ChildItem -Path $projectRoot -File -Filter "*.md"

foreach ($file in $rootFiles) {
    if ($file.Name -in $allowedRoot) {
        if ($Verbose) { Write-Success "$($file.Name) - OK" }
    } elseif ($file.Name -match '^\d{14}-') {
        Write-Error "$($file.Name) - Timestamp w ROOT! Powinno być w docs/"
        $errors += "ROOT: $($file.Name) ma timestamp (przenieś do docs/)"
        
        if ($Fix) {
            $targetDir = "$projectRoot\docs\architecture"
            $targetPath = Join-Path $targetDir $file.Name
            Move-Item $file.FullName $targetPath -Force
            Write-Info "  → Przeniesiono do docs/architecture/"
            $fixes += "Przeniesiono $($file.Name) → docs/architecture/"
        }
    } else {
        Write-Warning "$($file.Name) - Nieznany plik w ROOT"
        $warnings += "ROOT: $($file.Name) nie jest w liście dozwolonych"
    }
}

# ============================================================================
# REGUŁA 2: docs/ - Wszystkie .md MUSZĄ mieć timestamp
# ============================================================================
Write-Host "`n📋 REGUŁA 2: Pliki w docs/ (WYMAGANY timestamp)" -ForegroundColor Magenta

$docsRoot = "$projectRoot\docs"
$docsFiles = Get-ChildItem -Path $docsRoot -Recurse -File -Filter "*.md"

# Wyjątki (katalogi gdzie pliki mogą być bez timestampu - stałe reference)
$exceptionDirs = @("quickref", "quickstart", "user-guide", "diagrams")
$docsExceptions = @()

foreach ($file in $docsFiles) {
    $relativePath = $file.FullName.Replace("$docsRoot\", "")
    
    # Sprawdź czy plik jest w katalogu wyjątków (reference docs)
    $isException = $false
    foreach ($exDir in $exceptionDirs) {
        if ($relativePath -like "$exDir\*") {
            $isException = $true
            break
        }
    }
    
    if ($file.Name -in $docsExceptions -or $isException) {
        if ($Verbose) { Write-Success "$relativePath - Wyjątek (reference doc, dozwolony)" }
    } elseif ($file.Name -match '^\d{14}-') {
        if ($Verbose) { Write-Success "$relativePath - OK (ma timestamp)" }
    } else {
        Write-Error "$relativePath - BRAK TIMESTAMPU!"
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
}

# ============================================================================
# REGUŁA 3: docs/ bezpośrednio - powinno być prawie puste
# ============================================================================
Write-Host "`n📋 REGUŁA 3: Pliki bezpośrednio w docs/ (powinny być w podfolderach)" -ForegroundColor Magenta

$docsDirectFiles = Get-ChildItem -Path $docsRoot -File

foreach ($file in $docsDirectFiles) {
    # Wyjątki: QUICK-INFO.txt itp.
    if ($file.Extension -eq ".txt") {
        if ($Verbose) { Write-Success "$($file.Name) - OK (plik tekstowy reference)" }
    } else {
        Write-Warning "$($file.Name) - Powinien być w podfolderze (work-logs, reports, architecture)"
        $warnings += "docs/: $($file.Name) powinien być w podfolderze"
        
        if ($Fix -and $file.Extension -eq ".md") {
            # Próbuj określić gdzie powinien trafić
            $targetSubdir = "architecture"  # Domyślnie
            
            if ($file.Name -match 'work|session|log') {
                $targetSubdir = "work-logs"
            } elseif ($file.Name -match 'report') {
                $targetSubdir = "reports"
            }
            
            $targetPath = Join-Path "$docsRoot\$targetSubdir" $file.Name
            Move-Item $file.FullName $targetPath -Force
            Write-Info "  → Przeniesiono do docs/$targetSubdir/"
            $fixes += "Przeniesiono $($file.Name) → docs/$targetSubdir/"
        }
    }
}

# ============================================================================
# REGUŁA 4: Timestamp format - YYYYMMDDHHMMSS
# ============================================================================
Write-Host "`n📋 REGUŁA 4: Format timestampu (YYYYMMDDHHMMSS-)" -ForegroundColor Magenta

$allMdFiles = Get-ChildItem -Path $projectRoot -Recurse -File -Filter "*.md"

foreach ($file in $allMdFiles) {
    if ($file.Name -match '^(\d+)-') {
        $timestamp = $Matches[1]
        
        if ($timestamp.Length -eq 14) {
            if ($Verbose) { Write-Success "$($file.Name) - Timestamp OK (14 cyfr)" }
        } else {
            Write-Error "$($file.Name) - Zły format timestampu! (ma $($timestamp.Length) cyfr, powinno być 14)"
            $errors += "$($file.FullName): Timestamp $timestamp ma $($timestamp.Length) cyfr (powinno 14)"
        }
    }
}

# ============================================================================
# REGUŁA 5: Workspace files
# ============================================================================
Write-Host "`n📋 REGUŁA 5: Workspace files (.code-workspace)" -ForegroundColor Magenta

$workspaceFiles = Get-ChildItem -Path $projectRoot -Filter "*.code-workspace" -Recurse

foreach ($file in $workspaceFiles) {
    # Workspace files mogą być bez timestampu
    if ($Verbose) { Write-Success "$($file.Name) - OK (workspace file)" }
}

# ============================================================================
# PODSUMOWANIE
# ============================================================================
Write-Header "📊 PODSUMOWANIE"

Write-Host "`n🔴 BŁĘDY: $($errors.Count)" -ForegroundColor $(if ($errors.Count -eq 0) { "Green" } else { "Red" })
foreach ($error in $errors) {
    Write-Host "   - $error" -ForegroundColor Red
}

Write-Host "`n🟡 OSTRZEŻENIA: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -eq 0) { "Green" } else { "Yellow" })
foreach ($warning in $warnings) {
    Write-Host "   - $warning" -ForegroundColor Yellow
}

if ($Fix -and ($fixes.Count -gt 0)) {
    Write-Host "`n🔧 NAPRAWIONE: $($fixes.Count)" -ForegroundColor Cyan
    foreach ($fix in $fixes) {
        Write-Host "   - $fix" -ForegroundColor Cyan
    }
}

# Status końcowy
Write-Host ""
if ($errors.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✅ WSZYSTKO OK! Projekt przestrzega AI_RULES.md" -ForegroundColor Green
    exit 0
} elseif ($errors.Count -eq 0) {
    Write-Host "⚠️  Projekt OK, ale są ostrzeżenia" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "❌ Znaleziono błędy! Uruchom z -Fix aby naprawić" -ForegroundColor Red
    exit 1
}
