#NoEnv
#SingleInstance Force
SetBatchLines, -1

global APPName:="KMCounter"

gosub, CreateMenu

OnExit("ExitFunc")

return

CreateMenu:
  Menu, Tray, Add, Exit, MenuHandler
  Menu, Tray, Default, Exit
  if (!A_IsCompiled)
    Menu, Tray, Icon, resouces\KMCounter.ico
return

MenuHandler:
  if (A_ThisMenuItem = "Exit")
    ExitApp
return

ExitFunc()
{
  ExitApp
}