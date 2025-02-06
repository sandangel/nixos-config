#!/bin/sh

pid=$(hyprctl activewindow -j | jq '.pid')
cmdline=$(cat /proc/${pid}/cmdline | xargs -0 echo)

# change to if the cmdline not including zsh
if [[ "$cmdline" != *"zsh"* ]]; then
  dir=$(readlink /proc/"$pid"/cwd || echo "$HOME")
else
  ppid=$(pgrep --newest --parent "$pid")
  dir=$(readlink /proc/"$ppid"/cwd || echo "$HOME")
fi

[ -d "$dir" ] && echo "$dir" || echo "$HOME"
