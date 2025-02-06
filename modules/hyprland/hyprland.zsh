function nvim() {
  if [[ -z $HYPRLAND_INSTANCE_SIGNATURE ]]; then
    command nvim $@
    return 0
  fi

  workspace_id=$(hyprctl activeworkspace -j | jq -r '.id')
  nvim_addr=/tmp/nvim-hypr-$workspace_id
  neovide_window_id=$(hyprctl clients -j | jq -r "first(.[] | select(.workspace.id == $workspace_id) | select(.class == \"neovide\")).address")

  [[ ! $neovide_window_id && -e $nvim_addr ]] && rm -rf $nvim_addr

  if [[ $# -eq 0 && ! -e $nvim_addr  ]]; then
    command nvim --listen $nvim_addr --headless > /dev/null 2>&1 0< /dev/null &!
    command neovide --server $nvim_addr
  elif [[ $# -eq 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
  elif [[ $# -gt 0 && ! -e $nvim_addr ]]; then
    command nvim --listen $nvim_addr --headless > /dev/null 2>&1 0< /dev/null &!
    command neovide --server $nvim_addr
  elif [[ $# -gt 0 && -e $nvim_addr ]]; then
    hyprctl dispatch layoutmsg focusmaster >/dev/null 2>&1
    command nvim --server $nvim_addr --remote $@
  else
    command nvim --listen $nvim_addr --headless > /dev/null 2>&1 0< /dev/null &!
    command neovide --server $nvim_addr
  fi
}
