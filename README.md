# KMCounter

A customizable keyboard interface for counting key presses with modern design features.

## Features

- **Customizable font size** for keyboard interface
- Vertically centered key letters for modern look
- **English language support** for keyboard and settings
- **Customizable key highlight colors** (hex color codes for gradient start/end)
- "Restore default" option in settings menu

## Compilation Instructions

To compile KMCounter.ahk into an executable file, follow these steps:

### 1. Install AutoHotkey

Download and install AutoHotkey from the official website:
https://www.autohotkey.com/download/

### 2. Locate Ahk2Exe Compiler

After installation, the compiler can be found at:
`C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`

### 3. Compile the Script

#### Method 1: Using Command Line

Open Command Prompt or PowerShell and run:

```powershell
"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in KMCounter.ahk /out KMCounter.exe
```

#### Method 2: Using GUI Interface

1. Double-click on `Ahk2Exe.exe` from the compiler directory
2. Click "Browse" next to "Source (script file)" and select `KMCounter.ahk`
3. Click "Browse" next to "Destination (EXE file)" and specify where to save `KMCounter.exe`
4. Click "Convert" to compile the script

## Usage

### Running from Source

Double-click `KMCounter.ahk` to run the script directly (requires AutoHotkey installation).

### Running as Executable

After compilation, double-click `KMCounter.exe` to run the application.

### Settings

Right-click on the system tray icon and select "Settings" to:
- Adjust font size
- Change highlight colors (enter hex color codes)
- Restore default settings

## Configuration File

Settings are saved in `KMCounter.ini` and include:
- Font size
- Highlight colors
- Layout parameters

## Support

For issues or questions, please check the source code comments or create an issue on the project's GitHub repository.
