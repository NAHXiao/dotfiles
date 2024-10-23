#!/bin/bash
REGEX_CLASS='^(?!rofi|fcitx$).+$'
REGEX_TITLE='^(?!rofi|fcitx$).+$'
WORKSPACE=1
[[ -n $1 ]] && WORKSPACE=$1
hyprctl keyword windowrulev2 tile,workspace:$WORKSPACE,title:"$REGEX_TITLE",class:$REGEX_CLASS
# hyprctl keyword windowrulev2  maxsize 1800 1000, workspace:$WORKSPACE
# hyprctl keyword windowrulev2  maxsize 1800 1000, floating:1
# hyprctl keyword windowrulev2 'center,workspace:'$WORKSPACE',floating:1,class:'$REGEX_CLASS
# hyprctl keyword windowrulev2 'center,floating:1,class:'$REGEX_CLASS
# hyprctl keyword windowrulev2 'maxsize 1800 1000, floating:1,class:'$REGEX_CLASS',title:'$REGEX_CLASS
# hyprctl keyword windowrulev2 minsize '1000 600, floating:1,class:'$REGEX_CLASS',title:'$REGEX_TITLE

