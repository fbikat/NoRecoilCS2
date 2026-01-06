#Requires AutoHotkey v2.0
#SingleInstance Force

scriptDir := A_ScriptDir
ConfigFile := scriptDir "\..\config\config.ini"
mouse := scriptDir "\..\config\mouse.ini"

; --- CONFIG LOADING, will default to these unless changed in the menu or config file ---
key_AK    := IniRead(ConfigFile, "KeyBinds", "AK", "F2")
key_M4A1  := IniRead(ConfigFile, "KeyBinds", "M4A1", "F3")
key_M4A4  := IniRead(ConfigFile, "KeyBinds", "M4A4", "F4")
key_Famas := IniRead(ConfigFile, "KeyBinds", "Famas", "F5")
key_Galil := IniRead(ConfigFile, "KeyBinds", "Galil", "F6")
key_UMP   := IniRead(ConfigFile, "KeyBinds", "UMP", "F7")
key_AUG   := IniRead(ConfigFile, "KeyBinds", "AUG", "Home")
key_SG    := IniRead(ConfigFile, "KeyBinds", "SG", "End")

key_off   := IniRead(ConfigFile, "KeyBinds", "off", "CapsLock") 
key_zoom  := IniRead(ConfigFile, "KeyBinds", "zoom", "RButton")

sens      := IniRead(ConfigFile, "Settings", "sens", "0.83")
zoomsens  := IniRead(ConfigFile, "Settings", "zoomsens", "1.0")
PauseKey  := IniRead(mouse, "Controls", "PauseKey", "Del")

smoothness := 0.7
modifier := 2.52 / Number(sens)
zoomsens := Number(zoomsens)
xDampener := 0.85 

currentWeapon := "none"
Paused := false
BoundKeys := [] 

SetupHotkeys()

SetupHotkeys() {
    global
    RegisterKey(key_M4A4, "M4A4")
    RegisterKey(key_M4A1, "M4A1")
    RegisterKey(key_Famas, "Famas")
    RegisterKey(key_AUG, "AUG")
    RegisterKey(key_AK, "AK")
    RegisterKey(key_Galil, "Galil")
    RegisterKey(key_SG, "SG")
    RegisterKey(key_UMP, "UMP")
    RegisterKey(key_off, "none")
    
    ; Mouse Hotkeys
    Hotkey("*~LButton", StartRecoil)
    Hotkey("*~LButton Up", StopRecoil)
    BoundKeys.Push("*~LButton", "*~LButton Up")
    
    try Hotkey(PauseKey, TogglePause)
}

RegisterKey(KeyName, WeaponName) {
    global BoundKeys
    if (KeyName = "")
        return
    try {
        Hotkey(KeyName, (*) => SelectWeapon(WeaponName))
        BoundKeys.Push(KeyName)
    } catch {
        MsgBox("Error registering key: " KeyName)
    }
}

SelectWeapon(weapon) {
    global currentWeapon
    currentWeapon := weapon
    ToolTip("Selected: " weapon)
    SetTimer(() => ToolTip(), -1500)
}

TogglePause(*) {
    global Paused, BoundKeys
    Paused := !Paused
    
    if Paused {
        for key in BoundKeys {
            try Hotkey(key, "Off")
        }
        ToolTip("PAUSED (Keys Unlocked)")
    } else {
        for key in BoundKeys {
            try Hotkey(key, "On")
        }
        ToolTip("RESUMED (NoRecoil Active)")
    }
    SetTimer(() => ToolTip(), -1500)
}

recoilActive := false
recoilStep := 0

StartRecoil(*) {
    global recoilActive, recoilStep, currentWeapon, Paused
    
    if (Paused || currentWeapon = "none")
        return

    if (KeyWait("LButton", "T0.1")) {
        return
    }
    
    recoilActive := true
    recoilStep := 0
    SetTimer(DoRecoil, 10)
}

StopRecoil(*) {
    global recoilActive
    recoilActive := false
    SetTimer(DoRecoil, 0)
}

DoRecoil() {
    global recoilActive, recoilStep, currentWeapon, modifier, smoothness, zoomsens, key_zoom, xDampener
    
    if (!recoilActive || !GetKeyState("LButton", "P")) {
        recoilActive := false
        SetTimer(DoRecoil, 0)
        return
    }
    
    pattern := GetRecoilPattern(currentWeapon)
    
    if (recoilStep >= pattern.Length) {
        Sleep(500)
        recoilStep := 0
        return
    }
    
    step := pattern[recoilStep + 1]
    
    x := step.x * modifier * xDampener 
    y := step.y * modifier
    delay := step.delay
    
    if (currentWeapon = "AUG" || currentWeapon = "SG") {
        if (!GetKeyState(key_zoom, "P")) {
            recoilStep++
            SetTimer(DoRecoil, delay)
            return
        }
        zom := 1.2 / zoomsens
        x := x * zom
        y := y * zom
    }
    
    MoveMouse(Integer(x), Integer(y))
    recoilStep++
    SetTimer(DoRecoil, delay)
}

