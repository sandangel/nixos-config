function nvim() {
  if [[ -z $HYPRLAND_INSTANCE_SIGNATURE ]]; then
    command nvim $@
    return 0
  fi

  workspace_id=$(hyprctl activeworkspace -j | jq -r '.id')
  nvim_addr=/tmp/nvim-hypr-$workspace_id
  window_id=$(hyprctl clients -j | jq -r "first(.[] | select(.workspace.id == $workspace_id) | select(.tags | index(\"nvim\"))).address")
  active_window_id=$(hyprctl activewindow -j | jq -r ".address")
  master_window_id=$(hyprctl clients -j | jq -r "[.[] | select (.workspace.id == $workspace_id)] | min_by(.at[1]) | .address")

  [[ ! $window_id && -e $nvim_addr ]] && rm -rf $nvim_addr

  if [[ $# -eq 0 && ! -e $nvim_addr  ]]; then
    [[ $master_window_id != $active_window_id ]] && hyprctl dispatch layoutmsg swapwithmaster
    hyprctl dispatch tagwindow +nvim activewindow >/dev/null 2>&1
    command nvim --listen $nvim_addr
    hyprctl dispatch -- tagwindow -nvim activewindow >/dev/null 2>&1
  elif [[ $# -eq 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
  elif [[ $# -gt 0 && ! -e $nvim_addr ]]; then
    [[ $master_window_id != $active_window_id ]] && hyprctl dispatch layoutmsg swapwithmaster
    hyprctl dispatch -- tagwindow +nvim activewindow >/dev/null 2>&1
    command nvim --listen $nvim_addr $@
    hyprctl dispatch tagwindow -nvim activewindow >/dev/null 2>&1
  elif [[ $# -gt 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
    command nvim --server $nvim_addr --remote $@
  else
    [[ $master_window_id != $active_window_id ]] && hyprctl dispatch layoutmsg swapwithmaster
    hyprctl dispatch tagwindow +nvim activewindow >/dev/null 2>&1
    command nvim --listen $nvim_addr
    hyprctl dispatch -- tagwindow -nvim activewindow >/dev/null 2>&1
  fi
}
