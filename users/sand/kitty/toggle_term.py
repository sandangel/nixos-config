#!/usr/bin/env python3
# vim:fileencoding=utf-8

from kittens.tui.handler import result_handler
from kitty.boss import Boss


def main(_):
    pass


@result_handler(no_ui=True)
def handle_result(args, answer, target_window_id, boss: Boss):
    tab = boss.active_tab
    active_win = tab.active_window
    win_count = len(tab.windows)
    is_zoomed = tab.current_layout.name == "stack"

    nvim_win = None
    cwd = None

    for w in tab.windows:
        for p in w.child.foreground_processes:
            cmdline = p.get("cmdline")
            if len(cmdline) > 0:
                if "/bin/nvim" in cmdline[0]:
                    nvim_win = w
                    cwd = p.get("cwd")
                    break

    if nvim_win is not None:
        if active_win.id == nvim_win.id:
            if win_count == 1:
                tab.goto_layout("fat:bias=70")
                tab.new_window(cwd=cwd)
            else:
                if is_zoomed:
                    neighbor_win = list(filter(lambda wd: wd.id != nvim_win.id, tab.windows))[0]
                    tab.goto_layout("fat:bias=70")
                    tab.set_active_window(neighbor_win)
                else:
                    tab.goto_layout("stack")
        elif win_count > 1 and active_win.id != nvim_win.id:
            tab.set_active_window(nvim_win)
            tab.goto_layout("stack")
