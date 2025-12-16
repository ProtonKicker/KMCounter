#NoEnv
#SingleInstance Force
SetBatchLines, -1

global APPName:="KMCounter", ver:=3.7

; Simple color control functions
ChangeControlColor(control, bgColor, textColor) {
    ; Simplified to just set font color to avoid Color command syntax issues
    GuiControl, Font, %control%, c%textColor%
}
FreeControlColors() {
    ; Empty implementation for compatibility
}

; Test GUI
Gui, Add, Text, x10 y10 w100 h30 vtestCtrl, Test
ChangeControlColor("testCtrl", "FFFFFF", "FF0000")

Gui, Show, w200 h200, Test

return

GuiClose:
ExitApp
