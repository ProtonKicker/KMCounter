#NoEnv
#SingleInstance Force

; Simplified version of LoadControlList to check for duplicates
LoadControlList(layout:="")
{
  KeyW := 52
  KeyH := 45
  KeySpacing := 2
  HorizontalSpacing := 10
  VerticalSpacing := 10

  m:=[KeySpacing, "+" KeySpacing, HorizontalSpacing, "+" HorizontalSpacing, VerticalSpacing, "+" VerticalSpacing, "", ""]

  w := KeyW
  h := KeyH
  w2 := w*2+10
  w3 := (w*13 + w2 - w*12 + m.1*0)/2
  w4 := (w*13 + w2 - w*11 + m.1*1)/2
  w5 := (w*13 + w2 - w*10 + m.1*2)/2
  w6_1 := w3
  w6_2 := w6_1-10
  w6_3 := (w*13 + w2 - w6_1*2 - w6_2*4 + m.1*7)

  m7 := (w*13 + w2 - w*13 + m.1*4)/3
  m.7 := m7
  m.8 := "+" m7

  list:=[]
  ; First row
  list.push({Hwnd:"sc1", Text:"Esc", x:"", y:"", w:w, h:h})
  list.push({Hwnd:"sc59", Text:"F1", x:m.8, y:"", w:w, h:h})
  list.push({Hwnd:"sc60", Text:"F2", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc61", Text:"F3", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc62", Text:"F4", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc63", Text:"F5", x:m.8, y:"", w:w, h:h})
  list.push({Hwnd:"sc64", Text:"F6", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc65", Text:"F7", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc66", Text:"F8", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc67", Text:"F9", x:m.8, y:"", w:w, h:h})
  list.push({Hwnd:"sc68", Text:"F10", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc87", Text:"F11", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc88", Text:"F12", x:m.2, y:"", w:w, h:h})
  ; Second row
  list.push({Hwnd:"sc41", Text:"``", x:"m", y:m.4, w:w, h:h})
  list.push({Hwnd:"sc2", Text:"1", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc3", Text:"2", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc4", Text:"3", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc5", Text:"4", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc6", Text:"5", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc7", Text:"6", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc8", Text:"7", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc9", Text:"8", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc10", Text:"9", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc11", Text:"0", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc12", Text:"-", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc13", Text:"=", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc14", Text:"BackSpace", x:m.2, y:"", w:w2, h:h})
  ; Third row
  list.push({Hwnd:"sc15", Text:"Tab", x:"m", y:m.2, w:w3, h:h})
  list.push({Hwnd:"sc16", Text:"q", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc17", Text:"w", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc18", Text:"e", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc19", Text:"r", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc20", Text:"t", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc21", Text:"y", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc22", Text:"u", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc23", Text:"i", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc24", Text:"o", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc25", Text:"p", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc26", Text:"[", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc27", Text:"]", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc43", Text:"\\", x:m.2, y:"", w:w3, h:h})
  ; Fourth row
  list.push({Hwnd:"sc58", Text:"CapsLock", x:"m", y:m.2, w:w4, h:h})
  list.push({Hwnd:"sc30", Text:"a", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc31", Text:"s", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc32", Text:"d", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc33", Text:"f", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc34", Text:"g", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc35", Text:"h", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc36", Text:"j", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc37", Text:"k", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc38", Text:"l", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc39", Text:";", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc40", Text:"'", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc28", Text:"Enter", x:m.2, y:"", w:w4, h:h})
  ; Fifth row
  list.push({Hwnd:"sc42", Text:"Shift", x:"m", y:m.2, w:w5, h:h})
  list.push({Hwnd:"sc44", Text:"z", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc45", Text:"x", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc46", Text:"c", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc47", Text:"v", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc48", Text:"b", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc49", Text:"n", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc50", Text:"m", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc51", Text:",", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc52", Text:".", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc53", Text:"/", x:m.2, y:"", w:w, h:h})
  list.push({Hwnd:"sc310", Text:"Shift", x:m.2, y:"", w:w5, h:h})
  ; Sixth row
  list.push({Hwnd:"sc29", Text:"Ctrl", x:"m", y:m.2, w:w6_1, h:h})
  list.push({Hwnd:"sc347", Text:"Win", x:m.2, y:"", w:w6_2, h:h})
  list.push({Hwnd:"sc56", Text:"Alt", x:m.2, y:"", w:w6_2, h:h})
  list.push({Hwnd:"sc57", Text:"Space", x:m.2, y:"", w:w6_3, h:h})
  list.push({Hwnd:"sc312", Text:"Alt", x:m.2, y:"", w:w6_2, h:h})
  list.push({Hwnd:"sc348", Text:"Win", x:m.2, y:"", w:w6_2, h:h})
  list.push({Hwnd:"sc285", Text:"Ctrl", x:m.2, y:"", w:w6_1, h:h})

  return list
}

; Check for duplicates
list := LoadControlList()
hwnds := {}
for k, control in list {
    if (control.Hwnd && InStr(control.Hwnd, "sc")) {
        if (hwnds[control.Hwnd]) {
            MsgBox, Duplicate found: %control.Hwnd%
            ExitApp, 1
        }
        hwnds[control.Hwnd] := true
    }
}

MsgBox, No duplicates found!
ExitApp, 0
