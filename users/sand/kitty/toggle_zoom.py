#!/usr/bin/env python3
# vim:fileencoding=utf-8

def main():
    pass

def handle_result(args, result, target_window_id, boss):
    tab = boss.active_tab
    if tab is not None:
        if tab.current_layout.name == 'stack':
            tab.last_used_layout()
        else:
            tab.goto_layout('stack')


handle_result.no_ui = True
