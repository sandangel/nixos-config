#!/bin/sh

active_workspace_id=$(hyprctl activeworkspace -j | jq -r '.id')
win_count=$(hyprctl activeworkspace -j | jq -r '.windows')
is_zoomed=$(hyprctl activeworkspace -j | jq -r '.hasfullscreen')
nvim_win_id=$(hyprctl clients -j | jq -r "first(.[] | select(.workspace.id == $active_workspace_id) | select(.class == \"neovide\")).address")
active_win_id=$(hyprctl activewindow -j | jq -r '.address')

if [[ "$active_win_id" == "$nvim_win_id" ]]; then
  if [[ $win_count -eq 1 ]]; then
    hyprctl dispatch -- exec "ghostty --window-inherit-working-directory"
  else
    if [[ "$is_zoomed" == "true" ]]; then
      hyprctl dispatch fullscreen 1
      hyprctl dispatch layoutmsg cyclenext
    else
      hyprctl dispatch fullscreen 1
    fi
  fi
elif [[ $win_count -gt 1 && "$active_win_id" != "$nvim_win_id" ]]; then
  hyprctl dispatch layoutmsg focusmaster
  hyprctl dispatch fullscreen 1
fi
