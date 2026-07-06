' ============================================================================
' DESKTOP SHORTCUT CREATOR - myAI System
' ============================================================================
' 
' Tworzy skróty na pulpicie dla One-Click Starterów
' Uruchom: Podwójne kliknięcie tego pliku
' ============================================================================

Set objShell = CreateObject("WScript.Shell")
Set objFSO = CreateObject("Scripting.FileSystemObject")

' Pobierz ścieżkę do pulpitu
strDesktop = objShell.SpecialFolders("Desktop")

' ============================================================================
' SKRÓT 1: myAI System (C:\)
' ============================================================================

strShortcutPath1 = strDesktop & "\🖥️ myAI System (C).lnk"
Set objShortcut1 = objShell.CreateShortcut(strShortcutPath1)

' Uruchom PowerShell z ukrytym oknem, wykonaj skrypt, ale pokaż okno podczas działania
objShortcut1.TargetPath = "powershell.exe"
objShortcut1.Arguments = "-ExecutionPolicy Bypass -WindowStyle Normal -File ""C:\myAI_System\scripts\startup\start-myai-system-c.ps1"""
objShortcut1.WorkingDirectory = "C:\myAI_System"
objShortcut1.Description = "Uruchom myAI System (C:\myAI_System) w VS Code"
objShortcut1.IconLocation = "C:\Program Files\Microsoft VS Code\Code.exe,0"
objShortcut1.Save

WScript.Echo "✅ Utworzono: 🖥️ myAI System (C).lnk"

' ============================================================================
' SKRÓT 2: myAI Application (D:\)
' ============================================================================

strShortcutPath2 = strDesktop & "\🤖 myAI Application (D).lnk"
Set objShortcut2 = objShell.CreateShortcut(strShortcutPath2)

objShortcut2.TargetPath = "powershell.exe"
objShortcut2.Arguments = "-ExecutionPolicy Bypass -WindowStyle Normal -File ""C:\myAI_System\scripts\startup\start-myai-application-d.ps1"""
objShortcut2.WorkingDirectory = "D:\myai"
objShortcut2.Description = "Uruchom myAI Application (D:\myai) w VS Code"
objShortcut2.IconLocation = "C:\Program Files\Microsoft VS Code\Code.exe,0"
objShortcut2.Save

WScript.Echo "✅ Utworzono: 🤖 myAI Application (D).lnk"

' ============================================================================
' SKRÓT 3: myAI Docker (C:\myAI)
' ============================================================================

strShortcutPath3 = strDesktop & "\🐳 myAI Docker (C).lnk"
Set objShortcut3 = objShell.CreateShortcut(strShortcutPath3)

objShortcut3.TargetPath = "powershell.exe"
objShortcut3.Arguments = "-ExecutionPolicy Bypass -WindowStyle Normal -File ""C:\myAI\scripts\start-docker-environment.ps1"""
objShortcut3.WorkingDirectory = "C:\myAI"
objShortcut3.Description = "Uruchom środowisko Docker dla myAI (C:\myAI)"
objShortcut3.IconLocation = "C:\Program Files\Docker\Docker\resources\bin\docker.exe,0"
objShortcut3.Save

WScript.Echo "✅ Utworzono: 🐳 myAI Docker (C).lnk"

' ============================================================================
' PODSUMOWANIE
' ============================================================================

WScript.Echo ""
WScript.Echo "🚀 Skróty utworzone na pulpicie!"
WScript.Echo ""
WScript.Echo "Kliknij dwukrotnie aby uruchomić:"
WScript.Echo "  - 🖥️ myAI System (C).lnk     → C:\myAI_System (zarządzanie systemem)"
WScript.Echo "  - 🤖 myAI Application (D).lnk → D:\myai (agenty AI, Python)"
WScript.Echo "  - 🐳 myAI Docker (C).lnk      → C:\myAI (środowisko Docker)"
WScript.Echo ""
WScript.Echo "Gotowe!"
WScript.Echo ""
WScript.Echo "(Opcjonalnie) Autostart:" 
WScript.Echo "  1. Skopiuj wybrany skrót do: %APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\Startup" 
WScript.Echo "     (automatyczne uruchomienie po zalogowaniu)." 
WScript.Echo "  2. Lub utwórz Harmonogram zadań (Task Scheduler) z opóźnieniem 30-60s" 
WScript.Echo "     aby mieć pewność że dyski (np. G: Google Drive) są zamontowane." 
WScript.Echo "  3. Alternatywa: skrypt PowerShell który sprawdza dostępność G: zanim wywoła starter." 
WScript.Echo "" 
WScript.Echo "Przykład komendy sprawdzającej G: (dla skryptu opóźniającego):" 
WScript.Echo "  while(!(Test-Path G:\\)){ Start-Sleep -Seconds 5 } ; & C:\\myAI_System\\scripts\\startup\\start-myai-system-c.ps1" 
WScript.Echo "(Możesz zapisać jako start-delayed.ps1 i dodać do Harmonogramu)." 
