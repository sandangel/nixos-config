#!/bin/sh

dir="$1"
NVIM_ADDR="/tmp/nvim-hypr-$(hyprctl activeworkspace -j | jq -r ".id")"

case "$dir" in
    u) ;;
    r) ;;
    d) ;;
    l) ;;
    *)
        echo "USAGE: $0 u|r|d|l"
        exit 1
esac

if [[ -e "$NVIM_ADDR" && "$(hyprctl activewindow -j | jq -r '.class')" == "neovide" ]]; then
  command nvim --server $NVIM_ADDR --remote-send "<cmd>HyprNavigate $dir<CR>" >/dev/null 2>&1 && exit 0
fi

hyprctl dispatch movefocus "$dir"
