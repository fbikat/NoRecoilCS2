scriptDir := A_ScriptDir
IniFile := scriptDir "config.ini" 
mouse := scriptDir "mouse.ini"

currentWeapon := "none"
Paused := false
BoundKeys := [] 

key_AK    := IniRead(IniFile, "KeyBinds", "AK", "F2")
key_M4A1  := IniRead(IniFile, "KeyBinds", "M4A1", "F3")
key_M4A4  := IniRead(IniFile, "KeyBinds", "M4A4", "F4")
key_Famas := IniRead(IniFile, "KeyBinds", "Famas", "F5")
key_Galil := IniRead(IniFile, "KeyBinds", "Galil", "F6")
key_UMP   := IniRead(IniFile, "KeyBinds", "UMP", "F7")
key_AUG   := IniRead(IniFile, "KeyBinds", "AUG", "Home")
key_SG    := IniRead(IniFile, "KeyBinds", "SG", "End")
key_off   := IniRead(IniFile, "KeyBinds", "off", "CapsLock") 
key_zoom  := IniRead(IniFile, "KeyBinds", "zoom", "RButton")

sens      := IniRead(IniFile, "Settings", "sens", "0.83")
zoomsens  := IniRead(IniFile, "Settings", "zoomsens", "1.0")
PauseKey  := IniRead(mouse, "Controls", "PauseKey", "Del")

smoothness := 0.7
modifier := 2.52 / Number(sens)
zoomsens := Number(zoomsens)
xDampener := 0.85 

SetupHotkeys()

MyGui := Gui()
MyGui.SetFont("S10 CGreen Bold", "Comic Sans MS")
MyGui.Add("Text", "x2 y-1 w480 h20 +Center", "AHK NoRecoil CS2")
MyGui.SetFont("S8 CBlack Bold", "Comic Sans MS")
MyGui.Add("Tab", "x2 y19 w480 h390", ["Keybinds"])

MyGui.Add("GroupBox", "x2 y59 w110 h60", "M4A4")
MyGui.Add("GroupBox", "x362 y59 w110 h60", "Famas")
MyGui.Add("GroupBox", "x182 y59 w110 h60", "M4A1")
MyGui.Add("GroupBox", "x2 y129 w110 h60", "AUG")
MyGui.Add("GroupBox", "x182 y129 w110 h60", "AK")
MyGui.Add("GroupBox", "x362 y129 w110 h60", "Galil")
MyGui.Add("GroupBox", "x2 y199 w110 h60", "SG")
MyGui.Add("GroupBox", "x182 y199 w110 h60", "UMP")
MyGui.Add("GroupBox", "x362 y199 w110 h60", "off")
MyGui.Add("GroupBox", "x2 y269 w110 h60 CRed", "zoomsens")
MyGui.Add("GroupBox", "x182 y269 w110 h60 CRed", "sens")
MyGui.Add("GroupBox", "x362 y269 w110 h60", "hold zoom")

HK_M4A4  := MyGui.Add("Hotkey", "x12 y79 w90 h30 vM4A4")
HK_AUG   := MyGui.Add("Hotkey", "x12 y149 w90 h30 vAUG")
HK_SG    := MyGui.Add("Hotkey", "x12 y219 w90 h30 vSG")
HK_M4A1  := MyGui.Add("Hotkey", "x192 y79 w90 h30 vM4A1")
HK_AK    := MyGui.Add("Hotkey", "x192 y149 w90 h30 vAK")
HK_UMP   := MyGui.Add("Hotkey", "x192 y219 w90 h30 vUMP")
HK_Famas := MyGui.Add("Hotkey", "x372 y79 w90 h30 vFamas")
HK_Galil := MyGui.Add("Hotkey", "x372 y149 w90 h30 vGalil")
HK_off   := MyGui.Add("Hotkey", "x372 y219 w90 h30 voff")

CommonKeys := ["RButton", "LAlt", "LShift", "LCtrl", "XButton1", "XButton2"]
HK_zoom  := MyGui.Add("ComboBox", "x372 y289 w90 h60 vzoom", CommonKeys)

MyGui.SetFont("S7 CBlack Bold", "Comic Sans MS")
MyGui.SetFont("S10 CBlack", "Comic Sans MS")
MyGui.Add("Text", "x42 y359 w390 h20 +Center", "You can change recoil weapon keys as you wish")
MyGui.Add("Text", "x42 y339 w390 h20 CRed +Center", "Important: Set your game sensitivity")

SaveBtn := MyGui.Add("Button", "x182 y379 w110 h20", "Save & Reload")
SaveBtn.OnEvent("Click", GenerateConfig)

Edit_zoomsens := MyGui.Add("Edit", "x12 y289 w90 h30 vzoomsenss")
Edit_sens := MyGui.Add("Edit", "x192 y289 w90 h30 vsenss")

MyGui.SetFont("S8 Cblue Bold Underline", "Comic Sans MS")
MyGui.Add("Text", "x422 y19 w40 h20", "FBI")

Edit_sens.Value := sens
Edit_zoomsens.Value := zoomsens
HK_M4A4.Value := key_M4A4
HK_AUG.Value := key_AUG
HK_SG.Value := key_SG
HK_Galil.Value := key_Galil
HK_M4A1.Value := key_M4A1
HK_AK.Value := key_AK
HK_UMP.Value := key_UMP
HK_Famas.Value := key_Famas
HK_off.Value := key_off
HK_zoom.Text := key_zoom

MyGui.OnEvent("Close", GuiClose)
MyGui.Show("x599 y260 h417 w489")

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
    
    ; Recoil Activation
    Hotkey("*~LButton", StartRecoil)
    Hotkey("*~LButton Up", StopRecoil)
    BoundKeys.Push("*~LButton", "*~LButton Up")
    
    ; Pause Key
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
        ; Ignore errors
    }
}

SelectWeapon(weapon) {
    global currentWeapon, Paused
    if (Paused)
        return
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

GenerateConfig(*) {
    global MyGui, IniFile
    
    saved := MyGui.Submit(false)
    
    try {
        IniWrite(saved.senss, IniFile, "Settings", "sens")
        IniWrite(saved.zoomsenss, IniFile, "Settings", "zoomsens")
        IniWrite(saved.M4A4, IniFile, "KeyBinds", "M4A4")
        IniWrite(saved.AUG, IniFile, "KeyBinds", "AUG")
        IniWrite(saved.SG, IniFile, "KeyBinds", "SG")
        IniWrite(saved.Galil, IniFile, "KeyBinds", "Galil")
        IniWrite(saved.M4A1, IniFile, "KeyBinds", "M4A1")
        IniWrite(saved.AK, IniFile, "KeyBinds", "AK")
        IniWrite(saved.UMP, IniFile, "KeyBinds", "UMP")
        IniWrite(saved.zoom, IniFile, "KeyBinds", "Zoom")
        IniWrite(saved.Famas, IniFile, "KeyBinds", "Famas")
        IniWrite(saved.off, IniFile, "KeyBinds", "Off")
        
        MsgBox("Settings have been saved! The script will now reload.")
        Reload()
        
    } catch as e {
        MsgBox("Error writing config: " e.Message)
    }
}

GuiClose(*) {
    ExitApp()
}