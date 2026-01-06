LibPath := A_ScriptDir "\..\lib\lib.ahk"
IniFile := A_ScriptDir "\..\config\config.ini"
ImgPath := A_ScriptDir "\..\img\cs2.png"

if FileExist(LibPath)
    Run(LibPath)
else
    MsgBox("Error: Could not find lib.ahk at:`n" LibPath)

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

if FileExist(ImgPath)
    MyGui.Add("Picture", "x412 y339 w60 h60", ImgPath)
else
    MyGui.Add("Text", "x412 y339 w60 h60", "No Image")

SaveBtn := MyGui.Add("Button", "x182 y379 w110 h20", "Save")
SaveBtn.OnEvent("Click", GenerateConfig)

Edit_zoomsens := MyGui.Add("Edit", "x12 y289 w90 h30 vzoomsenss")
Edit_sens := MyGui.Add("Edit", "x192 y289 w90 h30 vsenss")

MyGui.SetFont("S8 Cblue Bold Underline", "Comic Sans MS")
MyGui.Add("Text", "x422 y19 w40 h20", "FBI")

Edit_sens.Value := IniRead(IniFile, "Settings", "sens", "0.83")
Edit_zoomsens.Value := IniRead(IniFile, "Settings", "zoomsens", "1.0")
HK_M4A4.Value := IniRead(IniFile, "KeyBinds", "M4A4", "F4")
HK_AUG.Value := IniRead(IniFile, "KeyBinds", "AUG", "Home")
HK_SG.Value := IniRead(IniFile, "KeyBinds", "SG", "End")
HK_Galil.Value := IniRead(IniFile, "KeyBinds", "Galil", "F6")
HK_M4A1.Value := IniRead(IniFile, "KeyBinds", "M4A1", "F3")
HK_AK.Value := IniRead(IniFile, "KeyBinds", "AK", "F2")
HK_UMP.Value := IniRead(IniFile, "KeyBinds", "UMP", "F7")
HK_Famas.Value := IniRead(IniFile, "KeyBinds", "Famas", "F5")
HK_off.Value := IniRead(IniFile, "KeyBinds", "Off", "CapsLock")
HK_zoom.Text := IniRead(IniFile, "KeyBinds", "Zoom", "RButton")

MyGui.OnEvent("Close", GuiClose)
MyGui.Show("x599 y260 h417 w489")
return

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
        
        MsgBox("Settings have been saved!")
        
        if WinExist("lib.ahk")
            WinClose("lib.ahk")
        Run(A_ScriptDir "\..\lib\lib.ahk")
        
    } catch as e {
        MsgBox("Error writing config: " e.Message)
    }
}

GuiClose(*) {
    ExitApp()
}