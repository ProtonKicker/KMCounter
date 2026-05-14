/*
Known issue: display dimensions don't auto-update on monitor change
*/
/*
Original project
https://github.com/telppa/KMCounter
https://www.autoahk.com/archives/35147
*/
;Compile info - All directives removed for compilation compatibility

#NoEnv
#SingleInstance Force
SetBatchLines, -1

global APPName:="KMCounter", ver:=3.8
     , today:=SubStr(A_Now, 1, 8)
     , tomorrow:=EnvAdd(today, 1, "Days", 1, 8)
     , DataStorageDays, firstday
     , devicecaps:={}, layout:={}
     , hHookMouse, mouse:={}
     , hHookKeyboard, keyboard:={}
     , ControlColors:={}, ControlBrushes:={}

gosub, MultiLanguage
gosub, Welcome
LoadData(today)
gosub, BlockClickOnGui1
gosub, CreateMenu
gosub, CreateGui1
gosub, CreateGui2

HookMouse()
HookKeyboard()

SetTimer, Reload, % countdown()
SetTimer, ReloadHook, % 60000*10
OnMessage(0x0138, "WM_CTLCOLORSTATIC")
OnExit("ExitFunc")

return

Welcome:
IfNotExist, KMCounter.ini
  ; Removed welcome message for compilation compatibility
return

