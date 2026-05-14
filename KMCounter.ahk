/*
Known issue: display dimensions don't auto-update on monitor change
*/
/*
Original project by telppa
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
      , themes:={Blue:{bg:"1E1E1E", text:"D4D4D4", accent:"3B82F6", key:"3A3A3C", hs:"3A3A3C", he:"3B82F6"}
                 ,Red:{bg:"1E1E1E", text:"D4D4D4", accent:"EF4444", key:"3A3A3C", hs:"3A3A3C", he:"EF4444"}
                 ,Orange:{bg:"1E1E1E", text:"D4D4D4", accent:"F97316", key:"3A3A3C", hs:"3A3A3C", he:"F97316"}
                 ,Purple:{bg:"1E1E1E", text:"D4D4D4", accent:"A855F7", key:"3A3A3C", hs:"3A3A3C", he:"A855F7"}
                 ,Green:{bg:"1E1E1E", text:"D4D4D4", accent:"22C55E", key:"3A3A3C", hs:"3A3A3C", he:"22C55E"}}
      , currentTheme:="Blue"

gosub, MultiLanguage
gosub, Welcome
LoadData(today)
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
  kw:=layout.kw, kh:=layout.kh, ks:=layout.ks, khs:=layout.khs, kvs:=layout.kvs
  w2:=kw*2+10
  w3:=(kw*13+w2-kw*11+ks)//2
  w4:=(kw*13+w2-kw*10+ks)//2
  w5:=(kw*13+w2-kw*10+ks*2)//2
  w6_1:=w3, w6_2:=w6_1-10, w6_3:=kw*13+w2-w6_1*2-w6_2*4+ks*7
  m7:=(w2+ks*4)//3, kfs:=kw<60?9:kw<80?11:13
  mw:=13*kw+12*ks+w2+khs*2, sw:=kw*4+ks*3+khs*2+20
  tw:=mw+sw+ks*2+48, bw:=tw-16
  t:=themes[currentTheme]
  Gui, -DPIScale +HwndhWin
  Gui, Color, 1E1E1E
  ; Native settings bar
  Gui, Font, s10 Bold cFFFFFF, Microsoft YaHei
  Gui, Add, Text, x8 y6 wauto h20 Section, %APPName%
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, xs+60 ys+2 wauto h14, v%ver%
  Gui, Font, % "s9 c" t.accent, Microsoft YaHei
  Gui, Add, Text, x+10 ys wauto h20 vDateDisplay, % today
  Gui, Font, % "s11 c" t.accent, Microsoft YaHei
  Gui, Add, Text, x+8 ys w22 h22 Center gShowSettings, ⚙
  yb:=30
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, % "x8 y" yb " w40 h18", Store:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, % "x48 y" yb-2 " w40 h18 Number Limit vdsd1", % DataStorageDays
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, % "x90 y" yb " w12 h18", d
  Gui, Add, Text, % "x108 y" yb " w30 h18", Theme:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Text, % "x138 y" yb " w45 h18 vThemeDisplay gThemeCycle", % currentTheme
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, % "x188 y" yb " w16 h18", KW:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, % "x204 y" yb-2 " w32 h18 Number Limit vlkw1", % layout.kw
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, % "x238 y" yb " w16 h18", KH:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, % "x254 y" yb-2 " w32 h18 Number Limit vlkh1", % layout.kh
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, % "x290 y" yb " w14 h18", FS:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, % "x304 y" yb-2 " w28 h18 Number Limit vlfs1", % layout.fs
  Gui, Font, s7 cFFFFFF, Microsoft YaHei
  Gui, Add, Button, % "x336 y" yb-2 " w28 h18 gApplySettings", ✓
  ; Browser fills the area below the settings bar
  bh:=kh*6+kvs*5+340
  bw:=tw-16
  Gui, Add, ActiveX, vWB x8 y52 w%bw% h%bh%, Shell.Explorer
  html:=BuildHtml(kw,kh,ks,khs,kvs,w2,w3,w4,w5,w6_1,w6_2,w6_3,m7,kfs,t,mw,sw)
  WB.Navigate("about:blank")
  while WB.ReadyState<4
    Sleep 10
  WB.Document.Write(html)
  WB.Document.Close()
  ComObjConnect(WB, "BrowserEvents")
  Sleep 100
  UpdateBrowserData()
  Gui, Show, w%tw% h%bh+60%
return

ApplySettings:
  Gui, Submit, NoHide
  DataStorageDays := NonNull_Ret(dsd1, 9999, 0)
  UpdateLayout(lkw1, lkh1, layout.ks, layout.khs, layout.kvs, lfs1, layout.highlightStart, layout.highlightEnd)
  IniWrite(DataStorageDays, "KMCounter.ini", "history", "storage")
  IniWrite(layout.kw, "KMCounter.ini", "layout", "kw")
  IniWrite(layout.kh, "KMCounter.ini", "layout", "kh")
  IniWrite(layout.fs, "KMCounter.ini", "layout", "fs")
  gosub CreateGui1
return
return

ThemeCycle:
  themeList := ["Blue", "Red", "Orange", "Purple", "Green"]
  for k, v in themeList
    if (v = currentTheme)
      currentTheme := themeList[k = themeList.MaxIndex() ? 1 : k + 1]
  IniWrite, % currentTheme, KMCounter.ini, theme, name
  gosub CreateGui1
  gosub ShowHeatMap
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
  Gui, 2:Hide
  history:=""
  btt()
return

CreateGui2:
{
  _sy := 56
  Gui, 2:Color, F1F3F6, F1F3F6

  Gui, 2:Font, s18 Bold c1E293B, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy-42 " w480 h34", %L_gui2_设置%

  ; ========== History Data ==========
  Gui, 2:Font, s11 c3B82F6 Bold, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w200 h24", %L_gui2_历史数据%
  _sy += 26
  Gui, 2:Font, s9 c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w460 h15", %L_gui2_sub1%
  _sy += 22
  Gui, 2:Font, s10 c475569, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w55 h24", %L_gui2_存储%:
  Gui, 2:Add, Edit, % "x84 y" _sy-2 " w70 h28 Number Limit -Multi vdsd", % DataStorageDays
  Gui, 2:Add, Text, % "x161 y" _sy+3 " w40 h20", %L_gui2_天%
  _sy += 42

  ; ========== Screen Size ==========
  Gui, 2:Font, s11 c3B82F6 Bold, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w200 h24", %L_gui2_屏幕尺寸%
  _sy += 26
  Gui, 2:Font, s9 c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w460 h15", %L_gui2_sub2%
  _sy += 22
  Gui, 2:Font, s10 c475569, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w60 h24", %L_gui2_屏幕宽%:
  Gui, 2:Add, Edit, % "x89 y" _sy-2 " w70 h28 Number Limit -Multi vdw", % devicecaps.w
  Gui, 2:Add, Text, % "x166 y" _sy+3 " w25 h20", mm
  Gui, 2:Add, Text, % "x215 y" _sy " w60 h24", %L_gui2_屏幕高%:
  Gui, 2:Add, Edit, % "x280 y" _sy-2 " w70 h28 Number Limit -Multi vdh", % devicecaps.h
  Gui, 2:Add, Text, % "x357 y" _sy+3 " w25 h20", mm
  _sy += 42

  ; ========== Keyboard Layout ==========
  Gui, 2:Font, s11 c3B82F6 Bold, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w200 h24", %L_gui2_键盘布局%
  _sy += 26
  Gui, 2:Font, s9 c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w460 h15", %L_gui2_sub3%
  _sy += 22

  Gui, 2:Font, s10 c475569, Microsoft YaHei

  Gui, 2:Add, Text, % "x24 y" _sy " w65 h24", %L_gui2_键宽%:
  Gui, 2:Add, Edit, % "x94 y" _sy-2 " w65 h28 Number Limit -Multi vlkw", % layout.kw
  Gui, 2:Add, Text, % "x166 y" _sy+3 " w25 h20", px
  Gui, 2:Add, Text, % "x210 y" _sy " w65 h24", %L_gui2_键高%:
  Gui, 2:Add, Edit, % "x280 y" _sy-2 " w65 h28 Number Limit -Multi vlkh", % layout.kh
  Gui, 2:Add, Text, % "x352 y" _sy+3 " w25 h20", px
  _sy += 30

  Gui, 2:Add, Text, % "x24 y" _sy " w65 h24", %L_gui2_键间距%:
  Gui, 2:Add, Edit, % "x94 y" _sy-2 " w65 h28 Number Limit -Multi vlks", % layout.ks
  Gui, 2:Add, Text, % "x166 y" _sy+3 " w25 h20", px
  _sy += 30

  Gui, 2:Add, Text, % "x24 y" _sy " w110 h24", %L_gui2_区域水平间距%:
  Gui, 2:Add, Edit, % "x139 y" _sy-2 " w65 h28 Number Limit -Multi vlkhs", % layout.khs
  Gui, 2:Add, Text, % "x211 y" _sy+3 " w25 h20", px
  Gui, 2:Add, Text, % "x255 y" _sy " w110 h24", %L_gui2_区域垂直间距%:
  Gui, 2:Add, Edit, % "x370 y" _sy-2 " w65 h28 Number Limit -Multi vlkvs", % layout.kvs
  Gui, 2:Add, Text, % "x442 y" _sy+3 " w25 h20", px
  _sy += 42

  ; ========== Keyboard Appearance ==========
  Gui, 2:Font, s11 c3B82F6 Bold, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w200 h24", %L_gui2_键盘外观%
  _sy += 26

  Gui, 2:Font, s10 c475569, Microsoft YaHei
  Gui, 2:Add, Text, % "x24 y" _sy " w65 h24", %L_gui2_字体大小%:
  Gui, 2:Add, Edit, % "x94 y" _sy-2 " w65 h28 Number Limit -Multi vlfs", % layout.fs
  Gui, 2:Add, Text, % "x166 y" _sy+3 " w25 h20", pt
  _sy += 30

  Gui, 2:Add, Text, % "x24 y" _sy " w65 h24", %L_gui2_起始颜色%:
  Gui, 2:Add, Edit, % "x94 y" _sy-2 " w100 h28 -Multi vhighlightStart", % layout.highlightStart
  Gui, 2:Add, Text, % "x210 y" _sy " w65 h24", %L_gui2_结束颜色%:
  Gui, 2:Add, Edit, % "x280 y" _sy-2 " w100 h28 -Multi vhighlightEnd", % layout.highlightEnd
  _sy += 44

  ; ========== Buttons ==========
  Gui, 2:Font, s10, Microsoft YaHei
  Gui, 2:Add, Button, % "x24 y" _sy " w100 h30 gCancelSetting", %L_gui2_取消%
  Gui, 2:Add, Button, % "x134 y" _sy " w100 h30 gSaveSetting", %L_gui2_保存%
  Gui, 2:Add, Button, % "x244 y" _sy " w130 h30 gRestoreDefaultSetting", %L_gui2_恢复默认%

  Gui, 2:Show, % "w520 h660 Hide", %L_gui2_设置%
}
return

CancelSetting:
2GuiEscape:
2GuiClose:
  Gui, 2:Hide
return

SaveSetting:
  Gui, 2:Submit
  ; Clamp storage days min=0, default=9999
  DataStorageDays := NonNull_Ret(dsd, 9999, 0)
  UpdateDeviceCaps(dw, dh)
  UpdateLayout(lkw, lkh, lks, lkhs, lkvs, lfs, highlightStart, highlightEnd)
  ; Reload to apply settings
  gosub, Reload
return

RestoreDefaultSetting:
  ; Reset all to defaults
  ; Restore default storage days
  DataStorageDays := 9999
  GuiControl, 2:, dsd, % DataStorageDays
  
  ; Restore default screen size (empty=auto)
  GuiControl, 2:, dw, 
  GuiControl, 2:, dh, 
  UpdateDeviceCaps("", "")
  
  ; Restore default keyboard layout
  t := themes[currentTheme]
  defaultKw := Min(Max(Round((A_ScreenWidth-500)/15), 55), 100)
  defaultKh := Round(defaultKw*0.92)
  defaultKs := 2
  defaultKhs := 4
  defaultKvs := 4
  defaultFs := Round(defaultKw/6)
  defaultHighlightStart := t.hs
  defaultHighlightEnd := t.he
  
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
  IniWrite, 9999, KMCounter.ini, history, storage
  IniDelete, KMCounter.ini, devicecaps, w
  IniDelete, KMCounter.ini, devicecaps, h
  IniWrite, % defaultKw, KMCounter.ini, layout, kw
  IniWrite, % defaultKh, KMCounter.ini, layout, kh
  IniWrite, % defaultKs, KMCounter.ini, layout, ks
  IniWrite, % defaultKhs, KMCounter.ini, layout, khs
  IniWrite, % defaultKvs, KMCounter.ini, layout, kvs
  IniWrite, % defaultFs, KMCounter.ini, layout, fs
  IniWrite, % defaultHighlightStart, KMCounter.ini, layout, highlightStart
  IniWrite, % defaultHighlightEnd, KMCounter.ini, layout, highlightEnd
  
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
  Menu, Tray, NoStandard
  Menu, Tray, Tip, %APPName% v%ver%

  ; Theme submenu
  Menu, ThemeMenu, Add, Blue, ThemeHandler
  Menu, ThemeMenu, Add, Red, ThemeHandler
  Menu, ThemeMenu, Add, Orange, ThemeHandler
  Menu, ThemeMenu, Add, Purple, ThemeHandler
  Menu, ThemeMenu, Add, Green, ThemeHandler
  Menu, ThemeMenu, Check, % currentTheme

  Menu, Tray, Add, %L_menu_统计%,     MenuHandler
  Menu, Tray, Add, %L_menu_设置%,     MenuHandler
  Menu, Tray, Add
  Menu, Tray, Add, Theme, :ThemeMenu
  Menu, Tray, Add
  Menu, Tray, Add, %L_menu_开机启动%, MenuHandler
  Menu, Tray, Add
  Menu, Tray, Add, %L_menu_退出%,     MenuHandler
  Menu, Tray, Default, %L_menu_统计%

  if (!A_IsCompiled)
    Menu, Tray, Icon, resouces\%APPName%.ico

  IfExist, %A_Startup%\%APPName%.Lnk
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

  if (A_ThisMenuItem = L_menu_退出)
    ExitApp
return

ThemeHandler:
  currentTheme := A_ThisMenuItem
  IniWrite, % currentTheme, KMCounter.ini, theme, name
  gosub, Reload
return

ShowSettings:
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
return

ShowHeatMap:
{
  GuiControl, , DateDisplay, % date = tomorrow ? "Total" : date
  Gui, Show
  UpdateBrowserData()
}
return

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
  DataStorageDays := IniRead("KMCounter.ini", "history", "storage", 9999)
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
  UpdateDeviceCaps(devicecaps.w, devicecaps.h)
  ; Load theme
  currentTheme := IniRead("KMCounter.ini", "theme", "name", "Blue")
  t := themes[currentTheme]
  ; Load layout - key size fills screen width like a real laptop keyboard
  layout.kw    := IniRead("KMCounter.ini", "layout", "kw",  Min(Max(Round((A_ScreenWidth-500)/15), 55), 100))
  layout.kh    := IniRead("KMCounter.ini", "layout", "kh",  Round(layout.kw*0.92))
  layout.ks    := IniRead("KMCounter.ini", "layout", "ks",  2)
  layout.khs   := IniRead("KMCounter.ini", "layout", "khs", 4)
  layout.kvs   := IniRead("KMCounter.ini", "layout", "kvs", 4)
  layout.fs    := IniRead("KMCounter.ini", "layout", "fs",  Round(layout.kw/6))
  layout.highlightStart := IniRead("KMCounter.ini", "layout", "highlightStart", t.hs)
  layout.highlightEnd := IniRead("KMCounter.ini", "layout", "highlightEnd", t.he)
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
  ; Save theme
  IniWrite(currentTheme, "KMCounter.ini", "theme", "name")
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
  list.push({Hwnd:"sc1",  Text:"Esc", x:"m", y:"", w:w, h:h})
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

  ; Position nav keys, bottom-aligned with main keyboard
  temp1:="m+" (h*2 + m.1*2 + m.3) " Section"
  list.push({Hwnd:"sc338", Text:"Insert", x:m.6, y:temp1, w:w, h:h})
  list.push({Hwnd:"sc327", Text:"Home",   x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc329", Text:"PageUp", x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc339", Text:"Delete", x:"s", y:m.2,   w:w, h:h})
  list.push({Hwnd:"sc335", Text:"End",    x:m.2, y:"",    w:w, h:h})
  list.push({Hwnd:"sc337", Text:"PageDn", x:m.2, y:"",    w:w, h:h})

  ; Position arrow keys, bottom-aligned with main keyboard
  temp1:="s+" w+m.1, temp2:="+" (m.1*3 + m.3*3)
  list.push({Hwnd:"sc328", Text:"▲", x:temp1, y:temp2, w:w, h:h})
  list.push({Hwnd:"sc331", Text:"◀", x:"s",   y:m.2,   w:w, h:h})
  list.push({Hwnd:"sc336", Text:"▼", x:m.2,   y:"",    w:w, h:h})
  list.push({Hwnd:"sc333", Text:"▶", x:m.2,   y:"",    w:w, h:h})

  ; Position numpad, bottom-aligned with main keyboard
  temp1:="m+" (h*2 + m.1*2 + m.3) " Section"
  list.push({Hwnd:"sc325", Text:"Num`nLock", x:m.6, y:temp1, w:w, h:h})
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
  ; Numpad row 5
  temp1:="s+" (h+m.1)*4
  list.push({Hwnd:"sc82", Text:"0",        x:"s", y:temp1, w:w*2+m.1, h:h})
  list.push({Hwnd:"sc83", Text:".",        x:m.2, y:"",    w:w,       h:h})

  ; Stats area below keyboard, full width
    temp1:="m"
  , temp2:=13*w + m.1*12 + w2 + m.3*2
  , temp3:=300
  list.push({Hwnd:"Message", Text:"",      x:temp1, y:"m+" . (h*8 + m.1*7 + m.3*3), w:temp2, h:temp3})

  ; Color without 0x prefix. BG affects keys in info area when data is low.
  t := themes[currentTheme]
  list.Opt := {Font:"Microsoft YaHei", FontSize:NonNull_Ret(layout.fs, 9, 6), BackgroundColor:t.bg, TextColor:t.text}

  return, list
}

MultiLanguage:
  if (false)  ; Force English; Chinese strings kept for future use
  {
    L_menu_统计:="统计"
    L_menu_设置:="设置"
    L_menu_开机启动:="开机启动"
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
    if (text = "") {
        ToolTip
        return
    }
    ToolTip, %text%, %x%, %y%, 1
}

JSEncode(obj) {
    if (IsObject(obj)) {
        isArray := true
        for k, v in obj
            if (k != A_Index) {
                isArray := false
                break
            }
        if (isArray) {
            s := "["
            for k, v in obj
                s .= JSEncode(v) ","
            return SubStr(s, 1, StrLen(s)-1) "]"
        }
        s := "{"
        for k, v in obj
            s .= "'" k "':" JSEncode(v) ","
        return SubStr(s, 1, StrLen(s)-1) "}"
    }
    if obj is number
        return obj
    s := StrReplace(obj, "\", "\\")
    s := StrReplace(s, "'", "\'")
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "\r")
    return "'" s "'"
}

UpdateBrowserData() {
    global WB, date, mouse, keyboard, layout, devicecaps, themes, currentTheme
    global L_gui1_鼠标移动, L_gui1_键盘敲击, L_gui1_左键点击, L_gui1_右键点击, L_gui1_中键点击
    global L_gui1_滚轮滚动, L_gui1_滚轮横滚, L_gui1_侧键点击, L_gui1_屏幕尺寸, L_gui1_米, L_gui1_次, L_gui1_寸
    global tomorrow, APPName, ver
    if !IsObject(WB)
        return
    data := {}
    data.date := date = tomorrow ? "Total" : date
    data.hs := layout.highlightStart
    data.he := layout.highlightEnd
    data.ks := {}
    if keyboard.HasKey(date)
        for k, v in keyboard[date]
            data.ks[k] := v
    data.tk := keyboard[date].keystrokes
    data.st := []
    data.st.Push({n:L_gui1_鼠标移动, t:Format("{:.2f} {2}", mouse[date].move, L_gui1_米), t2:Format("{:.2f} {2}", mouse.total.move, L_gui1_米)})
    data.st.Push({n:L_gui1_键盘敲击, t:keyboard[date].keystrokes " " L_gui1_次, t2:keyboard.total.keystrokes " " L_gui1_次})
    data.st.Push({n:L_gui1_左键点击, t:mouse[date].lbcount " " L_gui1_次, t2:mouse.total.lbcount " " L_gui1_次})
    data.st.Push({n:L_gui1_右键点击, t:mouse[date].rbcount " " L_gui1_次, t2:mouse.total.rbcount " " L_gui1_次})
    data.st.Push({n:L_gui1_中键点击, t:mouse[date].mbcount " " L_gui1_次, t2:mouse.total.mbcount " " L_gui1_次})
    data.st.Push({n:L_gui1_滚轮滚动, t:mouse[date].wheel " " L_gui1_次, t2:mouse.total.wheel " " L_gui1_次})
    data.st.Push({n:L_gui1_滚轮横滚, t:mouse[date].hwheel " " L_gui1_次, t2:mouse.total.hwheel " " L_gui1_次})
    data.st.Push({n:L_gui1_侧键点击, t:mouse[date].xbcount " " L_gui1_次, t2:mouse.total.xbcount " " L_gui1_次})
    data.st.Push({n:L_gui1_屏幕尺寸, t:Format("{:.1f} {2}", devicecaps.size, L_gui1_寸), t2:""})
    try WB.document.parentWindow.updateData(JSEncode(data))
}

BrowserEvents_TitleChange(ByRef Text) {
    global history, date, today, tomorrow, firstday, DataStorageDays
    if (Text = "settings")
        gosub ShowSettings
    else if (Text = "theme")
        gosub ThemeCycle
    else if (SubStr(Text, 1, 2) = "n:") {
        dir := SubStr(Text, 3)
        NonNull(history, today)
        loop 2 {
            if (dir = "-1")
                history := EnvAdd(history, -1, "Days", 1, 8)
            else
                history := EnvAdd(history, 1, "Days", 1, 8)
            if (history > tomorrow) history := firstday
            if (history < firstday) history := tomorrow
            if (history = tomorrow) { date := "Total"; gosub ShowHeatMap; break }
            if (LoadData(history) and date!=history) { date := history; gosub ShowHeatMap; break }
        }
    }
}

ThemeCycle:
  themeList := ["Blue", "Red", "Orange", "Purple", "Green"]
  for k, v in themeList
    if (v = currentTheme)
        currentTheme := themeList[k = themeList.MaxIndex() ? 1 : k + 1]
  IniWrite, % currentTheme, KMCounter.ini, theme, name
  gosub CreateGui1
return

BuildHtml(kw,kh,ks,khs,kvs,w2,w3,w4,w5,w6_1,w6_2,w6_3,m7,kfs,t,mw,sw) {
    tw := mw + sw + ks*2 + 32
    h := "<!DOCTYPE html><html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'>"
    h := h . "<style>*{margin:0;padding:0;box-sizing:border-box}body{background:#1E1E1E;font-family:Microsoft YaHei,sans-serif;color:#D4D4D4;overflow:hidden;user-select:none;padding:4px 8px 0}"
    h := h . ".cols{display:flex;gap:" . (khs+2) . "px}.row{display:flex;gap:" . ks . "px;margin-bottom:" . kvs . "px}"
    h := h . ".k{height:" . kh . "px;background:#3A3A3C;border-radius:6px;display:flex;align-items:center;justify-content:center;font-size:" . kfs . "px;color:#D4D4D4;box-shadow:0 1px 3px rgba(0,0,0,0.3);transition:background .15s,transform .12s;cursor:default;flex-shrink:0;position:relative}"
    h := h . ".k:hover{transform:translateY(-1px);box-shadow:0 3px 8px rgba(0,0,0,0.4);z-index:1}"
    h := h . ".k .tt{display:none;position:absolute;bottom:calc(100% + 3px);left:50%;transform:translateX(-50%);background:#2A2A2C;color:#D4D4D4;padding:2px 6px;border-radius:3px;font-size:10px;white-space:nowrap;pointer-events:none;z-index:10}"
    h := h . ".k:hover .tt{display:block}"
    h := h . ".g{flex-shrink:0}.side{display:flex;flex-direction:column;gap:" . (kvs-1) . "px;flex-shrink:0}"
    h := h . ".nr{display:flex;gap:" . ks . "px;margin-bottom:" . ks . "px}"
    h := h . ".np{display:grid;grid-template-columns:repeat(4," . kw . "px);gap:" . ks . "px}"
    h := h . ".np .k{width:auto}.np .kt{grid-row:span 2;height:auto}.np .kw{grid-column:span 2}"
    h := h . ".st{margin-top:" . (kvs+2) . "px;background:#252528;border-radius:6px;overflow:hidden}"
    h := h . ".st table{width:100%;border-collapse:collapse;font-size:11px}"
    h := h . ".st th{background:#2A2A2D;color:#94A3B8;padding:3px 8px;text-align:left;font-weight:600;font-size:10px}"
    h := h . ".st td{padding:2px 8px;border-top:1px solid #2E2E30;font-size:11px}"
    h := h . ".st tr:first-child td{border-top:none}.st tr:nth-child(even) td{background:rgba(255,255,255,0.015)}"
    h := h . ".st .rv{text-align:right;color:#A0A0A4}</style></head><body><div class='cols'>"
    h := h . "<div class='main'>"
    h := h . "<div class='row'>" . "<div class='k' data-s='sc1' style='width:" . kw . "px'>Esc</div><div class='g' style='width:" . m7 . "px'></div><div class='k' data-s='sc59' style='width:" . kw . "px'>F1</div><div class='k' data-s='sc60' style='width:" . kw . "px'>F2</div><div class='k' data-s='sc61' style='width:" . kw . "px'>F3</div><div class='k' data-s='sc62' style='width:" . kw . "px'>F4</div><div class='g' style='width:" . m7 . "px'></div><div class='k' data-s='sc63' style='width:" . kw . "px'>F5</div><div class='k' data-s='sc64' style='width:" . kw . "px'>F6</div><div class='k' data-s='sc65' style='width:" . kw . "px'>F7</div><div class='k' data-s='sc66' style='width:" . kw . "px'>F8</div><div class='g' style='width:" . m7 . "px'></div><div class='k' data-s='sc67' style='width:" . kw . "px'>F9</div><div class='k' data-s='sc68' style='width:" . kw . "px'>F10</div><div class='k' data-s='sc87' style='width:" . kw . "px'>F11</div><div class='k' data-s='sc88' style='width:" . kw . "px'>F12</div></div>"
    h := h . "<div class='row'>" . "<div class='k' data-s='sc41' style='width:" . kw . "px'>&#96;</div><div class='k' data-s='sc2' style='width:" . kw . "px'>1</div><div class='k' data-s='sc3' style='width:" . kw . "px'>2</div><div class='k' data-s='sc4' style='width:" . kw . "px'>3</div><div class='k' data-s='sc5' style='width:" . kw . "px'>4</div><div class='k' data-s='sc6' style='width:" . kw . "px'>5</div><div class='k' data-s='sc7' style='width:" . kw . "px'>6</div><div class='k' data-s='sc8' style='width:" . kw . "px'>7</div><div class='k' data-s='sc9' style='width:" . kw . "px'>8</div><div class='k' data-s='sc10' style='width:" . kw . "px'>9</div><div class='k' data-s='sc11' style='width:" . kw . "px'>0</div><div class='k' data-s='sc12' style='width:" . kw . "px'>-</div><div class='k' data-s='sc13' style='width:" . kw . "px'>=</div><div class='k' data-s='sc14' style='width:" . w2 . "px'>BackSpace</div></div>"
    h := h . "<div class='row'>" . "<div class='k' data-s='sc15' style='width:" . w3 . "px'>Tab</div><div class='k' data-s='sc16' style='width:" . kw . "px'>q</div><div class='k' data-s='sc17' style='width:" . kw . "px'>w</div><div class='k' data-s='sc18' style='width:" . kw . "px'>e</div><div class='k' data-s='sc19' style='width:" . kw . "px'>r</div><div class='k' data-s='sc20' style='width:" . kw . "px'>t</div><div class='k' data-s='sc21' style='width:" . kw . "px'>y</div><div class='k' data-s='sc22' style='width:" . kw . "px'>u</div><div class='k' data-s='sc23' style='width:" . kw . "px'>i</div><div class='k' data-s='sc24' style='width:" . kw . "px'>o</div><div class='k' data-s='sc25' style='width:" . kw . "px'>p</div><div class='k' data-s='sc26' style='width:" . kw . "px'>[</div><div class='k' data-s='sc27' style='width:" . kw . "px'>]</div><div class='k' data-s='sc43' style='width:" . w3 . "px'>\</div></div>"
    h := h . "<div class='row'>" . "<div class='k' data-s='sc58' style='width:" . w4 . "px'>CapsLock</div><div class='k' data-s='sc30' style='width:" . kw . "px'>a</div><div class='k' data-s='sc31' style='width:" . kw . "px'>s</div><div class='k' data-s='sc32' style='width:" . kw . "px'>d</div><div class='k' data-s='sc33' style='width:" . kw . "px'>f</div><div class='k' data-s='sc34' style='width:" . kw . "px'>g</div><div class='k' data-s='sc35' style='width:" . kw . "px'>h</div><div class='k' data-s='sc36' style='width:" . kw . "px'>j</div><div class='k' data-s='sc37' style='width:" . kw . "px'>k</div><div class='k' data-s='sc38' style='width:" . kw . "px'>l</div><div class='k' data-s='sc39' style='width:" . kw . "px'>;</div><div class='k' data-s='sc40' style='width:" . kw . "px'>'</div><div class='k' data-s='sc28' style='width:" . w4 . "px'>Enter</div></div>"
    h := h . "<div class='row'>" . "<div class='k' data-s='sc42' style='width:" . w5 . "px'>Shift</div><div class='k' data-s='sc44' style='width:" . kw . "px'>z</div><div class='k' data-s='sc45' style='width:" . kw . "px'>x</div><div class='k' data-s='sc46' style='width:" . kw . "px'>c</div><div class='k' data-s='sc47' style='width:" . kw . "px'>v</div><div class='k' data-s='sc48' style='width:" . kw . "px'>b</div><div class='k' data-s='sc49' style='width:" . kw . "px'>n</div><div class='k' data-s='sc50' style='width:" . kw . "px'>m</div><div class='k' data-s='sc51' style='width:" . kw . "px'>,</div><div class='k' data-s='sc52' style='width:" . kw . "px'>.</div><div class='k' data-s='sc53' style='width:" . kw . "px'>/</div><div class='k' data-s='sc310' style='width:" . w5 . "px'>Shift</div></div>"
    h := h . "<div class='row'>" . "<div class='k' data-s='sc29' style='width:" . w6_1 . "px'>Ctrl</div><div class='k' data-s='sc347' style='width:" . w6_2 . "px'>Win</div><div class='k' data-s='sc56' style='width:" . w6_2 . "px'>Alt</div><div class='k' data-s='sc57' style='width:" . w6_3 . "px'>Space</div><div class='k' data-s='sc312' style='width:" . w6_2 . "px'>Alt</div><div class='k' data-s='sc348' style='width:" . w6_2 . "px'>Win</div><div class='k' data-s='sc285' style='width:" . w6_1 . "px'>Ctrl</div></div></div>"
    h := h . "<div class='side'>" . "<div><div class='nr'><div class='k' data-s='sc338' style='width:" . kw . "px'>Insert</div><div class='k' data-s='sc327' style='width:" . kw . "px'>Home</div><div class='k' data-s='sc329' style='width:" . kw . "px'>PageUp</div></div><div class='nr'><div class='k' data-s='sc339' style='width:" . kw . "px'>Delete</div><div class='k' data-s='sc335' style='width:" . kw . "px'>End</div><div class='k' data-s='sc337' style='width:" . kw . "px'>PageDn</div></div></div>"
    h := h . "<div><div class='nr'><div class='k' data-s='sc328' style='width:" . kw . "px'>▲</div></div><div class='nr'><div class='k' data-s='sc331' style='width:" . kw . "px'>◀</div><div class='k' data-s='sc336' style='width:" . kw . "px'>▼</div><div class='k' data-s='sc333' style='width:" . kw . "px'>▶</div></div></div>"
    h := h . "<div class='np'><div class='k' data-s='sc325' style='width:" . kw . "px;display:flex;flex-direction:column;line-height:1.15'><span>Num</span><span>Lock</span></div><div class='k' data-s='sc309' style='width:" . kw . "px'>/</div><div class='k' data-s='sc55' style='width:" . kw . "px'>*</div><div class='k' data-s='sc74' style='width:" . kw . "px'>-</div><div class='k' data-s='sc71' style='width:" . kw . "px'>7</div><div class='k' data-s='sc72' style='width:" . kw . "px'>8</div><div class='k' data-s='sc73' style='width:" . kw . "px'>9</div><div class='k kt' data-s='sc78' style='grid-row:span 2;height:" . (kh*2+ks) . "px'>+</div><div class='k' data-s='sc75' style='width:" . kw . "px'>4</div><div class='k' data-s='sc76' style='width:" . kw . "px'>5</div><div class='k' data-s='sc77' style='width:" . kw . "px'>6</div><div class='k' data-s='sc79' style='width:" . kw . "px'>1</div><div class='k' data-s='sc80' style='width:" . kw . "px'>2</div><div class='k' data-s='sc81' style='width:" . kw . "px'>3</div><div class='k kw' data-s='sc82' style='grid-column:span 2'>0</div><div class='k' data-s='sc83' style='width:" . kw . "px'>.</div></div></div></div>"
    h := h . "<div class='st'><table><thead><tr><th>Item</th><th style='text-align:right'>Today</th><th style='text-align:right'>Total</th></tr></thead><tbody id='tb'>"
    h := h . "<tr><td>Mouse Movement</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Keyboard Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Left Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Right Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Middle Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Wheel Scrolls</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Wheel Tilt</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Side Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Screen Size</td><td class='rv'>-</td><td class='rv'>-</td></tr></tbody></table></div>"
    h := h . "<script>var gc=[];function gg(c1,c2,n){var i,r1=parseInt(c1.substr(0,2),16),g1=parseInt(c1.substr(2,2),16),b1=parseInt(c1.substr(4,2),16),r2=parseInt(c2.substr(0,2),16),g2=parseInt(c2.substr(2,2),16),b2=parseInt(c2.substr(4,2),16),rd=(r2-r1)/(n-1),gd=(g2-g1)/(n-1),bd=(b2-b1)/(n-1);gc=[];for(i=0;i<n;i++){var r=Math.round(r1+rd*i),g=Math.round(g1+gd*i),b=Math.round(b1+bd*i);gc.push('#'+(r<16?'0':'')+r.toString(16)+(g<16?'0':'')+g.toString(16)+(b<16?'0':'')+b.toString(16))}}"
    h := h . "function ud(d){var ks=d.ks||{},mk=d.tk/10||1;gg(d.hs,d.he,100);var els=document.querySelectorAll('.k[data-s]');for(var i=0;i<els.length;i++){var e=els[i],sc=e.getAttribute('data-s'),cnt=parseInt(ks[sc])||0;if(cnt>=mk)e.style.background='#'+d.he;else if(cnt<mk/100)e.style.background='#3A3A3C';else e.style.background=gc[Math.floor(cnt/mk*100)-1]||gc[0];var tt=e.querySelector('.tt');if(!tt){tt=document.createElement('div');tt.className='tt';e.appendChild(tt)}tt.textContent=cnt}"
    h := h . "var tb=document.getElementById('tb');if(tb&&d.st){tb.innerHTML='';for(var i=0;i<d.st.length;i++){var s=d.st[i];tb.innerHTML+='<tr><td>'+s.n+'</td><td class=\'rv\'>'+s.t+'</td><td class=\'rv\'>'+s.t2+'</td></tr>'}}}"
    h := h . "function sc(c){document.title='n:'+c;setTimeout(function(){document.title=''},50)}"
    h := h . "document.addEventListener('wheel',function(e){if(e.deltaY>0)sc('-1');else if(e.deltaY<0)sc('1')},{passive:true})"
    h := h . "document.addEventListener('keydown',function(e){var k=e.key;if(k==='PageDown'||k==='ArrowDown'){sc('-1');e.preventDefault()}else if(k==='PageUp'||k==='ArrowUp'){sc('1');e.preventDefault()}})</script></body></html>"
    return h
}

