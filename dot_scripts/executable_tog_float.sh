#!/bin/bash
DIR=/tmp/"$(whoami)"/"${WAYLAND_DISPLAY}"/workspace
WS=$(hyprctl activeworkspace -j|jq .id)
REGEX_CLASS='^(?!fcitx|Rofi$).+$'
REGEX_TITLE='^(?!fcitx|Rofi$).+$'
mkdir -v $DIR
if [[ $(cat $DIR/$WS 2>/dev/null) == 1 ]];then
hyprctl keyword windowrulev2 tile,workspace:$WS,title:"$REGEX_TITLE",class:$REGEX_CLASS
echo 0 >$DIR/$WS
else
hyprctl keyword windowrulev2 float , workspace:$WS
hyprctl keyword windowrulev2 'maxsize 1800 1000, floating:1,workspace:'$WS 
hyprctl keyword windowrulev2 'center,floating:1,class:'$REGEX_CLASS
hyprctl keyword windowrulev2 'maxsize 1800 1000, floating:1,class:'$REGEX_CLASS',title:'$REGEX_CLASS
echo 1 >$DIR/$WS
fi
