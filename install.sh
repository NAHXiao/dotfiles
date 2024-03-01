#!/bin/bash 

for configdir in $(ls dotfiles/.config) ;do
    echo delete ~/.config/${configdir} and link ./dotfiles/.config/${configdir} to ~/.config/${configdir}
    rm -rf ~/.config/${configdir}
    ln -sr $(pwd)/dotfiles/.config/${configdir} ~/.config/${configdir}
done
echo delete ~/.scripts and link .scripts to ~/.scripts
rm -rf ~/.scripts
ln -sr $(pwd)/dotfiles/.scripts ~/.scripts
echo delete ~/scripts and link ~/.scripts to ~/scripts
rm -rf ~/scripts
ln -sr ~/.scripts ~/scripts

for configfile in $(/bin/ls -Fa1 dotfiles);do
        echo delete ~/${configfile} and link ./dotfiles/${configfile} to ~/${configfile}
        rm -rf ~/${configfile}
        ln -sr $(pwd)/dotfiles/${configfile} ~/${configfile}
done
