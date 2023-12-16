#!/bin/bash

if [[ $1 == '-c' ]];then
sudo su -c "
chattr -R -i $HOME/.config/hypr
chattr -R -i $HOME/.config/kitty
chattr -R -i $HOME/.config/wezterm
chattr -R -i $HOME/.config/zsh
chattr -R -i $HOME/.config/rofi
chattr -R -i $HOME/.config/waybar
"
else
sudo su -c "
chattr -R +i $HOME/.config/hypr
chattr -R +i $HOME/.config/kitty
chattr -R +i $HOME/.config/wezterm
chattr -R +i $HOME/.config/zsh
chattr -R +i $HOME/.config/rofi
chattr -R +i $HOME/.config/waybar
"
fi
