#!/bin/bash
# windows_addT=$(hyprctl -j clients | jq -r 'map(select((.workspace.id > 0) and (.title != "") and (.class != "")))|map({address,T:"\(.class): \(.initialTitle) , \(.title)"})|sort_by(.T|ascii_downcase)')

{
windows_addT=$(hyprctl -j clients | jq -r 'map(select((.workspace.id > 0) and (.title != "") and (.class != "")))|map({address,T:"\(.class): \(.initialTitle) , \(.title)"})|sort_by(.T|ascii_downcase)|to_entries|map({id:.key,address:.value.address,T:.value.T})')
theme=$HOME/.config/rofi/launchers/type-1/style-5.rasi
id=$(echo "$windows_addT" |jq -r 'map("\(.id):\(.T)")|.[]' |\
		rofi -dmenu \
		-matching regex\
		-i -theme "$theme" \
		| cut -d ':' -f 1 )
echo $!
hyprctl dispatch focuswindow address:"$(echo "$windows_addT" | jq -r 'map(select(.id=='"$id"'))|.[].address')"
}&
"$HOME"/.scripts/close_rofi_while_not_focus.sh $!


