# Create AutoHotkey Startup Shortcut
# Usage: .\Create-StartupShortcut.ps1 -AhkExe "C:\path\to\AutoHotkey64.exe" -ScriptPath "C:\path\to\script.ahk" [-ShortcutName "My Script"]

param(
    [Parameter(Mandatory=$true)]
    [string]$AhkExe,
    
    [Parameter(Mandatory=$true)]
    [string]$ScriptPath,
    
    [string]$ShortcutName
)

# Default shortcut name from script filename
if (-not $ShortcutName) {
    $ShortcutName = "AutoHotkey - " + [System.IO.Path]::GetFileNameWithoutExtension($ScriptPath)
}

# Validate script exists
if (-not (Test-Path $ScriptPath)) {
    Write-Error "Script not found: $ScriptPath"
    exit 1
}

# Validate AHK executable exists
if (-not (Test-Path $AhkExe)) {
    Write-Error "AutoHotkey executable not found: $AhkExe"
    exit 1
}

# Get Startup folder
$StartupFolder = [Environment]::GetFolderPath('Startup')
$ShortcutPath = Join-Path $StartupFolder "$ShortcutName.lnk"

# Create shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $AhkExe
$Shortcut.Arguments = "`"$ScriptPath`""
$Shortcut.WorkingDirectory = Split-Path $ScriptPath
$Shortcut.Save()

Write-Host "Startup shortcut created: $ShortcutPath" -ForegroundColor Green
Write-Host "Script: $ScriptPath" -ForegroundColor Cyan
Write-Host "AutoHotkey will start on next login." -ForegroundColor Cyan
