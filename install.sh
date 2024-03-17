#!/bin/bash 
echo -e "Attention!!!\tThis script will delete your current dotfiles and replace them with the ones in this repo"
echo -e "注意!!!\t此脚本将删除您当前的dotfiles并用此repo中的dotfiles替换它们"
read -r -p "Still Install? [y/N] " response
[[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]] || exit 1
mkdir ~/.config 2>/dev/null
for configdir in $(ls -A1 dotfiles/.config) ;do
    echo delete ~/.config/${configdir} and link ./dotfiles/.config/${configdir} to ~/.config/${configdir}
    rm -rf ~/.config/${configdir}
    ln -s $(pwd)/dotfiles/.config/${configdir} ~/.config/${configdir}
done
echo delete ~/.scripts and link .scripts to ~/.scripts
rm -rf ~/.scripts
ln -s $(pwd)/dotfiles/.scripts ~/.scripts
echo delete ~/scripts and link ~/.scripts to ~/scripts
rm -rf ~/scripts
ln -s ~/.scripts ~/scripts

for configfile in $(/bin/ls -A1 dotfiles|grep -v '^\.config$');do
        echo delete ~/${configfile} and link ./dotfiles/${configfile} to ~/${configfile}
        rm -rf ~/${configfile}
        ln -s $(pwd)/dotfiles/${configfile} ~/${configfile}
done
