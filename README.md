# KMCounter

**Turn your typing data into ergonomic insights.**

KMCounter is a keyboard & mouse usage tracker with a live heatmap overlay. It logs every keystroke and click, then visualizes your patterns directly on a rendered keyboard.

## Architecture

```
┌──────────────────────────────────────────────────────┐
│                    Main Window                        │
│  ┌────────────────────────────────────────────────┐  │
│  │  App Bar: Name │ Ver │ Date │ ⚙               │  │
│  │  Settings: Storage │ KW │ KH │ FS │ [Apply ✓] │  │
│  ├────────────────────────────────────────────────┤  │
│  │                                                │  │
│  │              Keyboard (6 rows)                 │  │
│  │         + nav cluster + arrows + numpad        │  │
│  │        (rounded Text controls, 6px radius)     │  │
│  │                                                │  │
│  ├────────────────────────────────────────────────┤  │
│  │  Stats ListView: Item │ Today │ Total           │  │
│  │  9 rows (mouse movement, clicks, scrolls, ...)  │  │
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
4. **ShowHeatMap** reads the current `date`'s data, computes a gradient from `highlightStart` to `highlightEnd` (100 steps), and colors each key proportionally via `ChangeControlColor` + `WM_CTLCOLORSTATIC`.
5. **Stats ListView** shows 9 metric rows (mouse movement, keyboard clicks, left/right/middle clicks, wheel scrolls, wheel tilt, side clicks, screen size) with Today and Total columns.
6. **Settings Bar** (top of window) allows live adjustment of Storage Days, Key Width, Key Height, and Font Size — Apply triggers a reload.
7. **History navigation**: PgUp/PgDn/Arrows/Wheel scroll through past days. The `LoadData()` function cycles through stored INI sections, or resets to "Total" / "Today".

### Window Layout (top to bottom)

| Section | Height | Contents |
|---------|--------|----------|
| App Bar | ~28px | Name, version, date display, gear icon → full Settings |
| Settings Bar | ~24px | Storage (days), Key Width, Key Height, Font Size, Apply button |
| Keyboard | auto | 6 rows alphanumeric + nav cluster + arrows + numpad (all rounded Text controls) |
| Stats | ~220px | ListView, 9 rows, 3 columns (Item / Today / Total) |

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
