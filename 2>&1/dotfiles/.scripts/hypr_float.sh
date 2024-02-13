#!/bin/bash
REGEX_CLASS='^(?!fcitx|Rofi$).+$'
REGEX_TITLE='^(?!fcitx|Rofi$).+$'
WORKSPACE=1
[[ -n $1 ]] && WORKSPACE=$1
hyprctl keyword windowrulev2 float , workspace:$WORKSPACE
hyprctl keyword windowrulev2 'maxsize 1800 1000, floating:1,workspace:'$WORKSPACE 
hyprctl keyword windowrulev2 'center,floating:1,class:'$REGEX_CLASS
hyprctl keyword windowrulev2 'maxsize 1800 1000, floating:1,class:'$REGEX_CLASS',title:'$REGEX_CLASS


