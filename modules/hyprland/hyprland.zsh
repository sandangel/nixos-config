function nvim() {
  if [[ -z $HYPRLAND_INSTANCE_SIGNATURE ]]; then
    command nvim $@
    return 0
  fi

  local nvim_addr=/tmp/nvim-hypr-$(hyprctl activeworkspace -j | jq -r '.id')
  window_id=$(hyprctl clients -j | jq -r 'first(.[] | select(.tags | index("nvim"))).address')

  [[ ! $window_id && -e $nvim_addr ]] && rm -rf $nvim_addr

  if [[ $# -eq 0 && ! -e $nvim_addr  ]]; then
    hyprctl dispatch tagwindow +nvim activewindow >/dev/null 2>&1
    command nvim --listen $nvim_addr
    hyprctl dispatch -- tagwindow -nvim activewindow >/dev/null 2>&1
  elif [[ $# -eq 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
  elif [[ $# -gt 0 && ! -e $nvim_addr ]]; then
    hyprctl dispatch -- tagwindow +nvim activewindow >/dev/null 2>&1
    command nvim --listen $nvim_addr $@
    hyprctl dispatch tagwindow -nvim activewindow >/dev/null 2>&1
  elif [[ $# -gt 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
    command nvim --server $nvim_addr --remote $@
  else
    hyprctl dispatch tagwindow +nvim activewindow >/dev/null 2>&1
    command nvim --listen $nvim_addr
    hyprctl dispatch -- tagwindow -nvim activewindow >/dev/null 2>&1
  fi
}
