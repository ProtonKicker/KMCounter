import random
import time
import tkinter as tk
from tkinter import messagebox, ttk
from typing import Dict, List, Optional


def _try_use_vista_theme(root: tk.Tk) -> None:
    try:
        style = ttk.Style(root)
        if "vista" in style.theme_names():
            style.theme_use("vista")
    except tk.TclError:
        return


class Minesweeper(tk.Frame):
    def __init__(
        self,
        master: tk.Misc,
        rows: int = 9,
        cols: int = 9,
        mines: int = 10,
    ) -> None:
        super().__init__(master)
        self.rows = rows
        self.cols = cols
        self.mines = mines

        self._started = False
        self._game_over = False
        self._start_ts: Optional[float] = None
        self._timer_job: Optional[str] = None
        self._revealed_count = 0
        self._flags = 0

        self._mine_map: List[List[bool]] = [[False for _ in range(cols)] for _ in range(rows)]
        self._revealed: List[List[bool]] = [[False for _ in range(cols)] for _ in range(rows)]
        self._flagged: List[List[bool]] = [[False for _ in range(cols)] for _ in range(rows)]
        self._adj: List[List[int]] = [[0 for _ in range(cols)] for _ in range(rows)]

        header = ttk.Frame(self)
        header.pack(side=tk.TOP, fill=tk.X, padx=10, pady=(10, 6))

        self.mine_var = tk.StringVar(value=f"Mines: {self.mines:03d}")
        self.time_var = tk.StringVar(value="Time: 000")

        self.mine_label = ttk.Label(header, textvariable=self.mine_var, font=("Segoe UI", 10, "bold"))
        self.mine_label.pack(side=tk.LEFT)

        self.reset_btn = ttk.Button(header, text="New Game", command=self.reset)
        self.reset_btn.pack(side=tk.LEFT, padx=12)

        self.time_label = ttk.Label(header, textvariable=self.time_var, font=("Segoe UI", 10, "bold"))
        self.time_label.pack(side=tk.RIGHT)

        board_outer = ttk.Frame(self)
        board_outer.pack(side=tk.TOP, padx=10, pady=(0, 10))

        self.board = tk.Frame(board_outer, bg="#9aa7b0", bd=1, relief=tk.SUNKEN)
        self.board.pack()

        self._buttons: List[List[tk.Button]] = []
        for r in range(rows):
            row_buttons: List[tk.Button] = []
            for c in range(cols):
                btn = tk.Button(
                    self.board,
                    width=2,
                    height=1,
                    font=("Segoe UI", 10, "bold"),
                    relief=tk.RAISED,
                    bd=1,
                    bg="#e6eef6",
                    activebackground="#d6e5f2",
                    highlightthickness=0,
                )
                btn.grid(row=r, column=c, padx=0, pady=0, sticky="nsew")
                btn.bind("<Button-1>", lambda e, rr=r, cc=c: self._on_left(rr, cc))
                btn.bind("<Button-3>", lambda e, rr=r, cc=c: self._on_right(rr, cc))
                btn.bind("<Button-2>", lambda e, rr=r, cc=c: self._on_right(rr, cc))
                row_buttons.append(btn)
            self._buttons.append(row_buttons)

        for c in range(cols):
            self.board.grid_columnconfigure(c, weight=1)
        for r in range(rows):
            self.board.grid_rowconfigure(r, weight=1)

        footer = ttk.Frame(self)
        footer.pack(side=tk.TOP, fill=tk.X, padx=10, pady=(0, 10))

        self.status_var = tk.StringVar(value="Left-click to reveal. Right-click to flag.")
        self.status = ttk.Label(footer, textvariable=self.status_var)
        self.status.pack(side=tk.LEFT)

        self.reset()

    def reset(self) -> None:
        if self._timer_job is not None:
            try:
                self.after_cancel(self._timer_job)
            except tk.TclError:
                pass
            self._timer_job = None

        self._started = False
        self._game_over = False
        self._start_ts = None
        self._revealed_count = 0
        self._flags = 0

        self._mine_map = [[False for _ in range(self.cols)] for _ in range(self.rows)]
        self._revealed = [[False for _ in range(self.cols)] for _ in range(self.rows)]
        self._flagged = [[False for _ in range(self.cols)] for _ in range(self.rows)]
        self._adj = [[0 for _ in range(self.cols)] for _ in range(self.rows)]

        for r in range(self.rows):
            for c in range(self.cols):
                b = self._buttons[r][c]
                b.config(text="", state=tk.NORMAL, relief=tk.RAISED, bg="#e6eef6", fg="#1b1b1b")

        self.mine_var.set(f"Mines: {self.mines:03d}")
        self.time_var.set("Time: 000")
        self.status_var.set("Left-click to reveal. Right-click to flag.")

    def _place_mines(self, safe_r: int, safe_c: int) -> None:
        positions = [(r, c) for r in range(self.rows) for c in range(self.cols) if (r, c) != (safe_r, safe_c)]
        random.shuffle(positions)
        for r, c in positions[: self.mines]:
            self._mine_map[r][c] = True

        for r in range(self.rows):
            for c in range(self.cols):
                self._adj[r][c] = self._count_adjacent(r, c)

    def _count_adjacent(self, r: int, c: int) -> int:
        if self._mine_map[r][c]:
            return 0
        cnt = 0
        for rr in range(max(0, r - 1), min(self.rows, r + 2)):
            for cc in range(max(0, c - 1), min(self.cols, c + 2)):
                if (rr, cc) != (r, c) and self._mine_map[rr][cc]:
                    cnt += 1
        return cnt

    def _on_left(self, r: int, c: int) -> None:
        if self._game_over:
            return
        if self._flagged[r][c]:
            return
        if not self._started:
            self._started = True
            self._place_mines(r, c)
            self._start_ts = time.time()
            self._tick_timer()

        if self._revealed[r][c]:
            return

        if self._mine_map[r][c]:
            self._lose(r, c)
            return

        self._reveal(r, c)
        self._check_win()

    def _on_right(self, r: int, c: int) -> None:
        if self._game_over:
            return
        if self._revealed[r][c]:
            return

        self._flagged[r][c] = not self._flagged[r][c]
        if self._flagged[r][c]:
            self._flags += 1
            self._buttons[r][c].config(text="⚑", fg="#b10000")
        else:
            self._flags -= 1
            self._buttons[r][c].config(text="", fg="#1b1b1b")

        remaining = max(0, self.mines - self._flags)
        self.mine_var.set(f"Mines: {remaining:03d}")

    def _reveal(self, r: int, c: int) -> None:
        stack = [(r, c)]
        while stack:
            rr, cc = stack.pop()
            if self._revealed[rr][cc] or self._flagged[rr][cc]:
                continue
            self._revealed[rr][cc] = True
            self._revealed_count += 1

            b = self._buttons[rr][cc]
            b.config(relief=tk.SUNKEN, bg="#f6fbff", activebackground="#f6fbff")
            b.config(state=tk.DISABLED)

            n = self._adj[rr][cc]
            if n > 0:
                b.config(text=str(n), fg=self._num_color(n))
            else:
                b.config(text="")
                for nr in range(max(0, rr - 1), min(self.rows, rr + 2)):
                    for nc in range(max(0, cc - 1), min(self.cols, cc + 2)):
                        if (nr, nc) != (rr, cc) and not self._revealed[nr][nc]:
                            if not self._mine_map[nr][nc]:
                                stack.append((nr, nc))

    def _num_color(self, n: int) -> str:
        return {
            1: "#1f4aa8",
            2: "#1a7f2e",
            3: "#b10000",
            4: "#000080",
            5: "#800000",
            6: "#008080",
            7: "#2b2b2b",
            8: "#6b6b6b",
        }.get(n, "#1b1b1b")

    def _lose(self, r: int, c: int) -> None:
        self._game_over = True
        if self._timer_job is not None:
            try:
                self.after_cancel(self._timer_job)
            except tk.TclError:
                pass
            self._timer_job = None

        for rr in range(self.rows):
            for cc in range(self.cols):
                b = self._buttons[rr][cc]
                if self._mine_map[rr][cc]:
                    b.config(text="✹", fg="#1b1b1b", bg="#f3d3d3")
                b.config(state=tk.DISABLED)

        hit = self._buttons[r][c]
        hit.config(bg="#e36b6b")

        self.status_var.set("Boom! You hit a mine.")
        messagebox.showinfo("Minesweeper", "Boom! You hit a mine.")

    def _check_win(self) -> None:
        safe_cells = self.rows * self.cols - self.mines
        if self._revealed_count >= safe_cells and not self._game_over:
            self._game_over = True
            if self._timer_job is not None:
                try:
                    self.after_cancel(self._timer_job)
                except tk.TclError:
                    pass
                self._timer_job = None

            for rr in range(self.rows):
                for cc in range(self.cols):
                    self._buttons[rr][cc].config(state=tk.DISABLED)

            self.status_var.set("You win!")
            messagebox.showinfo("Minesweeper", "You win!")

    def _tick_timer(self) -> None:
        if not self._started or self._game_over or self._start_ts is None:
            return
        elapsed = int(time.time() - self._start_ts)
        elapsed = max(0, min(999, elapsed))
        self.time_var.set(f"Time: {elapsed:03d}")
        self._timer_job = self.after(1000, self._tick_timer)


