#!/bin/sh

active_workspace_id=$(niri msg -j focused-window | jq -r '.workspace_id')
win_count=$(niri msg -j windows | jq -r "map(select(.workspace_id == $active_workspace_id)) | length")
is_zoomed=$(niri msg -j windows | jq -r "any(.[] | select(.workspace_id == $active_workspace_id); .layout.window_size[0] > 2000)")
nvim_win_id=$(niri msg -j windows | jq -r "first(.[] | select(.workspace_id == $active_workspace_id) | select(.app_id == \"neovide\")).id")
active_win_id=$(niri msg -j focused-window | jq -r '.id')

if [[ "$active_win_id" == "$nvim_win_id" ]]; then
  if [[ $win_count -eq 1 ]]; then
    pid=$(niri msg -j focused-window | jq -r '.pid')
    dir=$(readlink /proc/"$pid"/cwd || echo "$HOME")
    niri msg action spawn-sh -- "alacritty --working-directory $dir"
  else
    if [[ "$is_zoomed" == "true" ]]; then
      niri msg action maximize-column
      niri msg action focus-column-right
    else
      niri msg action maximize-column
    fi
  fi
elif [[ $win_count -gt 1 && "$active_win_id" != "$nvim_win_id" ]]; then
  niri msg action focus-window --id $nvim_win_id
  niri msg action maximize-column
fi
