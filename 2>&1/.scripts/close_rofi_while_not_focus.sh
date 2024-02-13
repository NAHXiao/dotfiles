#!/bin/bash 
sleep 0.5
[[ -z $1 ]] && set -- "$(pgrep -nx rofi)"
[[ -z $1 ]] &&	echo "no rofi process found" && exit 1
echo $1
while kill -0 "$1" 2>/dev/null; do 
[[ $(hyprctl activewindow -j | jq  -r .class) != "Rofi" ]] && killall rofi
sleep 0.1
done
