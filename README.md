# KMCounter

A keyboard counter application with customizable interface.

## Features
- Keyboard key press counting
- Customizable font size
- Vertically centered key letters
- English language support
- Customizable key highlight colors
- "Restore default" option in settings

## Requirements
- AutoHotkey v1.1.x (for running the script directly)
- AutoHotkey Compiler (for compiling to EXE)

## How to Run Directly

1. Download and install AutoHotkey from [https://www.autohotkey.com/](https://www.autohotkey.com/)
2. Double-click on `KMCounter.ahk` to run the application

## How to Compile to EXE

1. Download and install AutoHotkey from [https://www.autohotkey.com/](https://www.autohotkey.com/)
2. Locate the AutoHotkey Compiler (`Ahk2Exe.exe`):
   - Usually found at `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`
3. Open `Ahk2Exe.exe`
4. In the "Source" field, browse to select `KMCounter.ahk`
5. In the "Destination" field, specify where you want the compiled EXE to be saved
6. Click the "Convert" button to compile the application

## Customization

You can customize the following settings through the settings menu:
- Keyboard appearance (font size, colors)
- Language (Chinese/English)
- Key highlight colors
- Keyboard layout dimensions

## Troubleshooting

### "The same variable cannot be used for more than one control" error
This error occurs if the GUI is not properly destroyed before recreation. The script now includes a `Gui, Destroy` command at the beginning of the GUI creation function to prevent this issue.

### Language Support
The application automatically detects the system language and switches between Chinese and English interfaces. You can modify the `MultiLanguage` section in the script to customize translations.

## Files
- `KMCounter.ahk`: Main application script
- `find_duplicate_hwnd.ps1`: PowerShell script for debugging duplicate Hwnd values
- `test_fix.ahk`: Test script for verifying GUI creation fixes

## License
[MIT License](LICENSE)
