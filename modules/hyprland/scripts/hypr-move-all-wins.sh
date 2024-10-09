#!/bin/sh

workspace_id=$(hyprctl activeworkspace -j | jq -r '.id')
master_window_id=$(hyprctl clients -j | jq -r "[.[] | select (.workspace.id == $workspace_id)] | min_by(.at[1]) | .address")
if [ -n "$master_window_id" ]; then
  hyprctl dispatch -- movetoworkspacesilent $1,address:$master_window_id
fi
for i in $(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $workspace_id) | .address"); do
  hyprctl dispatch -- movetoworkspacesilent $1,address:$i
done
hyprctl dispatch -- workspace $1

