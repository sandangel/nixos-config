function nvim() {
  if [[ -z $NIRI_SOCKET ]]; then
    command nvim $@
    return 0
  fi

  workspace_id=$(niri msg -j focused-window | jq -r '.workspace_id')
  nvim_addr=/tmp/nvim-niri-$workspace_id
  neovide_window_id=$(niri msg -j windows | jq -r "first(.[] | select(.workspace_id == $workspace_id) | select(.app_id == \"neovide\")).id")

  [[ ! $neovide_window_id && -e $nvim_addr ]] && rm -rf $nvim_addr

  if [[ $# -eq 0 && ! -e $nvim_addr  ]]; then
    command nvim --listen $nvim_addr --headless > /dev/null 2>&1 0< /dev/null &!
    command neovide --server $nvim_addr
  elif [[ $# -eq 0 && -e $nvim_addr ]]; then
    niri msg action focus-window --id $neovide_window_id >/dev/null 2>&1
  elif [[ $# -gt 0 && ! -e $nvim_addr ]]; then
    command nvim --listen $nvim_addr --headless > /dev/null 2>&1 0< /dev/null &!
    command neovide --server $nvim_addr
  elif [[ $# -gt 0 && -e $nvim_addr ]]; then
    niri msg action focus-window --id $neovide_window_id >/dev/null 2>&1
    command nvim --server $nvim_addr --remote $@
  else
    command nvim --listen $nvim_addr --headless > /dev/null 2>&1 0< /dev/null &!
    command neovide --server $nvim_addr
  fi
}

