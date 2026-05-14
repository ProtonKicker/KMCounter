# KMCounter

**Turn your typing data into ergonomic insights.**

KMCounter is a keyboard & mouse usage tracker with a live heatmap overlay. It logs every keystroke and click, then visualizes your patterns directly on a rendered keyboard.

## Architecture

```
┌──────────────────────────────────────────────────────┐
│               KMCounter v3.8 — Main Window            │
│  ┌────────────────────────────────────────────────┐  │
│  │ ▲ NATIVE: Settings bar                         │  │
│  │  KMCounter v3.8  [date]  ⚙                     │  │
│  │  Store:[9999]  Theme:Blue  KW:[95]  KH:[87]    │  │
│  │  FS:[16]  [✓ Apply]                            │  │
│  ├────────────────────────────────────────────────┤  │
│  │ ▲ WEBBROWSER (IE ActiveX):                     │  │
│  │                                                │  │
│  │  [Esc][F1][F2][F3][F4]...[F12]    nav/arrows   │  │
│  │  [`][1][2]...[BackSpace]          numpad       │  │
│  │  [Tab][q][w]...[\]                             │  │
│  │  [CapsLock][a][s]...[Enter]                   │  │
│  │  [Shift][z][x]...[/][Shift]                   │  │
│  │  [Ctrl][Win][Alt][Space]...[Ctrl]              │  │
│  │                                                │  │
│  ├────────────────────────────────────────────────┤  │
│  │ Stats: Item       │ Today    │ Total           │  │
│  │ Mouse Movement     │ 12.5m    │ 100.2m         │  │
│  │ Keyboard Clicks    │ 50 times │ 500 times      │  │
│  │ ...                │ ...      │ ...            │  │
│  └────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────┘
         ↓ hooks (low-level system-wide)
  ┌──────────────────┐    ┌──────────────────────┐
  │  LowLevelMouse   │    │  LowLevelKeyboard    │
  │  Proc (LL hook)  │    │  Proc (LL hook)      │
  │  WM_MOUSEMOVE    │    │  WM_KEYUP/SYSKEYUP   │
  │  clicks, wheel   │    │  per-key scancode    │
  └────────┬─────────┘    └──────────┬───────────┘
           │                         │
           └──────────┬──────────────┘
                      ▼
              ┌───────────────┐
              │  Data Layer   │
              │  (KMCounter.ini) │
              │  daily + total │
              └───────────────┘
```

### Data Flow

1. **Hooks** (low-level system-wide `SetWindowsHookEx`) capture every physical mouse/keyboard event — no polling, no CPU cost when idle.
2. **LowLevelKeyboardProc** fires on `WM_KEYUP`/`WM_SYSKEYUP`, records the scancode. **LowLevelMouseProc** fires on move/click/wheel, records distance and counts.
3. Data accumulates in RAM (`mouse[date].move`, `keyboard[date]["scXXX"]`). On exit or day rollover, it's flushed to `KMCounter.ini` (plaintext, same folder).
4. **UpdateBrowserData** builds a JSON payload of current key counts and stats, calls `WB.document.parentWindow.updateData(json)`. The browser JS generates a 100-step gradient from `highlightStart` to `highlightEnd` and colors each key proportionally. Hover tooltips show per-key counts.
5. **Stats table** is rendered by the browser. The JS `ud()` function receives 9 metric rows (mouse movement, keyboard clicks, left/right/middle clicks, wheel scrolls, wheel tilt, side clicks, screen size) with Today and Total columns, and updates the HTML table.
6. **Settings Bar** (top of window) allows live adjustment of Storage Days, Key Width, Key Height, and Font Size — Apply triggers a reload.
7. **History navigation**: PgUp/PgDn/Arrows/Wheel scroll through past days. The `LoadData()` function cycles through stored INI sections, or resets to "Total" / "Today".

### Window Layout (top to bottom)

| Section | Rendering | Contents |
|---------|-----------|----------|
| App Bar | Native AHK | Name, version, date display, gear icon → full Settings |
| Settings Bar | Native AHK | Storage (days), Key Width, Key Height, Font Size, Apply button, Theme click-to-cycle |
| Keyboard | WebBrowser HTML/CSS | 6 rows alphanumeric + nav cluster + arrows + numpad (6px rounded corners, hover tooltips, gradient heatmap) |
| Stats | WebBrowser HTML/CSS | 9 metric rows, 3 columns (Item / Today / Total), dark theme

### Theme System

5 themes (Blue, Red, Orange, Purple, Green) stored in `themes` object. Each defines:
- `bg` — background color
- `text` — text color
- `accent` — accent color (date display, gear icon)
- `key` — default key color (uncolored keys)
- `hs` — heatmap start color (low usage)
- `he` — heatmap end color (high usage)

Switch via tray menu → Theme. Saved to `KMCounter.ini [theme] name`.

## Controls

| Input | Action |
|-------|--------|
| PgUp / Wheel Up / Arrow Up | Next day |
| PgDn / Wheel Down / Arrow Down | Previous day |
| Esc | Hide window |
| Tray icon → Statistics | Show window, reset to today |
| Tray icon → Settings | Open full Settings panel |
| Tray icon → Theme | Switch color theme |
| Gear icon (⚙) | Open full Settings panel |
| Apply button (✓) | Apply Storage/KW/KH/FS changes and reload |
| Theme text (clickable) | Cycle to next color theme |

## Communication

| Direction | Method |
|-----------|--------|
| AHK → Browser | `WB.document.parentWindow.updateData(json)` — pushes key counts, stats, gradient colors |
| Browser → AHK | `document.title = 'n:X'` caught by `BrowserEvents_TitleChange` — handles nav commands, settings open |
| Settings (native) | `Gui, Submit` reads Edit fields, writes to INI, recreates GUI |

## Files

- `KMCounter.ahk` — main script (all logic in one file)
- `KMCounter.ini` — data store (created on first run)
- `KMCounter.exe` — compiled binary (no dependencies)
- `resouces/KMCounter.ico` — app icon

## Requirements

- Windows 7+ (compiled EXE, no dependencies)
- Or [AutoHotkey v1.1](https://www.autohotkey.com/) to run the script directly

## Privacy

This app is entirely offline. Nothing leaves your machine.

## License

MIT

---

*Originally by telppa. Hard fork — codebase has diverged significantly.*
