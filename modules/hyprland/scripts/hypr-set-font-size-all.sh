#!/bin/sh

active_workspace_id=$(hyprctl activeworkspace -j | jq -r '.id')
initialClass="com.mitchellh.ghostty"
win_ids=$(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $active_workspace_id) | select(.initialClass == \"$initialClass\") | .address")
#
for win_id in $win_ids; do
  hyprctl dispatch pass "address:$win_id"
done
