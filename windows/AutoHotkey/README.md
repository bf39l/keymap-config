# AutoHotkey (Windows)

This folder contains an AutoHotkey v2 script that provides a **Colemak-style key remap** on Windows without installing a system keyboard layout.

## Prerequisites

- Windows 10/11
- **US (QWERTY) keyboard layout installed and active**
  - The remap assumes US QWERTY as the base layout.

## Quick Start

1. Install AutoHotkey v2 (user scope):

   ```powershell
   winget install --id AutoHotkey.AutoHotkey --scope user --exact
   ```

2. Run the script from this folder:

   ```powershell
   AutoHotkey64.exe .\01-Main.ahk
   ```

3. (Optional) Add startup shortcut with [Create a Startup shortcut (run at login)](#create-a-startup-shortcut-run-at-login).

## What this script does

Main script: `01-Main.ahk`

- Remaps selected QWERTY letter keys to Colemak positions.
- Keeps a toggle to enable/disable remapping quickly.
  - `Ctrl + Shift + Tab` toggles Colemak ON/OFF (shows a tooltip).
- Adds a dual-role `CapsLock` behavior:
  - Tap `CapsLock` -> `Esc`
  - Hold `CapsLock` -> holds `Ctrl + Shift` while pressed
- Lets you toggle real Caps Lock by pressing both Shift keys together.

## Install AutoHotkey v2 (user scope, no admin)

Open **PowerShell** and run:

```powershell
winget install --id AutoHotkey.AutoHotkey --scope user --exact
```

Notes:
- `--scope user` installs to your user profile (no admin required).
- If prompted to accept source/package agreements, accept them.

## Run the script manually

From this folder:

```powershell
AutoHotkey64.exe .\01-Main.ahk
```

If `AutoHotkey64.exe` is not found in `PATH`, locate it with:

```powershell
(Get-Command AutoHotkey64.exe).Source
```

Then run with the full executable path.

## Create a Startup shortcut (run at login)

Helper script: `scripts/Create-StartupShortcut.ps1`

It creates a `.lnk` file in your **Startup** folder so the AHK script auto-starts at login.

### 1) Get the AutoHotkey executable path

```powershell
$ahkExe = (Get-Command AutoHotkey64.exe).Source
```

### 2) Set the script path

Run these commands from `windows/AutoHotkey`:

```powershell
$scriptPath = (Resolve-Path .\01-Main.ahk).Path
```

### 3) Run the startup shortcut creator

For the current PowerShell session only, allow script execution:

```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\Create-StartupShortcut.ps1 `
  -AhkExe $ahkExe `
  -ScriptPath $scriptPath `
  -ShortcutName "AutoHotkey - Colemak"
```

If you omit `-ShortcutName`, the script uses: `AutoHotkey - <script-name>`.

## Verify startup entry

Open your startup folder:

```powershell
explorer.exe shell:startup
```

You should see the shortcut there. It will launch on next sign-in.

## Disable or remove startup

- Disable temporarily: move/delete the shortcut in `shell:startup`.
- Stop current run: right-click AutoHotkey tray icon -> Exit.

## Troubleshooting

- Script seems "wrong" key output:
  - Ensure US QWERTY is the active Windows input layout.
- PowerShell blocks script execution:
  - Use the provided `-ExecutionPolicy Bypass` command (process-only for that run).
- Changes not applying:
  - Restart the script from tray icon or re-run `AutoHotkey64.exe .\01-Main.ahk`.
