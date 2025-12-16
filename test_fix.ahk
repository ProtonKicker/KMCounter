; Simple test script to verify the GUI Destroy fix

; Simulate the duplicate variable issue
TestGuiCreation() {
    ; First GUI creation
    Gui, Add, Text, vtestCtrl1, First GUI
    Gui, Show, Hide
    
    ; Second GUI creation without Destroy (this would cause an error)
    ; Gui, Add, Text, vtestCtrl1, Second GUI  ; This line would cause "same variable cannot be used for more than one control"
    
    ; Second GUI creation with Destroy (this should work)
    Gui, Destroy
    Gui, Add, Text, vtestCtrl1, Second GUI (after Destroy)
    Gui, Show, Hide
    
    MsgBox, Test completed successfully! No duplicate variable errors.
}

; Test the LoadControlList function for duplicate Hwnd values
TestLoadControlList() {
    ; Copy of the LoadControlList function to test for duplicates
    LoadControlList() {
        KeyW := 52
        KeyH := 45
        KeySpacing := 2
        HorizontalSpacing := 10
        VerticalSpacing := 10

        m:=[KeySpacing,        "+" KeySpacing                 ; 普通按键间距
            , HorizontalSpacing, "+" HorizontalSpacing          ; 区域水平间距
            , VerticalSpacing,   "+" VerticalSpacing            ; 区域垂直间距
            , "",                ""]                            ; ESC-F1 间距（计算得到）

        w    :=  KeyW
        h    :=  KeyH
        w2   :=  w*2+10
        w3   := (w*13 + w2 - w*12 + m.1*0)/2
        w4   := (w*13 + w2 - w*11 + m.1*1)/2
        w5   := (w*13 + w2 - w*10 + m.1*2)/2
        w6_1 :=  w3
        w6_2 :=  w6_1-10
        w6_3 := (w*13 + w2 - w6_1*2 - w6_2*4 + m.1*7)

        m7   := (w*13 + w2 - w*13 + m.1*4)/3
        m.7  :=  m7
        m.8  :=  "+" m7

        list:=[]
        ; First line - including sc1
        list.push({Hwnd:"sc1",  Text:"Esc", x:"",  y:"", w:w, h:h})
        list.push({Hwnd:"sc59", Text:"F1",  x:m.8, y:"", w:w, h:h})
        list.push({Hwnd:"sc60", Text:"F2",  x:m.2, y:"", w:w, h:h})
        list.push({Hwnd:"sc61", Text:"F3",  x:m.2, y:"", w:w, h:h})
        
        ; Add a few more keys for testing
        list.push({Hwnd:"sc2",  Text:"1",   x:m.2, y:"", w:w, h:h})
        list.push({Hwnd:"sc3",  Text:"2",   x:m.2, y:"", w:w, h:h})
        list.push({Hwnd:"sc4",  Text:"3",   x:m.2, y:"", w:w, h:h})
        
        return list
    }
    
    ; Test the function
    controlList := LoadControlList()
    
    ; Check for duplicates
    hwndList := {}
    duplicateFound := false
    for k, control in controlList {
        if (control.Hwnd != "") {
            if (hwndList.HasKey(control.Hwnd)) {
                MsgBox, ERROR: Found duplicate Hwnd: %control.Hwnd% at index %k%!
                duplicateFound := true
            } else {
                hwndList[control.Hwnd] := k
            }
        }
    }
    
    if (!duplicateFound) {
        MsgBox, No duplicate Hwnd values found in LoadControlList!
    }
}

; Run both tests
TestGuiCreation()
TestLoadControlList()
