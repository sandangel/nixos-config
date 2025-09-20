#!/bin/sh

pid=$(niri msg -j focused-window | jq -r '.pid')
cmdline=""
if [[ "$pid" != "null" ]]; then
  cmdline=$(cat /proc/${pid}/cmdline | xargs -0 echo)
fi

# change to if the cmdline not including ghostty
if [[ "$cmdline" != *"alacritty"* ]]; then
  dir=$(readlink /proc/"$pid"/cwd || echo "$HOME")
else
  ppid=$(pgrep --newest --parent "$pid")
  dir=$(readlink /proc/"$ppid"/cwd || echo "$HOME")
fi

[ -d "$dir" ] && cd $dir

zsh
