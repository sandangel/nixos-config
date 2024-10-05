#!/usr/bin/env sh

insert() {
  value=$(cat)
  if [ -z "$value" ]; then
    exit 0
  fi

  wValue=$(wl-paste -n 2>/dev/null || echo "")
  xValue=$(xclip -o -selection clipboard 2>/dev/null || echo "")

  if [ "$value" != "$wValue" ]; then
    echo -n "$value" | wl-copy
  fi

  if [ "$value" != "$xValue" ]; then
    echo -n "$value" | xclip -i -selection clipboard
  fi
}

# Watch for clipboard changes and synchronize between Wayland and X11
# Usage: clipsync watch
watch() {
  # Add a small delay to ensure clipboard services are initialized
  sleep 1

  # Wayland -> X11
  wl-paste --type text --watch bash -c "clipsync insert" &

  # X11 -> Wayland
  while clipnotify; do
    xclip -o -selection clipboard 2>/dev/null | clipsync insert
  done &
}

# Kill all background processes related to clipsync
stop() {
  pkill -f "wl-paste --type text --watch"
  pkill clipnotify
  pkill -f "xclip -selection clipboard"
  pkill -f "clipsync insert"
}

help() {
  cat << EOF
clipsync - Two-way clipboard synchronization between Wayland and X11, with clipse support

Usage:
  clipsync watch
    Run clipboard synchronization in the background.

  clipsync stop
    Stop all background processes related to clipsync.

  echo -n "text" | clipsync insert
    Insert clipboard content from stdin.

  clipsync help
    Display this help information.

Requirements: wl-clipboard, xclip, clipnotify
EOF
}

case "$1" in
  watch)
    watch
    ;;
  stop)
    stop
    ;;
  insert)
    insert
    ;;
  help)
    help
    ;;
  *)
    echo "Usage: $0 {watch|insert|stop|help}"
    echo "Run '$0 help' for more information."
    exit 1
    ;;
esac