class VistaWindow(ttk.Frame):
    def __init__(self, master: tk.Misc) -> None:
        super().__init__(master)
        self.pack(fill=tk.BOTH, expand=True)

        self.header = ttk.Frame(self)
        self.header.pack(fill=tk.X)

        self.title_var = tk.StringVar(value="")
        self.title = ttk.Label(self.header, textvariable=self.title_var, font=("Segoe UI", 11, "bold"))
        self.title.pack(side=tk.LEFT, padx=10, pady=8)

        self.body = ttk.Frame(self)
        self.body.pack(fill=tk.BOTH, expand=True)

    def set_title(self, text: str) -> None:
        self.title_var.set(text)


class VistaDesktop(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("Windows Vista")
        self.geometry("1100x700")

        _try_use_vista_theme(self)

        self.bind("<Escape>", lambda e: self._toggle_fullscreen(False))
        self.bind("<F11>", lambda e: self._toggle_fullscreen(not bool(self.attributes("-fullscreen"))))

        self._start_menu: Optional[tk.Toplevel] = None
        self._open_windows: Dict[str, tk.Toplevel] = {}

        self.desktop = tk.Canvas(self, highlightthickness=0)
        self.desktop.pack(fill=tk.BOTH, expand=True)

        self.taskbar = ttk.Frame(self)
        self.taskbar.place(relx=0, rely=1, relwidth=1, anchor="sw")

        self._layout_taskbar()
        self._layout_desktop()
        self._redraw_wallpaper()

        self.bind("<Configure>", lambda e: self.after_idle(self._redraw_wallpaper))

    def _toggle_fullscreen(self, enabled: bool) -> None:
        try:
            self.attributes("-fullscreen", enabled)
        except tk.TclError:
            return

    def _layout_taskbar(self) -> None:
        self.taskbar.configure(padding=(8, 6))

        self.start_btn = ttk.Button(self.taskbar, text="Start", command=self._toggle_start_menu)
        self.start_btn.pack(side=tk.LEFT)

        self.quick = ttk.Frame(self.taskbar)
        self.quick.pack(side=tk.LEFT, padx=10)

        ttk.Button(self.quick, text="Minesweeper", command=self.open_minesweeper).pack(side=tk.LEFT)
        ttk.Button(self.quick, text="Paint", command=lambda: self._show_info("Paint", "Paint isn't installed in this mini-Vista."))
        ttk.Button(self.quick, text="Notepad", command=lambda: self._show_info("Notepad", "Notepad isn't installed in this mini-Vista."))

        self.window_strip = ttk.Frame(self.taskbar)
        self.window_strip.pack(side=tk.LEFT, padx=10, fill=tk.X, expand=True)

        self.clock_var = tk.StringVar(value="")
        self.clock = ttk.Label(self.taskbar, textvariable=self.clock_var, font=("Segoe UI", 9))
        self.clock.pack(side=tk.RIGHT)
        self._tick_clock()

    def _layout_desktop(self) -> None:
        self._make_icon(40, 40, "Minesweeper", self.open_minesweeper)
        self._make_icon(40, 120, "Recycle Bin", lambda: self._show_info("Recycle Bin", "The bin is empty."))
        self._make_icon(40, 200, "Computer", lambda: self._show_info("Computer", "Nothing to see here."))

        hint = "Mini Windows Vista Desktop\nOpen Minesweeper to play\nF11 fullscreen • Esc exit fullscreen"
        self.desktop.create_text(240, 60, text=hint, fill="#ffffff", font=("Segoe UI", 12, "bold"), anchor="nw")
        self.desktop.create_text(242, 62, text=hint, fill="#233a4f", font=("Segoe UI", 12, "bold"), anchor="nw")

    def _make_icon(self, x: int, y: int, label: str, command) -> None:
        icon = ttk.Frame(self.desktop)
        btn = ttk.Button(icon, text=label, command=command)
        btn.pack()
        self.desktop.create_window(x, y, window=icon, anchor="nw")

    def _redraw_wallpaper(self) -> None:
        w = max(1, self.winfo_width())
        h = max(1, self.winfo_height())
        tb_h = self.taskbar.winfo_reqheight() + 6
        self.desktop.delete("wall")

        top = (30, 90, 140)
        bottom = (10, 30, 60)
        steps = 48
        usable_h = max(1, h - tb_h)
        for i in range(steps):
            t = i / max(1, steps - 1)
            r = int(top[0] + (bottom[0] - top[0]) * t)
            g = int(top[1] + (bottom[1] - top[1]) * t)
            b = int(top[2] + (bottom[2] - top[2]) * t)
            y0 = int((usable_h * i) / steps)
            y1 = int((usable_h * (i + 1)) / steps)
            self.desktop.create_rectangle(0, y0, w, y1, outline="", fill=f"#{r:02x}{g:02x}{b:02x}", tags="wall")

        glow_x, glow_y = int(w * 0.62), int(usable_h * 0.30)
        for radius, alpha in [(220, 0.08), (160, 0.10), (110, 0.12), (70, 0.15)]:
            col = self._blend("#9ad1ff", "#000000", 1 - alpha)
            self.desktop.create_oval(
                glow_x - radius,
                glow_y - radius,
                glow_x + radius,
                glow_y + radius,
                outline="",
                fill=col,
                tags="wall",
            )

    def _blend(self, fg: str, bg: str, amount: float) -> str:
        amount = max(0.0, min(1.0, amount))
        fr, fg_g, fb = int(fg[1:3], 16), int(fg[3:5], 16), int(fg[5:7], 16)
        br, bg_g, bb = int(bg[1:3], 16), int(bg[3:5], 16), int(bg[5:7], 16)
        r = int(br + (fr - br) * amount)
        g = int(bg_g + (fg_g - bg_g) * amount)
        b = int(bb + (fb - bb) * amount)
        return f"#{r:02x}{g:02x}{b:02x}"

    def _tick_clock(self) -> None:
        self.clock_var.set(time.strftime("%I:%M %p").lstrip("0"))
        self.after(1000, self._tick_clock)

    def _toggle_start_menu(self) -> None:
        if self._start_menu is not None and self._start_menu.winfo_exists():
            self._start_menu.destroy()
            self._start_menu = None
            return

        menu = tk.Toplevel(self)
        self._start_menu = menu
        menu.overrideredirect(True)
        menu.attributes("-topmost", True)

        try:
            menu.wm_attributes("-transparentcolor", "#ff00ff")
        except tk.TclError:
            pass

        frame = ttk.Frame(menu, padding=10)
        frame.pack(fill=tk.BOTH, expand=True)

        ttk.Label(frame, text="Programs", font=("Segoe UI", 11, "bold")).pack(anchor="w", pady=(0, 6))
        ttk.Button(frame, text="Minesweeper", command=lambda: (self.open_minesweeper(), self._toggle_start_menu())).pack(
            fill=tk.X
        )
        ttk.Button(frame, text="Control Panel", command=lambda: self._show_info("Control Panel", "Not available.")).pack(
            fill=tk.X, pady=4
        )
        ttk.Button(frame, text="Shut Down", command=self.destroy).pack(fill=tk.X)

        menu.update_idletasks()
        x = self.start_btn.winfo_rootx()
        y = self.start_btn.winfo_rooty() - menu.winfo_reqheight() - 6
        menu.geometry(f"260x160+{x}+{y}")
        menu.bind("<FocusOut>", lambda e: self._toggle_start_menu())
        menu.focus_force()

    def _show_info(self, title: str, message: str) -> None:
        messagebox.showinfo(title, message)

    def _register_window(self, key: str, win: tk.Toplevel) -> None:
        self._open_windows[key] = win
        self._refresh_window_strip()
        win.bind("<Destroy>", lambda e: self._on_window_destroyed(key))

    def _on_window_destroyed(self, key: str) -> None:
        if key in self._open_windows:
            self._open_windows.pop(key, None)
            self._refresh_window_strip()

    def _refresh_window_strip(self) -> None:
        for child in list(self.window_strip.winfo_children()):
            child.destroy()
        for key, win in self._open_windows.items():
            if not win.winfo_exists():
                continue
            ttk.Button(
                self.window_strip,
                text=win.title() or key,
                command=lambda w=win: (w.deiconify(), w.lift(), w.focus_force()),
            ).pack(side=tk.LEFT, padx=3)

    def open_minesweeper(self) -> None:
        key = "minesweeper"
        existing = self._open_windows.get(key)
        if existing is not None and existing.winfo_exists():
            existing.deiconify()
            existing.lift()
            existing.focus_force()
            return

        win = tk.Toplevel(self)
        win.title("Minesweeper")
        win.geometry("420x520")
        _try_use_vista_theme(win)

        container = VistaWindow(win)
        container.set_title("Minesweeper")

        difficulty = ttk.Frame(container.body)
        difficulty.pack(fill=tk.X, padx=10, pady=(10, 0))

        ttk.Label(difficulty, text="Difficulty:").pack(side=tk.LEFT)
        diff_var = tk.StringVar(value="Beginner")
        diff_box = ttk.Combobox(difficulty, state="readonly", values=["Beginner", "Intermediate", "Expert"], textvariable=diff_var)
        diff_box.pack(side=tk.LEFT, padx=8)

        game_host = ttk.Frame(container.body)
        game_host.pack(fill=tk.BOTH, expand=True)

        game = Minesweeper(game_host, rows=9, cols=9, mines=10)
        game.pack(fill=tk.BOTH, expand=True)

        def apply_diff(_: Optional[object] = None) -> None:
            choice = diff_var.get()
            if choice == "Beginner":
                r, c, m = 9, 9, 10
                win.geometry("420x520")
            elif choice == "Intermediate":
                r, c, m = 16, 16, 40
                win.geometry("640x740")
            else:
                r, c, m = 16, 30, 99
                win.geometry("980x740")

            for child in list(game_host.winfo_children()):
                child.destroy()
            new_game = Minesweeper(game_host, rows=r, cols=c, mines=m)
            new_game.pack(fill=tk.BOTH, expand=True)

        diff_box.bind("<<ComboboxSelected>>", apply_diff)

        self._register_window(key, win)
        win.focus_force()


def main() -> int:
    app = VistaDesktop()
    app.mainloop()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

