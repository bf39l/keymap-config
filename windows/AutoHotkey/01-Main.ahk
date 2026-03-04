#Requires AutoHotkey v2.0+

; Colemak layout for AutoHotkey (MS Windows)
; See http://www.autohotkey.com/ for more information

; For this to work you have to make sure that the US (QWERTY) layout is installed,
; that is set as the default layout, and that it is set as the current layout.
; Otherwise some of the key mappings will be wrong.
;
; This is mainly useful for those who don't have privileges to install a new layout
; This doesn't support the international features of the Colemak layout.

#SingleInstance Force
; Keep only one running instance of this script.
; "Force" auto-replaces an older instance so updates apply immediately.

#MaxThreadsPerHotkey 1
; Prevent overlapping repeats of the same hotkey handler.
; Useful for hold/tap keys so state does not get out of sync.

ListLines(false)
; Disable line logging for lower overhead while this is always-on.

; #UseHook
; Optional (disabled): force low-level keyboard hook for all hotkeys.
; Keep off unless a specific hotkey needs it, to reduce hook side effects.

; #NoEnv (v1 directive) — omitted for AutoHotkey v2
; In v2 this behavior is already the default.

SendMode("Event") ; Fastest/reliable enough for simple remapping.
SetKeyDelay(-1, -1)
; Remove key send delays to keep remaps responsive.

SetMouseDelay(-1)
; Remove mouse send delay (kept consistent with keyboard speed settings).

SetWinDelay(-1)
; Remove delay after windowing commands.

SetControlDelay(-1)
; Remove delay after control commands.

A_BatchLines := -1
; Run script continuously (no cooperative sleep between lines).

ProcessSetPriority("High")
; Prioritize the process to reduce missed input during heavy CPU load.

SetTitleMatchMode(3)  ; Exact matching to avoid confusing T/B with Tab/Backspace.

global colemak_layout := true
; Master switch for all Colemak remaps.

global caps_tap_ms := 200
; Tap threshold for CapsLock dual-role behavior (tap=Esc, hold=Ctrl+Shift).

Suspend(!colemak_layout)
; Start suspended when layout switch is off.

#SuspendExempt True
; The following hotkeys remain active even when Suspend is on,
; so you can still toggle layout and Caps behavior back on.

^+Tab:: {
	; Ctrl+Shift+Tab toggles Colemak remapping on/off.
	global colemak_layout
	colemak_layout := !colemak_layout
	Suspend(!colemak_layout)
	ToolTip(colemak_layout ? "Colemak: ON" : "Colemak: OFF (QWERTY)")
	SetTimer(() => ToolTip(), -900)
}

*CapsLock:: {
	; Dual-role CapsLock:
	; - tap quickly -> Escape
	; - hold        -> momentary Ctrl+Shift chord
	global caps_tap_ms
	if KeyWait("CapsLock", "T" . (caps_tap_ms / 1000)) {
		SendInput("{Esc}")
	} else {
		SendInput("{LCtrl down}{LShift down}")
		KeyWait("CapsLock")
		SendInput("{LCtrl up}{LShift up}")
	}
}

LShift & RShift::ToggleCapsLockState()
; Press both Shift keys together to toggle CapsLock state.

RShift & LShift::ToggleCapsLockState()
; Reverse order included so both key press orders are recognized.

ToggleCapsLockState() {
	; Toggle CapsLock and show a short visual status hint.
	SetCapsLockState(GetKeyState("CapsLock", "T") ? "Off" : "On")
	ToolTip(GetKeyState("CapsLock", "T") ? "CapsLock: ON" : "CapsLock: OFF")
	SetTimer(() => ToolTip(), -900)
}
#SuspendExempt False

; Colemak alpha remaps (assumes OS keyboard layout remains US QWERTY).
; Left-hand top row remaps:

; QWERTY E -> Colemak F

e::f
; QWERTY R -> Colemak P

r::p
; QWERTY T -> Colemak G

t::g
; QWERTY Y -> Colemak J

y::j
; QWERTY U -> Colemak L

u::l
; QWERTY I -> Colemak U

i::u
; QWERTY O -> Colemak Y

o::y
; QWERTY P -> Colemak semicolon
p::`;
; Home-row remaps:

; QWERTY S -> Colemak R

s::r
; QWERTY D -> Colemak S

d::s
; QWERTY F -> Colemak T

f::t
; QWERTY G -> Colemak D
g::d

; QWERTY J -> Colemak N

j::n
; QWERTY K -> Colemak E

k::e
; QWERTY L -> Colemak I

l::i
; QWERTY semicolon -> Colemak O
`;::o

; QWERTY N -> Colemak K
n::k