MoveMouse(x, y) {
    DllCall("mouse_event", "UInt", 0x0001, "Int", x, "Int", y, "UInt", 0, "Ptr", 0)
}

GetRecoilPattern(weapon) {
    patterns := Map()
    patterns["AK"] := [{x: -4, y: 7, delay: 99}, {x: 4, y: 19, delay: 99}, {x: -3, y: 29, delay: 99}, {x: -1, y: 31, delay: 99}, {x: 13, y: 31, delay: 99}, {x: 8, y: 28, delay: 99}, {x: 13, y: 21, delay: 99}, {x: -17, y: 12, delay: 99}, {x: -42, y: -3, delay: 99}, {x: -21, y: 2, delay: 99}, {x: 12, y: 11, delay: 99}, {x: -15, y: 7, delay: 99}, {x: -26, y: -8, delay: 99}, {x: -3, y: 4, delay: 99}, {x: 40, y: 1, delay: 99}, {x: 19, y: 7, delay: 99}, {x: 14, y: 10, delay: 99}, {x: 27, y: 0, delay: 99}, {x: 33, y: -10, delay: 99}, {x: -21, y: -2, delay: 99}, {x: 7, y: 3, delay: 99}, {x: -7, y: 9, delay: 99}, {x: -8, y: 4, delay: 99}, {x: 19, y: -3, delay: 99}, {x: 5, y: 6, delay: 99}, {x: -20, y: -1, delay: 99}, {x: -33, y: -4, delay: 99}, {x: -45, y: -21, delay: 99}, {x: -14, y: 1, delay: 99}]
    patterns["M4A1"] := [{x: 1, y: 6, delay: 88}, {x: 0, y: 4, delay: 88}, {x: -4, y: 14, delay: 88}, {x: 4, y: 18, delay: 88}, {x: -6, y: 21, delay: 88}, {x: -4, y: 24, delay: 88}, {x: 14, y: 14, delay: 88}, {x: 8, y: 12, delay: 88}, {x: 18, y: 5, delay: 88}, {x: -4, y: 10, delay: 88}, {x: -14, y: 5, delay: 88}, {x: -25, y: -3, delay: 88}, {x: -19, y: 0, delay: 88}, {x: -22, y: -3, delay: 88}, {x: 1, y: 3, delay: 88}, {x: 8, y: 3, delay: 88}, {x: -9, y: 1, delay: 88}, {x: -13, y: -2, delay: 88}, {x: 3, y: 2, delay: 88}, {x: 1, y: 1, delay: 88}]
    patterns["M4A4"] := [{x: 2, y: 7, delay: 88}, {x: 0, y: 9, delay: 87}, {x: -6, y: 16, delay: 87}, {x: 7, y: 21, delay: 87}, {x: -9, y: 23, delay: 87}, {x: -5, y: 27, delay: 87}, {x: 16, y: 15, delay: 88}, {x: 11, y: 13, delay: 88}, {x: 22, y: 5, delay: 88}, {x: -4, y: 11, delay: 88}, {x: -18, y: 6, delay: 88}, {x: -30, y: -4, delay: 88}, {x: -24, y: 0, delay: 88}, {x: -25, y: -6, delay: 88}, {x: 0, y: 4, delay: 87}, {x: 8, y: 4, delay: 87}, {x: -11, y: 1, delay: 87}, {x: -13, y: -2, delay: 87}, {x: 2, y: 2, delay: 88}, {x: 33, y: -1, delay: 88}, {x: 10, y: 6, delay: 88}, {x: 27, y: 3, delay: 88}, {x: 10, y: 2, delay: 88}, {x: 11, y: 0, delay: 88}, {x: -12, y: 0, delay: 87}, {x: 6, y: 5, delay: 87}, {x: 4, y: 5, delay: 87}, {x: 3, y: 1, delay: 87}, {x: 4, y: -1, delay: 87}]
    patterns["Famas"] := [{x: -4, y: 5, delay: 88}, {x: 1, y: 4, delay: 88}, {x: -6, y: 10, delay: 88}, {x: -1, y: 17, delay: 88}, {x: 0, y: 20, delay: 88}, {x: 14, y: 18, delay: 88}, {x: 16, y: 12, delay: 88}, {x: -6, y: 12, delay: 88}, {x: -20, y: 8, delay: 88}, {x: -16, y: 5, delay: 88}, {x: -13, y: 2, delay: 88}, {x: 4, y: 5, delay: 87}, {x: 23, y: 4, delay: 88}, {x: 12, y: 6, delay: 88}, {x: 20, y: -3, delay: 88}, {x: 5, y: 0, delay: 88}, {x: 15, y: 0, delay: 88}, {x: 3, y: 5, delay: 80}, {x: -4, y: 3, delay: 88}, {x: -25, y: -1, delay: 80}, {x: -3, y: 2, delay: 84}, {x: 11, y: 0, delay: 80}, {x: 15, y: -7, delay: 88}, {x: 15, y: -10, delay: 88}]
    patterns["Galil"] := [{x: 4, y: 4, delay: 90}, {x: -2, y: 5, delay: 90}, {x: 6, y: 10, delay: 90}, {x: 12, y: 15, delay: 90}, {x: -1, y: 21, delay: 90}, {x: 2, y: 24, delay: 90}, {x: 6, y: 16, delay: 90}, {x: 11, y: 10, delay: 90}, {x: -4, y: 14, delay: 90}, {x: -22, y: 8, delay: 90}, {x: -30, y: -3, delay: 90}, {x: -29, y: -13, delay: 90}, {x: -9, y: 8, delay: 90}, {x: -12, y: 2, delay: 90}, {x: -7, y: 1, delay: 90}, {x: 0, y: 1, delay: 50}, {x: 4, y: 7, delay: 90}, {x: 25, y: 7, delay: 90}, {x: 14, y: 4, delay: 90}, {x: 25, y: -3, delay: 90}, {x: 31, y: -9, delay: 90}, {x: 6, y: 3, delay: 90}, {x: -12, y: 3, delay: 90}, {x: 13, y: -1, delay: 90}, {x: 10, y: -1, delay: 90}, {x: 16, y: -4, delay: 90}, {x: -9, y: 5, delay: 90}, {x: -32, y: -5, delay: 90}, {x: -24, y: -3, delay: 90}, {x: -15, y: 5, delay: 90}, {x: 6, y: 8, delay: 90}, {x: -14, y: -3, delay: 90}, {x: -24, y: -14, delay: 90}, {x: -13, y: -1, delay: 90}]
    patterns["UMP"] := [{x: -1, y: 6, delay: 90}, {x: -4, y: 8, delay: 90}, {x: -2, y: 18, delay: 90}, {x: -4, y: 23, delay: 90}, {x: -9, y: 23, delay: 90}, {x: -3, y: 26, delay: 90}, {x: 11, y: 17, delay: 90}, {x: -4, y: 12, delay: 90}, {x: 9, y: 13, delay: 90}, {x: 18, y: 8, delay: 90}, {x: 15, y: 5, delay: 90}, {x: -1, y: 3, delay: 90}, {x: 5, y: 6, delay: 90}, {x: 0, y: 6, delay: 90}, {x: 9, y: -3, delay: 90}, {x: 5, y: -1, delay: 90}, {x: -12, y: 4, delay: 90}, {x: -19, y: 1, delay: 85}, {x: -1, y: -2, delay: 90}, {x: 15, y: -5, delay: 90}, {x: 17, y: -2, delay: 85}, {x: -6, y: 3, delay: 90}, {x: -20, y: -2, delay: 90}, {x: -3, y: -1, delay: 90}]
    patterns["AUG"] := [{x: 4, y: 4, delay: 89}, {x: 0, y: 8, delay: 89}, {x: -3, y: 15, delay: 89}, {x: -5, y: 18, delay: 88}, {x: 4, y: 20, delay: 88}, {x: 6, y: 21, delay: 80}, {x: 10, y: 15, delay: 80}, {x: 4, y: 10, delay: 89}, {x: 10, y: 9, delay: 88}, {x: -11, y: 8, delay: 89}, {x: -4, y: 4, delay: 89}, {x: 9, y: 0, delay: 88}, {x: 1, y: 4, delay: 89}, {x: -15, y: 4, delay: 88}, {x: -26, y: -8, delay: 89}, {x: -22, y: -9, delay: 89}, {x: -2, y: 4, delay: 88}, {x: -3, y: 3, delay: 89}, {x: -6, y: 0, delay: 88}, {x: 17, y: 1, delay: 89}, {x: 22, y: 2, delay: 88}, {x: 11, y: 4, delay: 89}, {x: -3, y: 1, delay: 88}]
    patterns["SG"] := [{x: -3, y: 6, delay: 89}, {x: -9, y: 10, delay: 89}, {x: -6, y: 17, delay: 89}, {x: -4, y: 20, delay: 88}, {x: -6, y: 21, delay: 88}, {x: -5, y: 25, delay: 80}, {x: -14, y: 10, delay: 80}, {x: 10, y: 12, delay: 89}, {x: -6, y: 8, delay: 88}, {x: -10, y: 5, delay: 89}, {x: -3, y: 3, delay: 89}, {x: 4, y: 3, delay: 88}, {x: -6, y: 4, delay: 89}, {x: 1, y: 8, delay: 88}, {x: -10, y: -4, delay: 89}, {x: -14, y: -12, delay: 89}, {x: -12, y: -6, delay: 88}, {x: -6, y: -1, delay: 89}, {x: 28, y: 2, delay: 88}, {x: 39, y: -3, delay: 89}, {x: 30, y: -1, delay: 88}, {x: 12, y: 6, delay: 89}, {x: 10, y: 6, delay: 88}, {x: 4, y: 5, delay: 89}, {x: 15, y: -2, delay: 95}, {x: 20, y: -3, delay: 89}, {x: -4, y: 6, delay: 89}, {x: -10, y: 3, delay: 89}, {x: -26, y: -3, delay: 89}]
    
    if patterns.Has(weapon)
        return patterns[weapon]
    else
        return []
}

ToolTip("NoRecoil Ready - Binds: F2-F7, Home, End")
SetTimer(() => ToolTip(), -3000)