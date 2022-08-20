#!/usr/bin/env python3
# vim:fileencoding=utf-8

from kittens.tui.handler import result_handler
from kitty.boss import Boss


def main(_):
    pass


@result_handler(no_ui=True)
def handle_result(boss: Boss):
    tab = boss.active_tab
    if tab is not None:
        if tab.current_layout.name == "stack":
            tab.last_used_layout()
        else:
            tab.goto_layout("stack")
