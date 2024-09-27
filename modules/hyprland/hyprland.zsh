function nvim() {
  local nvim_addr=/tmp/nvim-hypr-$(hyprctl activeworkspace -j | jq -r '.id')

  if [[ $# -eq 0 && ! -e $nvim_addr  ]]; then
    hyprctl dispatch tagwindow +nvim activewindow
    command nvim --listen $nvim_addr
    hyprctl dispatch tagwindow -nvim activewindow
  elif [[ $# -eq 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster
  elif [[ $# -gt 0 && ! -e $nvim_addr ]]; then
    hyprctl dispatch tagwindow +nvim activewindow
    command nvim --listen $nvim_addr $@
    hyprctl dispatch tagwindow -nvim activewindow
  elif [[ $# -gt 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster
    command nvim --server $nvim_addr --remote $@
  else
    hyprctl dispatch tagwindow +nvim activewindow
    command nvim --listen $nvim_addr
    hyprctl dispatch tagwindow -nvim activewindow
  fi
}
