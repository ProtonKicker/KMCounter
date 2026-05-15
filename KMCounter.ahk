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
  ; Native settings bar with section-based relative positioning
  Gui, Font, s10 Bold cFFFFFF, Microsoft YaHei
  Gui, Add, Text, x8 y6 wauto h20 Section, %APPName%
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  ; Version removed per user request
  Gui, Font, % "s9 c" t.accent, Microsoft YaHei
  Gui, Add, Text, x+10 ys wauto h20 vDateDisplay, % today
  Gui, Font, % "s11 c" t.accent, Microsoft YaHei
  Gui, Add, Text, x+8 ys w22 h22 Center gShowSettings, ⚙
  yb:=30
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, x8 y%yb% w40 h18 Section, Store:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, xs+40 ys-2 w44 h18 Number Limit vdsd1, % DataStorageDays
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, x+4 ys w14 h18, d
  Gui, Add, Text, x+8 ys w30 h18, Theme:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Text, x+2 ys w50 h18 vThemeDisplay gThemeCycle, % currentTheme
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, x+8 ys w42 h18, Key Width:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, x+2 ys-2 w36 h18 Number Limit vlkw1, % layout.kw
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, x+6 ys w44 h18, Key Height:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, x+2 ys-2 w36 h18 Number Limit vlkh1, % layout.kh
  Gui, Font, s7 c94A3B8, Microsoft YaHei
  Gui, Add, Text, x+6 ys w36 h18, Font Size:
  Gui, Font, s7 cD4D4D4, Microsoft YaHei
  Gui, Add, Edit, x+2 ys-2 w32 h18 Number Limit vlfs1, % layout.fs
  Gui, Font, s7 cFFFFFF, Microsoft YaHei
  Gui, Add, Button, x+6 ys-2 w30 h18 gApplySettings, ✓
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
  th:=bh+60
  Gui, Show, w%tw% h%th%
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
  KeyW              := NonNull_Ret(layout.kw,  52, 30)
  KeyH              := NonNull_Ret(layout.kh,  45, 25)
  KeySpacing        := NonNull_Ret(layout.ks,  2,  0)
  HorizontalSpacing := NonNull_Ret(layout.khs, 10, 0)
  VerticalSpacing   := NonNull_Ret(layout.kvs, 10, 0)

  m:=[KeySpacing,        "+" KeySpacing
    , HorizontalSpacing, "+" HorizontalSpacing
    , VerticalSpacing,   "+" VerticalSpacing
    , "",                ""]

  w    := KeyW
  h    := KeyH
  ; Row 1: half-height keys (rendered at half height via CSS)
  ; Row 2: `(narrower) + 1-0 + - + = + Bksp(2u) + NP/(calc) + NP-(calc) + NP+(calc) + NP.(calc)
  ; Row 3: Tab + q-p + [ + ] + \(1.5u) + NP7 + NP8 + NP9
  ; Row 4: CapsLock + a-; + ' + Enter(2u) + NP4 + NP5 + NP6
  ; Row 5: Shift(2u) + z-m + , + . + / + Shift(1.25u) + ▲ + NP1 + NP2 + NP3
  ; Row 6: Ctrl + Fn + Win + Alt + Space(6u C→M) + Alt + Copilot + Ctrl(1.25u) + ◀ + ▼ + ▶ + NP0

  ; Column grid: 17 columns of 1u each, gaps between
  ; Left Shift = 2u, Tab = 1.5u, CapsLock = ~1.83u, Bksp = ~2u, Enter = ~2u, RShift = 1.25u, RCtrl = 1.25u

  wBksp := w*2
  wTab  := w*23//20   ; ~1.15u, slightly wider than standard
  wCaps := (wTab + wLShift)//2  ; midway between Tab and LShift
  wEnter:= w*2-4
  wLShift:= w*2
  wRShift:= w*5//4
  wBackslash:= w*3//2
  wRCtrl:= w*5//4
  wSpace:= 5*w + 4*ks   ; from left of C to right of M
  wTilde:= w*3//4
  list:=[]

  ; Row 1: Esc | F1-F12 (no gaps) | Ins | Del | NumLock | *
  list.push({Hwnd:"sc1",   Text:"Esc",     x:"m", y:"", w:w, h:h})
  list.push({Hwnd:"sc59",  Text:"F1",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc60",  Text:"F2",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc61",  Text:"F3",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc62",  Text:"F4",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc63",  Text:"F5",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc64",  Text:"F6",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc65",  Text:"F7",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc66",  Text:"F8",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc67",  Text:"F9",      x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc68",  Text:"F10",     x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc87",  Text:"F11",     x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc88",  Text:"F12",     x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc338", Text:"Insert",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc339", Text:"Delete",  x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc325", Text:"NumLock", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc55",  Text:"*",       x:m.2, y:"", w:w, h:h})
  ; FP key removed (not a keyboard input)
  ; Row 2: `(smaller) | 1-0 | - | = | Bksp(2u) | / | - | + | .
  list.push({Hwnd:"sc41",  Text:"``",      x:"m", y:m.4, w:wTilde, h:h})
  list.push({Hwnd:"sc2",   Text:"1",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc3",   Text:"2",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc4",   Text:"3",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc5",   Text:"4",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc6",   Text:"5",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc7",   Text:"6",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc8",   Text:"7",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc9",   Text:"8",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc10",  Text:"9",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc11",  Text:"0",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc12",  Text:"-",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc13",  Text:"=",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc14",  Text:"⌫",    x:m.2, y:"",  w:wBksp, h:h})
  list.push({Hwnd:"sc309", Text:"/",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc74",  Text:"-",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc78",  Text:"+",       x:m.2, y:"",  w:w, h:h})
  ; Row 3: Tab(1.5u) | q-p | [ | ] | \(1.5u) | NP7 | NP8 | NP9
  list.push({Hwnd:"sc15",  Text:"Tab",     x:"m", y:m.2, w:wTab, h:h})
  list.push({Hwnd:"sc16",  Text:"Q",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc17",  Text:"W",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc18",  Text:"E",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc19",  Text:"R",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc20",  Text:"T",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc21",  Text:"Y",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc22",  Text:"U",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc23",  Text:"I",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc24",  Text:"O",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc25",  Text:"P",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc26",  Text:"[",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc27",  Text:"]",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc43",  Text:"\",       x:m.2, y:"",  w:wBackslash, h:h})
  list.push({Hwnd:"sc71",  Text:"7",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc72",  Text:"8",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc73",  Text:"9",       x:m.2, y:"",  w:w, h:h})
  ; Row 4: CapsLock(1.83u) | a-; | ' | Enter(2u) | NP4 | NP5 | NP6
  list.push({Hwnd:"sc58",  Text:"Caps",  x:"m", y:m.2, w:wCaps, h:h})
  list.push({Hwnd:"sc30",  Text:"A",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc31",  Text:"S",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc32",  Text:"D",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc33",  Text:"F",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc34",  Text:"G",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc35",  Text:"H",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc36",  Text:"J",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc37",  Text:"K",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc38",  Text:"L",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc39",  Text:";",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc40",  Text:"'",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc28",  Text:"Enter",     x:m.2, y:"",  w:wEnter, h:h})
  list.push({Hwnd:"sc75",  Text:"4",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc76",  Text:"5",         x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc77",  Text:"6",         x:m.2, y:"",  w:w, h:h})
  ; Row 5: Shift(2u) | z-m | , | . | / | Shift(1.25u) | ▲ | NP1 | NP2 | NP3
  list.push({Hwnd:"sc42",  Text:"Shift",  x:"m", y:m.2, w:wLShift, h:h})
  list.push({Hwnd:"sc44",  Text:"Z",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc45",  Text:"X",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc46",  Text:"C",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc47",  Text:"V",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc48",  Text:"B",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc49",  Text:"N",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc50",  Text:"M",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc51",  Text:",",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc52",  Text:".",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc53",  Text:"/",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc310", Text:"Shift",  x:m.2, y:"",  w:wRShift, h:h})
  list.push({Hwnd:"sc328", Text:"▲",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc79",  Text:"1",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc80",  Text:"2",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc81",  Text:"3",      x:m.2, y:"",  w:w, h:h})
  ; Row 6: Ctrl | Fn | Win | Alt | Space(6u) | Alt | Copilot | Ctrl(1.25u) | ◀ | ▼ | ▶ | NP0
  list.push({Hwnd:"sc29",   Text:"Ctrl",    x:"m", y:m.2, w:w, h:h})
  list.push({Hwnd:"scFn",   Text:"Fn",      x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc347",  Text:"Win",     x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc56",   Text:"Alt",     x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc57",   Text:"",   x:m.2, y:"",  w:wSpace, h:h})
  list.push({Hwnd:"sc312",  Text:"Alt",     x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"scCopilot", Text:"Copilot", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc285",  Text:"Ctrl",    x:m.2, y:"",  w:wRCtrl, h:h})
  list.push({Hwnd:"sc331",  Text:"◀",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc336",  Text:"▼",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc333",  Text:"▶",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc82",   Text:"0",       x:m.2, y:"",  w:w, h:h})
  list.push({Hwnd:"sc83",   Text:".",       x:m.2, y:"",  w:w, h:h})

  ; Stats area below keyboard, half-ish width
    temp1:="m"
  , temp2:=8*w + m.1*7
  , temp3:=300
  list.push({Hwnd:"Message", Text:"",      x:temp1, y:"m+" . (h*6 + m.1*5), w:temp2, h:temp3})

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
            if (history > tomorrow)
                history := firstday
            if (history < firstday)
                history := tomorrow
            if (history = tomorrow) {
                date := "Total"
                gosub ShowHeatMap
                break
            }
            if (LoadData(history) and date!=history) {
                date := history
                gosub ShowHeatMap
                break
            }
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
    w := kw
    wBksp := w*2
    wTab  := w*23//20
    wLShift:= w*2
    wRShift:= w*5//4
    wRCtrl:= w*5//4
    wBackslash:= w*3//2
    wCaps := (wTab + wLShift)//2
    wSpace:= 5*w + 4*ks   ; from left of C to right of M
    wTilde:= w*3//4
    wEnter:= w*2
    kfsm  := Max(kfs-3, 7)
    h := "<!DOCTYPE html><html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'>"
    h := h . "<style>*{margin:0;padding:0;box-sizing:border-box}body{background:#1E1E1E;font-family:Microsoft YaHei,sans-serif;color:#D4D4D4;overflow-y:auto;user-select:none;padding:8px 12px 0}"
    h := h . ".row{display:flex;gap:2px;margin-bottom:3px}"
    h := h . ".k{height:" . kh . "px;background:#3A3A3C;border-radius:4px;display:flex;align-items:center;justify-content:center;font-size:" . kfs . "px;color:#D4D4D4;box-shadow:0 1px 2px rgba(0,0,0,0.3);cursor:default;flex-shrink:0;position:relative;overflow:hidden;white-space:nowrap;text-overflow:ellipsis;padding:0 2px;line-height:1.1}"
    h := h . ".r1{height:" . (kh//2) . "px;font-size:" . Max(kfs-2, 8) . "px}.k:hover{z-index:2;box-shadow:0 3px 8px rgba(0,0,0,0.5)}.g{flex-shrink:0}"
    h := h . ".k .tt{display:none;position:absolute;bottom:calc(100%+4px);left:50%;transform:translateX(-50%);background:#1A1A1C;color:#D4D4D4;padding:3px 8px;border-radius:4px;font-size:10px;white-space:nowrap;pointer-events:none;z-index:10;border:1px solid #3A3A3C}"
    h := h . ".k:hover .tt{display:block}"
    h := h . ".st{margin-top:8px;background:#252528;border-radius:6px;overflow:hidden;width:fit-content;min-width:300px}"
    h := h . ".st table{width:100%;border-collapse:collapse;font-size:12px}"
    h := h . ".st th{background:#2A2A2D;color:#94A3B8;padding:5px 10px;text-align:left;font-weight:600;font-size:10px;text-transform:uppercase;letter-spacing:0.5px}"
    h := h . ".st td{padding:4px 10px;border-top:1px solid #2E2E30;font-size:12px}"
    h := h . ".st tr:first-child td{border-top:none}.st tr:nth-child(even) td{background:rgba(255,255,255,0.02)}"
    h := h . ".st .rv{text-align:right;color:#A0A0A4;font-variant-numeric:tabular-nums}</style></head><body>"
    ; Row 1: half-height, Esc F1-F12 Ins Del NumLk *
    h := h . "<div class='row'>"
    h := h . "<div class='k r1' data-s='sc1' style='width:" . w . "px'>Esc</div>"
    Loop 12 {
        sc := ["sc59","sc60","sc61","sc62","sc63","sc64","sc65","sc66","sc67","sc68","sc87","sc88"][A_Index]
        h := h . "<div class='k r1' data-s='" . sc . "' style='width:" . w . "px'>F" . A_Index . "</div>"
    }
    h := h . "<div class='k r1' data-s='sc338' style='width:" . w . "px'>Ins</div><div class='k r1' data-s='sc339' style='width:" . w . "px'>Del</div><div class='g' style='width:10px'></div><div class='k r1' data-s='sc325' style='width:" . w . "px'>NumLock</div><div class='k r1' data-s='sc55' style='width:" . w . "px'>*</div></div>"
    ; Row 2: `(smaller) 1-0 - = Bksp(2u) / - + .
    h := h . "<div class='row'><div class='k' data-s='sc41' style='width:" . wTilde . "px'>&#96;</div>"
    Loop 10 {
        sc := ["sc2","sc3","sc4","sc5","sc6","sc7","sc8","sc9","sc10","sc11"][A_Index]
        n := A_Index = 10 ? 0 : A_Index
        h := h . "<div class='k' data-s='" . sc . "' style='width:" . w . "px'>" . n . "</div>"
    }
    h := h . "<div class='k' data-s='sc12' style='width:" . w . "px'>-</div><div class='k' data-s='sc13' style='width:" . w . "px'>=</div><div class='k' data-s='sc14' style='width:" . wBksp . "px'>⌫</div><div class='g' style='width:10px'></div><div class='k' data-s='sc309' style='width:" . w . "px'>/</div><div class='k' data-s='sc74' style='width:" . w . "px'>-</div><div class='k' data-s='sc78' style='width:" . w . "px'>+</div></div>"
    ; Row 3: Tab(1.15u) q-p [ ] \(1.5u) 7 8 9
    h := h . "<div class='row'><div class='k' data-s='sc15' style='width:" . wTab . "px'>Tab</div>"
    letters := ["Q","W","E","R","T","Y","U","I","O","P"]
    scs := ["sc16","sc17","sc18","sc19","sc20","sc21","sc22","sc23","sc24","sc25"]
    Loop 10 {
        h := h . "<div class='k' data-s='" . scs[A_Index] . "' style='width:" . w . "px'>" . letters[A_Index] . "</div>"
    }
    h := h . "<div class='k' data-s='sc26' style='width:" . w . "px'>[</div><div class='k' data-s='sc27' style='width:" . w . "px'>]</div><div class='k' data-s='sc43' style='width:" . wBackslash . "px'>\</div><div class='g' style='width:10px'></div><div class='k' data-s='sc71' style='width:" . w . "px'>7</div><div class='k' data-s='sc72' style='width:" . w . "px'>8</div><div class='k' data-s='sc73' style='width:" . w . "px'>9</div></div>"
    ; Row 4: Caps a-; ' Enter(2u) 4 5 6
    h := h . "<div class='row'><div class='k' data-s='sc58' style='width:" . wCaps . "px'>Caps</div>"
    letters2 := ["A","S","D","F","G","H","J","K","L",";","'"]
    scs2 := ["sc30","sc31","sc32","sc33","sc34","sc35","sc36","sc37","sc38","sc39","sc40"]
    Loop 11 {
        h := h . "<div class='k' data-s='" . scs2[A_Index] . "' style='width:" . w . "px'>" . letters2[A_Index] . "</div>"
    }
    h := h . "<div class='k' data-s='sc28' style='width:" . wEnter . "px'>Enter</div><div class='g' style='width:10px'></div><div class='k' data-s='sc75' style='width:" . w . "px'>4</div><div class='k' data-s='sc76' style='width:" . w . "px'>5</div><div class='k' data-s='sc77' style='width:" . w . "px'>6</div></div>"
    ; Row 5: Shift(2u) z-m , . / Shift(1.25u) ▲ 1 2 3
    h := h . "<div class='row'><div class='k' data-s='sc42' style='width:" . wLShift . "px'>Shift</div>"
    letters3 := ["Z","X","C","V","B","N","M"]
    scs3 := ["sc44","sc45","sc46","sc47","sc48","sc49","sc50"]
    Loop 7 {
        h := h . "<div class='k' data-s='" . scs3[A_Index] . "' style='width:" . w . "px'>" . letters3[A_Index] . "</div>"
    }
    h := h . "<div class='k' data-s='sc51' style='width:" . w . "px'>,</div><div class='k' data-s='sc52' style='width:" . w . "px'>.</div><div class='k' data-s='sc53' style='width:" . w . "px'>/</div><div class='k' data-s='sc310' style='width:" . wRShift . "px'>Shift</div><div class='k' data-s='sc328' style='width:" . w . "px'>▲</div><div class='g' style='width:10px'></div><div class='k' data-s='sc79' style='width:" . w . "px'>1</div><div class='k' data-s='sc80' style='width:" . w . "px'>2</div><div class='k' data-s='sc81' style='width:" . w . "px'>3</div></div>"
    ; Row 6: Ctrl Fn Win Alt Space(C→M) Alt Copilot Ctrl(1.25u) ◀ ▼ ▶ 0 .
    h := h . "<div class='row'><div class='k' data-s='sc29' style='width:" . w . "px'>Ctrl</div><div class='k' data-s='scFn' style='width:" . w . "px'>Fn</div><div class='k' data-s='sc347' style='width:" . w . "px'>Win</div><div class='k' data-s='sc56' style='width:" . w . "px'>Alt</div><div class='k' data-s='sc57' style='width:" . wSpace . "px'></div><div class='k' data-s='sc312' style='width:" . w . "px'>Alt</div><div class='k' data-s='scCopilot' style='width:" . w . "px'>Copilot</div><div class='k' data-s='sc285' style='width:" . wRCtrl . "px'>Ctrl</div><div class='k' data-s='sc331' style='width:" . w . "px'>◀</div><div class='k' data-s='sc336' style='width:" . w . "px'>▼</div><div class='g' style='width:10px'></div><div class='k' data-s='sc333' style='width:" . w . "px'>▶</div><div class='k' data-s='sc82' style='width:" . w . "px'>0</div><div class='k' data-s='sc83' style='width:" . w . "px'>.</div></div>"
    ; Stats table
    h := h . "<div class='st'><table><thead><tr><th>Item</th><th style='text-align:right'>Today</th><th style='text-align:right'>Total</th></tr></thead><tbody id='tb'>"
    h := h . "<tr><td>Mouse Movement</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Keyboard Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Left Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Right Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Middle Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Wheel Scrolls</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Wheel Tilt</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Side Clicks</td><td class='rv'>-</td><td class='rv'>-</td></tr><tr><td>Screen Size</td><td class='rv'>-</td><td class='rv'>-</td></tr></tbody></table></div>"
    h := h . "<script>var gc=[];function gg(c1,c2,n){var i,r1=parseInt(c1.substr(0,2),16),g1=parseInt(c1.substr(2,2),16),b1=parseInt(c1.substr(4,2),16),r2=parseInt(c2.substr(0,2),16),g2=parseInt(c2.substr(2,2),16),b2=parseInt(c2.substr(4,2),16),rd=(r2-r1)/(n-1),gd=(g2-g1)/(n-1),bd=(b2-b1)/(n-1);gc=[];for(i=0;i<n;i++){var r=Math.round(r1+rd*i),g=Math.round(g1+gd*i),b=Math.round(b1+bd*i);gc.push('#'+(r<16?'0':'')+r.toString(16)+(g<16?'0':'')+g.toString(16)+(b<16?'0':'')+b.toString(16))}}"
    h := h . "function ud(d){var ks=d.ks||{},mk=d.tk/10||1;gg(d.hs,d.he,100);var els=document.querySelectorAll('.k[data-s]');for(var i=0;i<els.length;i++){var e=els[i],sc=e.getAttribute('data-s'),cnt=parseInt(ks[sc])||0;if(cnt>=mk)e.style.background='#'+d.he;else if(cnt<mk/100)e.style.background='#3A3A3C';else e.style.background=gc[Math.floor(cnt/mk*100)-1]||gc[0];var tt=e.querySelector('.tt');if(!tt){tt=document.createElement('div');tt.className='tt';e.appendChild(tt)}tt.textContent=cnt}"
    h := h . "var tb=document.getElementById('tb');if(tb&&d.st){tb.innerHTML='';for(var i=0;i<d.st.length;i++){var s=d.st[i];tb.innerHTML+='<tr><td>'+s.n+'</td><td class=\'rv\'>'+s.t+'</td><td class=\'rv\'>'+s.t2+'</td></tr>'}}}"
    h := h . "function sc(c){document.title='n:'+c;setTimeout(function(){document.title=''},50)}"
    h := h . "document.querySelectorAll('.k').forEach(function(e){if(e.textContent.length>3&&!e.querySelector('span')){e.style.fontSize='9px'}})"
    h := h . "document.addEventListener('wheel',function(e){if(e.deltaY>0)sc('-1');else if(e.deltaY<0)sc('1')},{passive:true})"
    h := h . "document.addEventListener('keydown',function(e){var k=e.key;if(k==='PageDown'||k==='ArrowDown'){sc('-1');e.preventDefault()}else if(k==='PageUp'||k==='ArrowUp'){sc('1');e.preventDefault()}})</script></body></html>"
    return h
}

CreateGui2:
  Gui, 2:Destroy
  Gui, 2:-DPIScale
  Gui, 2:Color, 1E1E1E
  Gui, 2:Font, s12 Bold cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Text, x16 y12, % L_gui2_设置
  yb:=38
  ; History Data
  Gui, 2:Font, s9 Bold c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, x16 y%yb% Section, % L_gui2_历史数据
  yb+=16
  Gui, 2:Font, s8 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x16 y%yb%, % L_gui2_sub1
  yb+=16
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w60 h20, % L_gui2_存储
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vdsd2, % DataStorageDays
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_天
  ; Screen Size
  yb+=26
  Gui, 2:Font, s9 Bold c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% Section, % L_gui2_屏幕尺寸
  yb+=16
  Gui, 2:Font, s8 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb%, % L_gui2_sub2
  yb+=16
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w80 h20, % L_gui2_屏幕宽
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vdw, % devicecaps.w
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_毫米
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, x+16 yp-2 w80 h20, % L_gui2_屏幕高
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vdh, % devicecaps.h
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_毫米
  ; Keyboard Layout
  yb+=26
  Gui, 2:Font, s9 Bold c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% Section, % L_gui2_键盘布局
  yb+=16
  Gui, 2:Font, s8 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb%, % L_gui2_sub3
  yb+=16
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w65 h20, % L_gui2_键宽
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vlkw, % layout.kw
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_像素
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, x+16 yp-2 w65 h20, % L_gui2_键高
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vlkh, % layout.kh
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_像素
  yb+=22
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w65 h20, % L_gui2_键间距
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vlks, % layout.ks
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_像素
  yb+=22
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w65 h20, % L_gui2_区域水平间距
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vlkhs, % layout.khs
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_像素
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, x+16 yp-2 w65 h20, % L_gui2_区域垂直间距
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vlkvs, % layout.kvs
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_像素
  ; Keyboard Appearance
  yb+=26
  Gui, 2:Font, s9 Bold c94A3B8, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% Section, % L_gui2_键盘外观
  yb+=16
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w65 h20, % L_gui2_字体大小
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w50 h20 Number Limit vlfs, % layout.fs
  Gui, 2:Font, s9 c64748B, Microsoft YaHei
  Gui, 2:Add, Text, x+4 yp+2 w30 h20, % L_gui2_号
  yb+=22
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w65 h20, Start Color
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w80 h20 vhighlightStart, % layout.highlightStart
  yb+=22
  Gui, 2:Font, s9 cCBD5E1, Microsoft YaHei
  Gui, 2:Add, Text, xs y%yb% w65 h20, End Color
  Gui, 2:Font, s9 cF1F5F9, Microsoft YaHei
  Gui, 2:Add, Edit, x+4 yp-2 w80 h20 vhighlightEnd, % layout.highlightEnd
  ; Buttons
  yb+=30
  Gui, 2:Font, s9 cFFFFFF, Microsoft YaHei
  Gui, 2:Add, Button, xs y%yb% w70 h24 gGui2Cancel, % L_gui2_取消
  Gui, 2:Add, Button, x+8 yp w60 h24 gGui2Save, % L_gui2_保存
  Gui, 2:Add, Button, x+8 yp w90 h24 gGui2Restore, Restore Default
  ; Compute window size and show
  Gui, 2:Show, AutoSize Center, % L_gui2_设置
return

Gui2Close:
Gui2Escape:
  Gui, 2:Hide
return

Gui2Cancel:
  Gui, 2:Hide
return

Gui2Save:
  Gui, 2:Submit, NoHide
  DataStorageDays := NonNull_Ret(dsd2, 9999, 0)
  UpdateLayout(lkw, lkh, lks, lkhs, lkvs, lfs, highlightStart, highlightEnd)
  UpdateDeviceCaps(dw, dh)
  IniWrite(DataStorageDays, "KMCounter.ini", "history", "storage")
  IniWrite(devicecaps.w,  "KMCounter.ini", "devicecaps", "w")
  IniWrite(devicecaps.h,  "KMCounter.ini", "devicecaps", "h")
  IniWrite(layout.kw,     "KMCounter.ini", "layout", "kw")
  IniWrite(layout.kh,     "KMCounter.ini", "layout", "kh")
  IniWrite(layout.ks,     "KMCounter.ini", "layout", "ks")
  IniWrite(layout.khs,    "KMCounter.ini", "layout", "khs")
  IniWrite(layout.kvs,    "KMCounter.ini", "layout", "kvs")
  IniWrite(layout.fs,     "KMCounter.ini", "layout", "fs")
  IniWrite(layout.highlightStart, "KMCounter.ini", "layout", "highlightStart")
  IniWrite(layout.highlightEnd,   "KMCounter.ini", "layout", "highlightEnd")
  Gui, 2:Hide
  gosub CreateGui1
return

Gui2Restore:
  Gui, 2:Destroy
  DataStorageDays := 9999
  UpdateLayout(52, 45, 2, 4, 4, 9, "3A3A3C", "3B82F6")
  UpdateDeviceCaps()
  IniWrite(DataStorageDays, "KMCounter.ini", "history", "storage")
  IniWrite(devicecaps.w,  "KMCounter.ini", "devicecaps", "w")
  IniWrite(devicecaps.h,  "KMCounter.ini", "devicecaps", "h")
  IniWrite(layout.kw,     "KMCounter.ini", "layout", "kw")
  IniWrite(layout.kh,     "KMCounter.ini", "layout", "kh")
  IniWrite(layout.ks,     "KMCounter.ini", "layout", "ks")
  IniWrite(layout.khs,    "KMCounter.ini", "layout", "khs")
  IniWrite(layout.kvs,    "KMCounter.ini", "layout", "kvs")
  IniWrite(layout.fs,     "KMCounter.ini", "layout", "fs")
  IniWrite(layout.highlightStart, "KMCounter.ini", "layout", "highlightStart")
  IniWrite(layout.highlightEnd,   "KMCounter.ini", "layout", "highlightEnd")
  Gosub CreateGui1
  MsgBox, 64, %APPName%, % L_gui2_已恢复
return