CreateGui1:
  Gui, Destroy
  ControlList:=LoadControlList(layout)
  Opt   := ControlList.Opt
  scale := A_ScreenDPI/96

  Gui, -DPIScale +HwndhWin
  Gui, Color, % Opt.BackgroundColor, % Opt.BackgroundColor
  Gui, Font, % "S" Opt.FontSize//scale " c" Opt.TextColor, % Opt.Font

  ; Title bar - clean header
  Gui, Font, s14 Bold c1E293B, Microsoft YaHei
  Gui, Add, Text, x16 y12 wauto h28 Section, %APPName%
  Gui, Font, s8 c64748B, Microsoft YaHei
  Gui, Add, Text, xs+90 ys+7 wauto h16, v%ver%
  Gui, Font, s10 c3B82F6, Microsoft YaHei
  Gui, Add, Text, x+25 ys+3 wauto h22 vDateDisplay

  for k, control in ControlList
  {
    p:=""
    for k1, optname in ["x", "y", "w", "h", "Hwnd"]
    {
      if (control[optname]!="")
        p.=" " optname control[optname]
    }
    if (InStr(control.Hwnd, "sc"))
    {
      p.=" vkey" control.Hwnd
      Gui, Add, Text, % "C" Opt.TextColor " Center -WantCtrlA -TabStop" p, % control.Text
      GuiControlGet, hCtrl, Hwnd, % "key" control.Hwnd
      MakeRoundRect(hCtrl, control.w, control.h, 4)
    }
    else if (control.Hwnd="Message")
    {
      p.=" vmsg" control.Hwnd
      Gui, Add, ListView, % "C" Opt.TextColor " Count10 -Hdr -HScroll" p, % L_gui1_LV标题
      GuiControlGet, hLV, Hwnd, msgMessage
      for k1, field in [L_gui1_鼠标移动, L_gui1_键盘敲击
                      , L_gui1_左键点击, L_gui1_右键点击, L_gui1_中键点击
                      , L_gui1_滚轮滚动, L_gui1_滚轮横滚
                      , L_gui1_侧键点击
                      , L_gui1_屏幕尺寸]
        LV_Add("", field)
      LV_ModifyCol(1, 100)
      LV_ModifyCol(2, (control.w-100-40)//2)
      LV_ModifyCol(3, (control.w-100-40)//2)
    }
  }

  Gui, Show, Hide
return

; Scroll/page keys switch history in stats view
#If (WinActive("ahk_id " hWin))
WheelDown::
WheelUp::
PgDn::
PgUp::
Down::
Up::
  Critical
  ; Set default
  NonNull(history, today)
  loop, % DataStorageDays+1
  {
    switch, A_ThisHotkey
    {
      case, "WheelDown","PgDn","Down": history:=EnvAdd(history, -1, "Days", 1, 8)  ; previous day
      case, "WheelUp","PgUp","Up":     history:=EnvAdd(history,  1, "Days", 1, 8)  ; next day
    }
    ; Cycle between today, total, and first day
    if (history > tomorrow)
      history := firstday
    if (history < firstday)
      history := tomorrow

    ; Show all data
    if (history = tomorrow)
    {
      date := "Total"
      gosub, ShowHeatMap
      break
    }
    ; Found data different from current, refresh
    if (LoadData(history) and date!=history)
    {
      date := history
      gosub, ShowHeatMap
      break
    }
  }
return
#If

GuiEscape:
GuiClose:
  Gui, Hide
  history:=""
  btt()
return

CreateGui2:
{
  Gui, 2:Color, F5F6F8, F5F6F8

  Gui, 2:Font, s16 Bold c1E293B, Microsoft YaHei
  Gui, 2:Add, Text, x20 y20 w360 h30 +0x200, %L_gui2_设置%
  Gui, 2:Font

  Gui, 2:Font, s11 Bold c3B82F6, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+50 w360 h24, %L_gui2_历史数据%
  Gui, 2:Font
  Gui, 2:Font, c475569, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+28 w360 h20, %L_gui2_sub1%
  Gui, 2:Add, Text, x20 yp+28 w80 h23, %L_gui2_存储%:
  Gui, 2:Add, Edit, x105 yp-2 w70 h23 Number Limit -Multi vdsd, % DataStorageDays
  Gui, 2:Add, Text, x183 yp+2 w40 h23, %L_gui2_天%

  Gui, 2:Font, s11 Bold c3B82F6, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+40 w360 h24, %L_gui2_屏幕尺寸%
  Gui, 2:Font
  Gui, 2:Font, c475569, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+28 w360 h20, %L_gui2_sub2%
  Gui, 2:Add, Text, x20 yp+26 w80 h23, %L_gui2_屏幕宽%:
  Gui, 2:Add, Edit, x105 yp-2 w70 h23 Number Limit -Multi vdw, % devicecaps.w
  Gui, 2:Add, Text, x183 yp+2 w40 h23, %L_gui2_毫米%
  Gui, 2:Add, Text, x20 yp+32 w80 h23, %L_gui2_屏幕高%:
  Gui, 2:Add, Edit, x105 yp-2 w70 h23 Number Limit -Multi vdh, % devicecaps.h
  Gui, 2:Add, Text, x183 yp+2 w40 h23, %L_gui2_毫米%

  Gui, 2:Font, s11 Bold c3B82F6, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+40 w360 h24, %L_gui2_键盘布局%
  Gui, 2:Font
  Gui, 2:Font, c475569, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+28 w360 h20, %L_gui2_sub3%
  Gui, 2:Add, Text, x20 yp+26 w80 h23, %L_gui2_键宽%:
  Gui, 2:Add, Edit, x105 yp-2 w60 h23 Number Limit -Multi vlkw, % layout.kw
  Gui, 2:Add, Text, x173 yp+2 w40 h23, %L_gui2_像素%
  Gui, 2:Add, Text, x220 yp-25 w80 h23, %L_gui2_键高%:
  Gui, 2:Add, Edit, x270 yp-2 w60 h23 Number Limit -Multi vlkh, % layout.kh
  Gui, 2:Add, Text, x338 yp+2 w40 h23, %L_gui2_像素%
  Gui, 2:Add, Text, x20 yp+32 w80 h23, %L_gui2_键间距%:
  Gui, 2:Add, Edit, x105 yp-2 w60 h23 Number Limit -Multi vlks, % layout.ks
  Gui, 2:Add, Text, x173 yp+2 w40 h23, %L_gui2_像素%
  Gui, 2:Add, Text, x20 yp+32 w100 h23, %L_gui2_区域水平间距%:
  Gui, 2:Add, Edit, x105 yp-2 w60 h23 Number Limit -Multi vlkhs, % layout.khs
  Gui, 2:Add, Text, x173 yp+2 w40 h23, %L_gui2_像素%
  Gui, 2:Add, Text, x220 yp-25 w100 h23, %L_gui2_区域垂直间距%:
  Gui, 2:Add, Edit, x270 yp-2 w60 h23 Number Limit -Multi vlkvs, % layout.kvs
  Gui, 2:Add, Text, x338 yp+2 w40 h23, %L_gui2_像素%

  Gui, 2:Font, s11 Bold c3B82F6, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+40 w360 h24, %L_gui2_键盘外观%
  Gui, 2:Font
  Gui, 2:Font, c475569, Microsoft YaHei
  Gui, 2:Add, Text, x20 yp+28 w80 h23, %L_gui2_字体大小%:
  Gui, 2:Add, Edit, x105 yp-2 w60 h23 Number Limit -Multi vlfs, % layout.fs
  Gui, 2:Add, Text, x173 yp+2 w40 h23, %L_gui2_号%
  Gui, 2:Add, Text, x20 yp+32 w80 h23, %L_gui2_起始颜色%:
  Gui, 2:Add, Edit, x105 yp-2 w120 h23 -Multi vhighlightStart, % layout.highlightStart
  Gui, 2:Add, Text, x20 yp+32 w80 h23, %L_gui2_结束颜色%:
  Gui, 2:Add, Edit, x105 yp-2 w120 h23 -Multi vhighlightEnd, % layout.highlightEnd

  Gui, 2:Add, Button, x20 yp+48 w100 h30 gCancelSetting, %L_gui2_取消%
  Gui, 2:Add, Button, x130 yp+0 w100 h30 gSaveSetting, %L_gui2_保存%
  Gui, 2:Add, Button, x240 yp+0 w130 h30 gRestoreDefaultSetting, %L_gui2_恢复默认%

  Gui, 2:Show, w400 h640 Hide
}
return

CancelSetting:
2GuiEscape:
2GuiClose:
  Gui, 2:Hide
return

SaveSetting:
  Gui, 2:Submit
  ; Clamp storage days min=0, default=30
  DataStorageDays := NonNull_Ret(dsd, 30, 0)
  UpdateDeviceCaps(dw, dh)
  UpdateLayout(lkw, lkh, lks, lkhs, lkvs, lfs, highlightStart, highlightEnd)
  ; Reload to apply settings
  gosub, Reload
return

RestoreDefaultSetting:
  ; Reset all to defaults
  ratio := A_ScreenWidth<1920 ? A_ScreenWidth/1920 : 1
  
  ; Restore default storage days
  DataStorageDays := 30
  GuiControl, 2:, dsd, % DataStorageDays
  
  ; Restore default screen size (empty=auto)
  GuiControl, 2:, dw, 
  GuiControl, 2:, dh, 
  UpdateDeviceCaps("", "")
  
  ; Restore default keyboard layout
  defaultKw := Round(52*ratio)
  defaultKh := Round(45*ratio)
  defaultKs := Round(2*ratio)
  defaultKhs := Round(10*ratio)
  defaultKvs := Round(10*ratio)
  defaultFs := 9
  defaultHighlightStart := "D1D5DB"
  defaultHighlightEnd := "3B82F6"
  
  GuiControl, 2:, lkw, % defaultKw
  GuiControl, 2:, lkh, % defaultKh
  GuiControl, 2:, lks, % defaultKs
  GuiControl, 2:, lkhs, % defaultKhs
  GuiControl, 2:, lkvs, % defaultKvs
  GuiControl, 2:, lfs, % defaultFs
  GuiControl, 2:, highlightStart, % defaultHighlightStart
  GuiControl, 2:, highlightEnd, % defaultHighlightEnd
  
  ; Update layout settings
  UpdateLayout(defaultKw, defaultKh, defaultKs, defaultKhs, defaultKvs, defaultFs, defaultHighlightStart, defaultHighlightEnd)
  
  ; Save defaults to INI
  IniWrite, 30, KMCounter.ini, history, storage
  IniDelete, KMCounter.ini, devicecaps, w
  IniDelete, KMCounter.ini, devicecaps, h
  IniWrite, % defaultKw, KMCounter.ini, layout, kw
  IniWrite, % defaultKh, KMCounter.ini, layout, kh
  IniWrite, % defaultKs, KMCounter.ini, layout, ks
  IniWrite, % defaultKhs, KMCounter.ini, layout, khs
  IniWrite, % defaultKvs, KMCounter.ini, layout, kvs
  IniWrite, 9, KMCounter.ini, layout, fs
  IniWrite, D1D5DB, KMCounter.ini, layout, highlightStart
  IniWrite, 3B82F6, KMCounter.ini, layout, highlightEnd
  
  ; Show success message
  MsgBox, 0x40040, % L_gui2_恢复默认, % L_gui2_已恢复
return

Reload:
  Reload
return

ReloadHook:
  ; Reload hooks if user scripts run after us to stay first in chain
  DllCall("UnhookWindowsHookEx", "UInt", hHookMouse)
  DllCall("UnhookWindowsHookEx", "UInt", hHookKeyboard)
  HookMouse()
  HookKeyboard()
return

CreateMenu:
{
  Menu, Tray, NoStandard                           ; Hide default AHK menu
  Menu, Tray, Tip, %APPName% v%ver%                ; Tray tip
  Menu, Tray, Add, %L_menu_统计%,     MenuHandler  ; Create menu item
  Menu, Tray, Add, %L_menu_设置%,     MenuHandler
  Menu, Tray, Add                                  ; Separator
  Menu, Tray, Add, %L_menu_开机启动%, MenuHandler
  Menu, Tray, Add, %L_menu_布局定制%, MenuHandler
  Menu, Tray, Add
  Menu, Tray, Add, %L_menu_退出%,     MenuHandler
  Menu, Tray, Default, %L_menu_统计%               ; Set Statistics as default

  ; Removed ImagePutHIcon calls and menu icons for compilation compatibility
  if (!A_IsCompiled)
    Menu, Tray, Icon, resouces\%APPName%.ico         ; Load tray icon

  IfExist, %A_Startup%\%APPName%.Lnk                 ; Check startup folder for shortcut
    Menu, Tray, Check, %L_menu_开机启动%
}
return

MenuHandler:
  if (A_ThisMenuItem = L_menu_统计)
  {
    date := today
    gosub, ShowHeatMap
  }

  if (A_ThisMenuItem = L_menu_设置)
  {
    GuiControl, 2:, dw,   % devicecaps.w
    GuiControl, 2:, dh,   % devicecaps.h
    GuiControl, 2:, lkw,  % layout.kw
    GuiControl, 2:, lkh,  % layout.kh
    GuiControl, 2:, lks,  % layout.ks
    GuiControl, 2:, lkhs, % layout.khs
    GuiControl, 2:, lkvs, % layout.kvs
    GuiControl, 2:, lfs,  % layout.fs
    GuiControl, 2:, highlightStart, % layout.highlightStart
    GuiControl, 2:, highlightEnd, % layout.highlightEnd
    Gui, 2:Show, , %L_gui2_设置%
  }

  if (A_ThisMenuItem = L_menu_开机启动)
  {
    IfExist, %A_Startup%\%APPName%.Lnk
    {
      FileDelete, %A_Startup%\%APPName%.Lnk
      Menu, Tray, UnCheck, %L_menu_开机启动%
    }
    else
    {
      FileCreateShortcut, %A_ScriptFullPath%, %A_Startup%\%APPName%.Lnk, %A_ScriptDir%
      Menu, Tray, Check, %L_menu_开机启动%
    }
  }

  if (A_ThisMenuItem = L_menu_布局定制)
  {
    Run, https://github.com/telppa/KMCounter
    Run, https://www.autoahk.com/archives/35147
  }

  if (A_ThisMenuItem = L_menu_退出)
    ExitApp
return

ShowHeatMap:
{
  GuiControl, , DateDisplay, % date = tomorrow ? "Total" : date

  Gui, Show, , % Format("{1} v{2} | {3} - {4}", APPName, ver, L_gui1_当前显示数据, date)
  ; Show text stats first
  LV_Modify(1,,, Format("{:.2f} {2}", mouse[date].move,          L_gui1_米), Format("{:.2f} {2}", mouse.total.move,          L_gui1_米))
  LV_Modify(2,,, Format("{1} {2}",    keyboard[date].keystrokes, L_gui1_次), Format("{1} {2}",    keyboard.total.keystrokes, L_gui1_次))
  LV_Modify(3,,, Format("{1} {2}",    mouse[date].lbcount,       L_gui1_次), Format("{1} {2}",    mouse.total.lbcount,       L_gui1_次))
  LV_Modify(4,,, Format("{1} {2}",    mouse[date].rbcount,       L_gui1_次), Format("{1} {2}",    mouse.total.rbcount,       L_gui1_次))
  LV_Modify(5,,, Format("{1} {2}",    mouse[date].mbcount,       L_gui1_次), Format("{1} {2}",    mouse.total.mbcount,       L_gui1_次))
  LV_Modify(6,,, Format("{1} {2}",    mouse[date].wheel,         L_gui1_次), Format("{1} {2}",    mouse.total.wheel,         L_gui1_次))
  LV_Modify(7,,, Format("{1} {2}",    mouse[date].hwheel,        L_gui1_次), Format("{1} {2}",    mouse.total.hwheel,        L_gui1_次))
  LV_Modify(8,,, Format("{1} {2}",    mouse[date].xbcount,       L_gui1_次), Format("{1} {2}",    mouse.total.xbcount,       L_gui1_次))
  LV_Modify(9,,, Format("{:.1f} {2}", devicecaps.size,           L_gui1_寸))
  ; Wait for enough data to avoid color errors
  if (keyboard[date].keystrokes >= 100)
  {
    ; Generate gradient colors
    colors   := getcolors("0x" layout.highlightStart, "0x" layout.highlightEnd, 100)
    ; Set 10% of total as comparison
    maxcount := keyboard[date].keystrokes / 10
    for k, count in keyboard[date]
    {
      ; Count >= max => darkest
      if (count >= maxcount)
        color := colors[100]
      ; Count < 1% of max => lightest
      else if (count < maxcount/100)
        color := colors[1]
      ; Color by percentage of max
      else
        color := colors[Floor(count/maxcount*100)]

      ; Apply key color
      ChangeControlColor(k, color, Opt.TextColor)
    }
  }
  else
  {
    ; Show insufficient data message
    for k, count in keyboard[date]
      ChangeControlColor(k, Opt.BackgroundColor, Opt.TextColor)
    MsgBox 0x42040, , %L_gui1_msgbox%
  }
}
return

WM_MOUSEMOVE()
{
  static init:=OnMessage(0x200, "WM_MOUSEMOVE"), IsMessageMaximized:=0
  global date, L_gui1_次, ControlList
  if (A_Gui = 1)
  {
    if (A_GuiControl = "msgMessage")
    {
      if (IsMessageMaximized = 0)
      {
        ; Expand info on mouse hover
        GuiControl, Move, msgMessage, % "h" layout.kh*6+layout.khs+layout.ks*4
        ; Show headers
        GuiControl, +Hdr, msgMessage
        ; Hide keys to prevent overlap
        for k, v in ControlList.Covered
          GuiControl, Hide, % "key" v
        IsMessageMaximized := 1
      }
    }
    else
    {
      if (IsMessageMaximized = 1)
      {
        ; Restore info to compact
        GuiControl, Move, msgMessage, % "h" layout.kh
        ; Hide headers
        GuiControl, -Hdr, msgMessage
        ; Show keys
        for k, v in ControlList.Covered
          GuiControl, Show, % "key" v
        IsMessageMaximized := 0
      }

      ; Show key count on hover
      key:=SubStr(A_GuiControl, 4)
      if (keyboard[date].HasKey(key))
        btt(keyboard[date][key] " " L_gui1_次,,,,"Style2")
      else
        btt()
    }
  }
  else
    btt()
}

BlockClickOnGui1:
{
  OnMessage(0x0201, "BlockClick")   ; LButton down
  OnMessage(0x0202, "BlockClick")   ; LButton up
  OnMessage(0x0203, "BlockClick")   ; LButton double
  OnMessage(0x0204, "BlockClick")   ; RButton down
  OnMessage(0x0205, "BlockClick")   ; RButton up
  OnMessage(0x0206, "BlockClick")   ; RButton double
}
return

BlockClick(wParam, lParam, msg, hwnd)
{
  if (A_Gui=1)
    return, 0
}

ExitFunc(ExitReason, ExitCode)
{
  DllCall("UnhookWindowsHookEx", "UInt", hHookMouse)
  DllCall("UnhookWindowsHookEx", "UInt", hHookKeyboard)
  FreeControlColors()
  SaveData()
}

LoadData(date)
{
  ; Get storage days
  DataStorageDays := IniRead("KMCounter.ini", "history", "storage", 30)
  firstday        := EnvAdd(today, -DataStorageDays, "Days", 1, 8)

  ; Delete expired data
  SectionNames := StrSplit(IniRead("KMCounter.ini"), "`n", " `t`r`n`v`f")
  SavedSectionNames:={}
  for k, SectionName in SectionNames
  {
    if SectionName is integer
    {
      if (SectionName < firstday)                ; Before firstday = expired
        IniDelete, KMCounter.ini, %SectionName%  ; Need to omit last param to delete section, use command syntax
      else
        SavedSectionNames[SectionName]:=""
    }
  }
  ; Return false if no history
  if (!SavedSectionNames.HasKey(date) and date!=today)
    return, false
  ; Return true if data exists
  if (IsObject(mouse[date]) or IsObject(keyboard[date]))
    return, true

  ; Get screen info
  devicecaps.w := IniRead("KMCounter.ini", "devicecaps", "w", " ")            ; Pass space to make default empty
  devicecaps.h := IniRead("KMCounter.ini", "devicecaps", "h", " ")
  UpdateDeviceCaps(devicecaps.w, devicecaps.h)                                ; Update devicecaps
  ; Load layout
  ratio        := A_ScreenWidth<1920 ? A_ScreenWidth/1920 : 1                 ; HiDPI screens have DPIScale, skip scaling
  layout.kw    := IniRead("KMCounter.ini", "layout", "kw",  Round(52*ratio))  ; Key width
  layout.kh    := IniRead("KMCounter.ini", "layout", "kh",  Round(45*ratio))  ; Key height
  layout.ks    := IniRead("KMCounter.ini", "layout", "ks",  Round(2*ratio))   ; Key spacing
  layout.khs   := IniRead("KMCounter.ini", "layout", "khs", Round(10*ratio))  ; Horizontal section spacing
  layout.kvs   := IniRead("KMCounter.ini", "layout", "kvs", Round(10*ratio))  ; Vertical section spacing
  layout.fs    := IniRead("KMCounter.ini", "layout", "fs",  9)                ; Font size
  layout.highlightStart := IniRead("KMCounter.ini", "layout", "highlightStart", "D1D5DB")  ; Highlight start color
  layout.highlightEnd := IniRead("KMCounter.ini", "layout", "highlightEnd", "3B82F6")  ; Highlight end color
  ; Get mouse data
  for k, v in ["lbcount", "rbcount", "mbcount", "xbcount", "wheel", "hwheel", "move"]
  {
    mouse[date, v]    := IniRead("KMCounter.ini", date,    v, 0)
    mouse["total", v] := IniRead("KMCounter.ini", "total", v, 0)
  }
  ; Get key data
  for k, control in LoadControlList()
  {
    if (InStr(control.Hwnd, "sc"))
    {
      keyboard[date, control.Hwnd]    := IniRead("KMCounter.ini", date,    control.Hwnd, 0)
      keyboard["total", control.Hwnd] := IniRead("KMCounter.ini", "total", control.Hwnd, 0)
    }
  }
  keyboard[date].keystrokes           := IniRead("KMCounter.ini", date,    "keystrokes", 0)
  keyboard["total"].keystrokes        := IniRead("KMCounter.ini", "total", "keystrokes", 0)

  return, true
}

SaveData()
{
  ; Save storage days
  IniWrite(DataStorageDays, "KMCounter.ini", "history", "storage")
  ; Save screen info
  IniWrite(devicecaps.w,  "KMCounter.ini", "devicecaps", "w")
  IniWrite(devicecaps.h,  "KMCounter.ini", "devicecaps", "h")
  ; Save layout info
  IniWrite(layout.kw,     "KMCounter.ini", "layout", "kw")
  IniWrite(layout.kh,     "KMCounter.ini", "layout", "kh")
  IniWrite(layout.ks,     "KMCounter.ini", "layout", "ks")
  IniWrite(layout.khs,    "KMCounter.ini", "layout", "khs")
  IniWrite(layout.kvs,    "KMCounter.ini", "layout", "kvs")
  IniWrite(layout.fs,     "KMCounter.ini", "layout", "fs")
  IniWrite(layout.highlightStart, "KMCounter.ini", "layout", "highlightStart")
  IniWrite(layout.highlightEnd, "KMCounter.ini", "layout", "highlightEnd")
  ; Save mouse data
  for k, v in ["lbcount", "rbcount", "mbcount", "xbcount", "wheel", "hwheel", "move"]
  {
    IniWrite(mouse[today][v],   "KMCounter.ini",   today, v)
    IniWrite(mouse["total"][v], "KMCounter.ini", "total", v)
  }
  ; Save key data
  for k, v in keyboard[today]
    IniWrite(v, "KMCounter.ini", today, k)
  for k, v in keyboard["total"]
    IniWrite(v, "KMCounter.ini", "total", k)
}

HookMouse()
{
  ; Global mouse hook
  hHookMouse := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
                      , "Int", WH_MOUSE_LL := 14
                      , "Ptr", RegisterCallback("LowLevelMouseProc", "Fast", 3)
                      , "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
                      , "UInt", 0, "Ptr")
}
; https://docs.microsoft.com/en-us/previous-versions/windows/desktop/legacy/ms644986(v=vs.85)
; MS docs don't list 0x0208, 0x020C values
LowLevelMouseProc(nCode, wParam, lParam)
{
  static oldx, oldy, init:=MouseGetPos(oldx, oldy)
  Critical
  ; lParam is a pointer, e.g. &lParam=0x123, lParam=0x456
  ; Its address holds the real data address
  ; NumGet(lParam, 12) reads the pointer value as uint
  ; NumGet(lParam+0, 12) reads the value at the pointed address
  flags := NumGet(lParam+0, 12, "UInt") & 0x1                            ; physical=0, simulated=1
  if (nCode>=0 and flags=0)
  {
    switch, wParam
    {
      case, 0x0200:                                                      ; WM_MOUSEMOVE   = 0x0200
          x := NumGet(lParam+0, 0, "Int")
        , y := NumGet(lParam+0, 4, "Int")
        , d := Sqrt((x-oldx)**2 + (y-oldy)**2)                           ; Pythagorean distance
        , d := d * devicecaps.w / A_ScreenWidth / 1000                   ; Convert pixels to meters
        , oldx := x, oldy := y
        , mouse[today].move += d
        , mouse.total.move  += d
      case, 0x0202: mouse[today].lbcount += 1, mouse.total.lbcount += 1  ; WM_LBUTTONUP   = 0x0202
      case, 0x0205: mouse[today].rbcount += 1, mouse.total.rbcount += 1  ; WM_RBUTTONUP   = 0x0205
      case, 0x0208: mouse[today].mbcount += 1, mouse.total.mbcount += 1  ; WM_MBUTTONUP   = 0x0208
      case, 0x020C: mouse[today].xbcount += 1, mouse.total.xbcount += 1  ; WM_XBUTTONUP   = 0x020C
      case, 0x020A: mouse[today].wheel   += 1, mouse.total.wheel   += 1  ; WM_MOUSEWHEEL  = 0x020A
      case, 0x020E: mouse[today].hwheel  += 1, mouse.total.hwheel  += 1  ; WM_MOUSEHWHEEL = 0x020E
    }
  }
  ; CallNextHookEx passes to other hooks
  ; Return non-zero to discard message
  return, DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
}

HookKeyboard()
{
  ; Global keyboard hook
  hHookKeyboard := DllCall("SetWindowsHookEx" . (A_IsUnicode ? "W" : "A")
                         , "Int", WH_KEYBOARD_LL := 13
                         , "Ptr", RegisterCallback("LowLevelKeyboardProc", "Fast", 3)
                         , "Ptr", DllCall("GetModuleHandle", "UInt", 0, "Ptr")
                         , "UInt", 0, "Ptr")
}
; https://docs.microsoft.com/en-us/previous-versions/windows/desktop/legacy/ms644985(v=vs.85)
LowLevelKeyboardProc(nCode, wParam, lParam)
{
  Critical
  flags := NumGet(lParam+0, 8, "UInt") & 0x10                         ; physical=0, simulated=non-zero
  if (nCode>=0 and flags=0 and (wParam = 0x0101 or wParam = 0x0105))  ; WM_KEYUP = 0x0101 WM_SYSKEYUP = 0x0105
  {
    ; vk := NumGet(lParam+0, "UInt")                                  ; vk can't distinguish numpad, use sc
      Extended := NumGet(lParam+0, 8, "UInt") & 0x1                   ; extended key (Fn/Numpad)=1, else=0
    , sc := (Extended<<8) | NumGet(lParam+0, 4, "UInt")
    if (!keyboard[today].HasKey("sc" sc))                             ; Init keys not in layout too
    {
      keyboard[today,   "sc" sc] := 0
      keyboard["total", "sc" sc] := 0
    }
      keyboard[today,   "sc" sc] += 1
    , keyboard["total", "sc" sc] += 1
    , keyboard[today,   "keystrokes"] += 1
    , keyboard["total", "keystrokes"] += 1
  }
  ; CallNextHookEx passes to other hooks
  ; Return non-zero to discard message
  return, DllCall("CallNextHookEx", "Ptr", 0, "Int", nCode, "UInt", wParam, "UInt", lParam)
}

getcolors(c1, c2, n)
{
  ; Clamp n range
  n := n>=2 ? n : 2
  ; Generate gradient
  colors := []
  r1 := c1 >> 16, g1 := c1 >> 8 & 0xFF, b1 := c1 & 0xFF
  r2 := c2 >> 16, g2 := c2 >> 8 & 0xFF, b2 := c2 & 0xFF
  ; (n-1) & (A_Index-1) ensure c1 and c2 endpoints
    rd := (r2-r1)/(n-1)
  , gd := (g2-g1)/(n-1)
  , bd := (b2-b1)/(n-1)
  loop, % n
    ; No rounding needed
    ; Format preserves precision better
    colors[A_Index] := Format("{:02x}{:02x}{:02x}"
    , r1+rd * (A_Index-1)
    , g1+gd * (A_Index-1)
    , b1+bd * (A_Index-1))
  return, colors
}

countdown()
{
  ; Seconds until 00:00:05 (+5s buffer for clock drift)
  return, -(EnvSub(tomorrow, A_Now, "Seconds")+5)*1000
}

UpdateDeviceCaps(w:="", h:="")
{
  ; EDID and GetDeviceCaps both give wrong sizes on my monitor
  ; Even AIDA64 gets it wrong
  ; No 100% reliable way to get physical size
  if (w>0 and h>0)                                                          ; Value might be space (empty), check >0
  {
    devicecaps.w  := w                                                      ; Use provided value
    devicecaps.h  := h
  }
  else
    {                                                                         ; Auto-detect physical size
    hdcScreen     := DllCall("GetDC", "UPtr", 0)
    devicecaps.w  := DllCall("GetDeviceCaps", "UPtr", hdcScreen, "Int", 4)  ; mm
    devicecaps.h  := DllCall("GetDeviceCaps", "UPtr", hdcScreen, "Int", 6)  ; mm
  }
  devicecaps.size := (Sqrt(devicecaps.w**2 + devicecaps.h**2)/25.4)         ; inches (diagonal)
}

UpdateLayout(lkw, lkh, lks, lkhs, lkvs, lfs, highlightStart:="D1D5DB", highlightEnd:="3B82F6")
{
  layout.kw  := lkw
  layout.kh  := lkh
  layout.ks  := lks
  layout.khs := lkhs
  layout.kvs := lkvs
  layout.fs  := lfs
  layout.highlightStart := highlightStart
  layout.highlightEnd := highlightEnd
}

IniRead(Filename, Section:="", Key:="", Default:=""){
  IniRead, OutputVar, %Filename%, %Section%, %Key%, %Default%
  ; Return default if key missing or empty
  return, OutputVar="" ? Default : OutputVar
}
IniWrite(Value, Filename, Section, Key:=""){
  IniWrite, %Value%, %Filename%, %Section%, %Key%
}
EnvSub(Var, Value, TimeUnits){
  EnvSub, Var, %Value%, %TimeUnits%
  return, Var
}
EnvAdd(Var, Value, TimeUnits, StartingPos, Length){
  EnvAdd, Var, %Value%, %TimeUnits%
  ; EnvAdd changes digit count, SubStr restores it
  return, SubStr(Var, StartingPos, Length)
}
MouseGetPos(ByRef OutputVarX, ByRef OutputVarY){
	MouseGetPos, OutputVarX, OutputVarY
}
MouseGetClassNN(){
	MouseGetPos,,,,OutputVarControl
  return, OutputVarControl
}

; Stores key size/position data for custom keyboard
LoadControlList(layout:="")
{
  KeyW              := NonNull_Ret(layout.kw,  52, 30)  ; Clamp key width min=30
  KeyH              := NonNull_Ret(layout.kh,  45, 25)  ; Clamp key height min=25
  KeySpacing        := NonNull_Ret(layout.ks,  2,  0)   ; Clamp key spacing
  HorizontalSpacing := NonNull_Ret(layout.khs, 10, 0)   ; Clamp horizontal spacing
  VerticalSpacing   := NonNull_Ret(layout.kvs, 10, 0)   ; Clamp vertical spacing

  m:=[KeySpacing,        "+" KeySpacing                 ; Normal key spacing
    , HorizontalSpacing, "+" HorizontalSpacing          ; Horizontal section spacing
    , VerticalSpacing,   "+" VerticalSpacing            ; Vertical section spacing
    , "",                ""]                            ; ESC-F1 gap (calculated)

  w    :=  KeyW                                       ; w/h without number = normal key size, with number = special row key
  h    :=  KeyH
  w2   :=  w*2+10                                     ; BackSpace
  w3   := (w*13 + w2 - w*12 + m.1*0)/2                ; Tab      \
  w4   := (w*13 + w2 - w*11 + m.1*1)/2                ; CapsLock Enter
  w5   := (w*13 + w2 - w*10 + m.1*2)/2                ; Shift
  w6_1 :=  w3                                         ; Ctrl
  w6_2 :=  w6_1-10                                    ; Win      Alt
  w6_3 := (w*13 + w2 - w6_1*2 - w6_2*4 + m.1*7)       ; Space

  m7   := (w*13 + w2 - w*13 + m.1*4)/3                ; ESC-F1 gap
  m.7  :=  m7
  m.8  :=  "+" m7

  list:=[]
  ; Row 1
  list.push({Hwnd:"sc1",  Text:"Esc", x:"", y:"", w:w, h:h})
  list.push({Hwnd:"sc59", Text:"F1",  x:m.8, y:"", w:w, h:h})
  list.push({Hwnd:"sc60", Text:"F2",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc61", Text:"F3",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc62", Text:"F4",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc63", Text:"F5",  x:m.8, y:"", w:w, h:h})
  list.push({Hwnd:"sc64", Text:"F6",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc65", Text:"F7",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc66", Text:"F8",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc67", Text:"F9",  x:m.8, y:"", w:w, h:h})
  list.push({Hwnd:"sc68", Text:"F10", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc87", Text:"F11", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc88", Text:"F12", x:m.2, y:"", w:w, h:h})
  ; Row 2
  list.push({Hwnd:"sc41", Text:"``",        x:"m", y:m.4, w:w,  h:h})
  list.push({Hwnd:"sc2",  Text:"1",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc3",  Text:"2",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc4",  Text:"3",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc5",  Text:"4",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc6",  Text:"5",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc7",  Text:"6",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc8",  Text:"7",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc9",  Text:"8",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc10", Text:"9",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc11", Text:"0",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc12", Text:"-",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc13", Text:"=",         x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc14", Text:"BackSpace", x:m.2, y:"",  w:w2, h:h})
  ; Row 3
  list.push({Hwnd:"sc15", Text:"Tab", x:"m", y:m.2, w:w3, h:h})
  list.push({Hwnd:"sc16", Text:"q",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc17", Text:"w",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc18", Text:"e",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc19", Text:"r",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc20", Text:"t",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc21", Text:"y",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc22", Text:"u",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc23", Text:"i",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc24", Text:"o",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc25", Text:"p",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc26", Text:"[",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc27", Text:"]",   x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc43", Text:"\",   x:m.2, y:"",  w:w3, h:h})
  ; Row 4
  list.push({Hwnd:"sc58", Text:"CapsLock", x:"m", y:m.2, w:w4, h:h})
  list.push({Hwnd:"sc30", Text:"a",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc31", Text:"s",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc32", Text:"d",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc33", Text:"f",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc34", Text:"g",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc35", Text:"h",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc36", Text:"j",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc37", Text:"k",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc38", Text:"l",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc39", Text:";",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc40", Text:"'",        x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc28", Text:"Enter",    x:m.2, y:"",  w:w4, h:h})
  ; Row 5
  list.push({Hwnd:"sc42", Text:"Shift", x:"m", y:m.2, w:w5, h:h})
  list.push({Hwnd:"sc44", Text:"z",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc45", Text:"x",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc46", Text:"c",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc47", Text:"v",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc48", Text:"b",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc49", Text:"n",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc50", Text:"m",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc51", Text:",",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc52", Text:".",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc53", Text:"/",     x:m.2, y:"",  w:w,  h:h})
  list.push({Hwnd:"sc310", Text:"Shift", x:m.2, y:"",  w:w5, h:h})
  ; Row 6
  list.push({Hwnd:"sc29",  Text:"Ctrl",  x:"m", y:m.2, w:w6_1, h:h})
  list.push({Hwnd:"sc347", Text:"Win",   x:m.2, y:"",  w:w6_2, h:h})
  list.push({Hwnd:"sc56",  Text:"Alt",   x:m.2, y:"",  w:w6_2, h:h})
  list.push({Hwnd:"sc57",  Text:"Space", x:m.2, y:"",  w:w6_3, h:h})
  list.push({Hwnd:"sc312", Text:"Alt",   x:m.2, y:"",  w:w6_2, h:h})
  list.push({Hwnd:"sc348", Text:"Win",   x:m.2, y:"",  w:w6_2, h:h})
  list.push({Hwnd:"sc285", Text:"Ctrl",  x:m.2, y:"",  w:w6_1, h:h})

  ; Position nav keys, align height with row 2
  temp1:="m+" h+m.3 " Section"
  list.push({Hwnd:"sc338", Text:"Insert", x:m.6, y:temp1, w:w, h:h})
  list.push({Hwnd:"sc327", Text:"Home",   x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc329", Text:"PageUp", x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc339", Text:"Delete", x:"s", y:m.2,   w:w, h:h})
  list.push({Hwnd:"sc335", Text:"End",    x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc337", Text:"PageDn", x:m.2, y:"",    w:w, h:h})

  ; Position arrow keys, align height with row 5
  temp1:="s+" w+m.1, temp2:="+" h+2*m.1
  list.push({Hwnd:"sc328", Text:"▲", x:temp1, y:temp2, w:w, h:h})
  list.push({Hwnd:"sc331", Text:"◀", x:"s",   y:m.2,   w:w, h:h})
  list.push({Hwnd:"sc336", Text:"▼", x:m.2,   y:"",    w:w, h:h})
  list.push({Hwnd:"sc333", Text:"▶", x:m.2,   y:"",    w:w, h:h})

  ; Position numpad, align height with row 2
  temp1:="m+" h+m.3 " Section"
  list.push({Hwnd:"sc325", Text:"NumLock", x:m.6, y:temp1, w:w, h:h})
  list.push({Hwnd:"sc309", Text:"/",       x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc55",  Text:"*",       x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc74",  Text:"-",       x:m.2, y:"",    w:w, h:h})
  ; Numpad row 2
  list.push({Hwnd:"sc71", Text:"7",        x:"s", y:m.2,   w:w, h:h})
  list.push({Hwnd:"sc72", Text:"8",        x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc73", Text:"9",        x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc78", Text:"+",        x:m.2, y:"",    w:w, h:h*2+m.1})
  ; Numpad row 3
  temp1:="s+" (h+m.1)*2
  list.push({Hwnd:"sc75", Text:"4",        x:"s", y:temp1, w:w, h:h})
  list.push({Hwnd:"sc76", Text:"5",        x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc77", Text:"6",        x:m.2, y:"",    w:w, h:h})
  ; Numpad row 4
  temp1:="s+" (h+m.1)*3
  list.push({Hwnd:"sc79",  Text:"1",       x:"s", y:temp1, w:w, h:h})
  list.push({Hwnd:"sc80",  Text:"2",       x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc81",  Text:"3",       x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc284", Text:"Enter",   x:m.2, y:"",    w:w, h:h*2+m.1})
  ; Numpad row 5
  temp1:="s+" (h+m.1)*4
  list.push({Hwnd:"sc82", Text:"0",        x:"s", y:temp1, w:w*2+m.1, h:h})
  list.push({Hwnd:"sc83", Text:".",        x:m.2, y:"",    w:w,       h:h})

  ; Message area position
    temp1:="m+" w*13+Round(m.7*3)+m.1*9+m.5
  , temp2:=w*7+m.1*5+m.5
  , temp3:=h
  list.push({Hwnd:"Message", Text:"",      x:temp1, y:"m", w:temp2, h:temp3})

  ; Keys covered by expanded message
  list.Covered := ["sc338", "sc327", "sc329", "sc339", "sc335", "sc337"  ; Nav keys
                 , "sc328", "sc331", "sc336", "sc333"                    ; Arrow keys
                 , "sc325", "sc309", "sc55",  "sc74"                     ; Numpad
                 , "sc71",  "sc72",  "sc73",  "sc78"
                 , "sc75",  "sc76",  "sc77"
                 , "sc79",  "sc80",  "sc81",  "sc284"
                 , "sc82",  "sc83"]

  ; Color without 0x prefix. BG affects keys in info area when data is low.
  list.Opt := {Font:"Microsoft YaHei", FontSize:NonNull_Ret(layout.fs, 9, 6), BackgroundColor:"F5F6F8", TextColor:"1E293B"}

  return, list
}

MultiLanguage:
  if (A_Language="0804")
  {
    L_menu_统计:="统计"
    L_menu_设置:="设置"
    L_menu_开机启动:="开机启动"
    L_menu_布局定制:="布局定制"
    L_menu_退出:="退出"

    L_gui1_当前显示数据:="当前显示数据"
    L_gui1_LV标题:="项目|今日|总计"
    L_gui1_鼠标移动:="鼠标移动"
    L_gui1_键盘敲击:="键盘敲击"
    L_gui1_左键点击:="左键点击"
    L_gui1_右键点击:="右键点击"
    L_gui1_中键点击:="中键点击"
    L_gui1_滚轮滚动:="滚轮滚动"
    L_gui1_滚轮横滚:="滚轮横滚"
    L_gui1_侧键点击:="侧键点击"
    L_gui1_屏幕尺寸:="屏幕尺寸"
    L_gui1_米:="米"
    L_gui1_次:="次"
    L_gui1_寸:="寸"
    L_gui1_msgbox:="今日按键次数较少，故暂未生成按键热点图。"

    L_gui2_设置:="设置"
    L_gui2_历史数据:="历史数据"
    L_gui2_sub1:="设置历史数据保留时长。"
    L_gui2_存储:="存储"
    L_gui2_天:="天"
    L_gui2_屏幕尺寸:="屏幕尺寸"
    L_gui2_sub2:="设置显示器的真实尺寸。"
    L_gui2_屏幕宽:="屏幕宽"
    L_gui2_屏幕高:="屏幕高"
    L_gui2_毫米:="毫米"
    L_gui2_键盘布局:="键盘布局"
    L_gui2_sub3:="设置键盘热力图的尺寸。"
    L_gui2_键宽:="键宽"
    L_gui2_键高:="键高"
    L_gui2_键间距:="键间距"
    L_gui2_区域水平间距:="区域水平间距"
    L_gui2_区域垂直间距:="区域垂直间距"
    L_gui2_像素:="像素"
    L_gui2_取消:="取消"
    L_gui2_保存:="保存"
    L_gui2_键盘外观:="键盘外观"
    L_gui2_字体大小:="字体大小"
    L_gui2_号:="号"
    L_gui2_已恢复:="已恢复默认设置！"
  }
  else
  {
    L_menu_统计:="Statistics"
    L_menu_设置:="Settings"
    L_menu_开机启动:="Run at Startup"
    L_menu_布局定制:="Layout Customization"
    L_menu_退出:="Exit"

    L_gui1_当前显示数据:="Current Data"
    L_gui1_LV标题:="Item|Today|Total"
    L_gui1_鼠标移动:="Mouse Movement"
    L_gui1_键盘敲击:="Keyboard Clicks"
    L_gui1_左键点击:="Left Clicks"
    L_gui1_右键点击:="Right Clicks"
    L_gui1_中键点击:="Middle Clicks"
    L_gui1_滚轮滚动:="Wheel Scrolls"
    L_gui1_滚轮横滚:="Wheel Tilt"
    L_gui1_侧键点击:="Side Clicks"
    L_gui1_屏幕尺寸:="Screen Size"
    L_gui1_米:="m"
    L_gui1_次:="times"
    L_gui1_寸:="in"
    L_gui1_msgbox:="Insufficient keystrokes today to generate a heatmap."

    L_gui2_设置:="Settings"
    L_gui2_历史数据:="History Data"
    L_gui2_sub1:="Set how long to keep historical data."
    L_gui2_存储:="Storage"
    L_gui2_天:="days"
    L_gui2_屏幕尺寸:="Screen Size"
    L_gui2_sub2:="Set the actual size of your monitor."
    L_gui2_屏幕宽:="Screen Width"
    L_gui2_屏幕高:="Screen Height"
    L_gui2_毫米:="mm"
    L_gui2_键盘布局:="Keyboard Layout"
    L_gui2_sub3:="Set the size of the keyboard heatmap."
    L_gui2_键宽:="Key Width"
    L_gui2_键高:="Key Height"
    L_gui2_键间距:="Key Spacing"
    L_gui2_区域水平间距:="Horizontal Spacing"
    L_gui2_区域垂直间距:="Vertical Spacing"
    L_gui2_像素:="pixels"
    L_gui2_取消:="Cancel"
    L_gui2_保存:="Save"
    L_gui2_键盘外观:="Keyboard Appearance"
    L_gui2_字体大小:="Font Size"
    L_gui2_号:="pt"
    L_gui2_已恢复:="Default settings restored!"
  }
return

; Control key heatmap colors via WM_CTLCOLORSTATIC
WM_CTLCOLORSTATIC(wParam, lParam, msg, hwnd) {
    global ControlColors, ControlBrushes
    controlHwnd := lParam
    if (ControlColors.HasKey(controlHwnd)) {
        DllCall("SetTextColor", "Ptr", wParam, "UInt", ControlColors[controlHwnd].text)
        DllCall("SetBkMode", "Ptr", wParam, "Int", 1)
        if (!ControlBrushes.HasKey(controlHwnd))
            ControlBrushes[controlHwnd] := DllCall("CreateSolidBrush", "UInt", ControlColors[controlHwnd].bg, "Ptr")
        return ControlBrushes[controlHwnd]
    }
}

MakeRoundRect(hwnd, w, h, r) {
    hrgn := DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", w, "Int", h, "Int", r, "Int", r)
    DllCall("SetWindowRgn", "Ptr", hwnd, "Ptr", hrgn, "Int", 1)
}

ChangeControlColor(key, bgColor, textColor) {
    global ControlColors, ControlBrushes
    GuiControlGet, hCtrl, Hwnd, % "key" key
    if (hCtrl = "")
        return
    if (ControlBrushes.HasKey(hCtrl)) {
        DllCall("DeleteObject", "Ptr", ControlBrushes[hCtrl])
        ControlBrushes.Delete(hCtrl)
    }
    ControlColors[hCtrl] := {bg: "0x" bgColor, text: "0x" textColor}
    ControlBrushes[hCtrl] := DllCall("CreateSolidBrush", "UInt", "0x" bgColor, "Ptr")
    WinSet, Redraw,, ahk_id %hCtrl%
}

FreeControlColors() {
    global ControlBrushes
    for k, v in ControlBrushes
        DllCall("DeleteObject", "Ptr", v)
    ControlBrushes := {}
}

; Utility functions that were missing from the script
NonNull(ByRef var, default) {
    if (!IsSet(var) || var = "")
        var := default
}

NonNull_Ret(var, default, min) {
    if (!IsSet(var) || var = "")
        var := default
    if (var < min)
        var := min
    return var
}

btt(text="", x="", y="", delay=0, style="") {
    ; Simple tooltip function implementation
    if (text = "") {
        ToolTip
        return
    }
    ToolTip, %text%, %x%, %y%, 1
}