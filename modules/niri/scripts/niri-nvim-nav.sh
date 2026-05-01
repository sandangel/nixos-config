#!/bin/sh

dir="$1"
NVIM_ADDR="/tmp/nvim-niri-$(niri msg -j focused-window | jq -r ".workspace_id")"

case "$dir" in
    "window-up") ;;
    "column-right") ;;
    "window-down") ;;
    "column-left") ;;
    *)
        echo "USAGE: $0 window-up|column-right|window-down|column-left"
        exit 1
esac

if [[ -e "$NVIM_ADDR" ]] && [[ "$(niri msg -j focused-window | jq -r '.app_id')" == "neovide" ]]; then
  command nvim --server $NVIM_ADDR --remote-send "<cmd>NiriNavigate $dir<CR>" >/dev/null 2>&1 && exit 0
fi

niri msg action focus-$dir
