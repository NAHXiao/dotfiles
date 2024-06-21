#!/bin/bash
BACKDIR="$HOME/configbak"
function bakupAll(){
    for ObjInConfig in $(ls -A1 dotfiles/.config) ;do
        if [[ -e "$HOME/.config/${ObjInConfig}" ]];then
            echo backup $HOME/.config/${ObjInConfig} to $BACKUPDIR/.config/${ObjInConfig}
            mv "$HOME/.config/${ObjInConfig}" "$BACKUPDIR/.config/${ObjInConfig}"
        fi
    done
    for ObjInHome in $(ls -A1 dotfiles|grep -v '^\.config$') ;do
        if [[ -e "$HOME/${ObjInHome}" ]];then
            echo backup $HOME/${ObjInHome} to $BACKUPDIR/${ObjInHome}
            mv "$HOME/${ObjInHome}" "$BACKUPDIR/${ObjInHome}"
        fi
    done
}
function bakupNvim(){
    if [[ -e "$HOME/.config/nvim" ]];then
        echo backup $HOME/.config/nvim to $BACKUPDIR/.config/nvim
        mv "$HOME/.config/nvim" "$BACKUPDIR/.config/nvim"
    fi
}
function bakupZsh(){
    if [[ -e "$HOME/.config/zsh" ]];then
        echo backup $HOME/.config/zsh to $BACKUPDIR/.config/zsh
        mv "$HOME/.config/zsh" "$BACKUPDIR/.config/zsh"
    fi
    if [[ -e "$HOME/.zshenv" ]];then
        echo backup $HOME/.zshenv to $BACKUPDIR/.zshenv
        mv "$HOME/.zshenv" "$BACKUPDIR/.zshenv"
    fi
}
function installAll(){
    for ObjInConfig in $(ls -A1 dotfiles/.config) ;do
        echo link ./dotfiles/.config/${ObjInConfig} to $HOME/.config/${ObjInConfig}
        if [[ ! -e "$HOME/.config/${ObjInConfig}" ]];then
            ln -s "$(pwd)/dotfiles/.config/${ObjInConfig}" "$HOME/.config/${ObjInConfig}"
        else
            echo "Install $HOME/.config/${ObjInConfig} failed : File exists"
        fi
    done
    for ObjInHome in $(ls -A1 dotfiles|grep -v '^\.config$') ;do
        echo link ./dotfiles/${ObjInHome} to $HOME/${ObjInHome}
        if [[ ! -e "$HOME/.config/${ObjInHome}" ]];then
            ln -s "$(pwd)/dotfiles/${ObjInHome}" "$HOME/${ObjInHome}"
        else
            echo "Install $HOME/.config/${ObjInHome} failed : File exists"
        fi
    done
}
function installNvim(){
    echo link ./dotfiles/.config/nvim to $HOME/.config/nvim
    if [[ ! -e "$HOME/.config/nvim" ]];then
       ln -s "$(pwd)/dotfiles/.config/nvim" "$HOME/.config/nvim"
    else
       echo "Install $HOME/.config/nvim failed : File exists"
    fi
}
function installZsh(){
    echo link ./dotfiles/.zshenv to $HOME/.zshenv

    if [[ ! -e "$HOME/.zshenv" ]];then
        ln -s "$(pwd)/dotfiles/.zshenv" "$HOME/.zshenv"
    else
       echo "Install $HOME/.zshenv failed : File exists"
    fi
    echo link ./dotfiles/.config/zsh to $HOME/.config/zsh
    if [[ ! -e "$HOME/.config/zsh" ]];then
        ln -s "$(pwd)/dotfiles/.config/zsh" "$HOME/.config/zsh"
    else
       echo "Install $HOME/.config/zsh failed : File exists"
    fi
}
function restoreAll(){
    flag=;
    for ObjInConfig in $(ls -A1 dotfiles/.config) ;do
        if [[ -e "$BACKUPDIR/.config/${ObjInConfig}" ]];then
            flag=1;
            echo restore $BACKUPDIR/.config/${ObjInConfig} to $HOME/.config/${ObjInConfig}
            mv -f "$BACKUPDIR/.config/${ObjInConfig}" "$HOME/.config/${ObjInConfig}"
        fi
    done
    for ObjInHome in $(ls -A1 dotfiles|grep -v '^\.config$') ;do
        if [[ -e "$BACKUPDIR/${ObjInHome}" ]];then
            flag=1;
            echo restore $BACKUPDIR/${ObjInHome} to $HOME/${ObjInHome}
            mv -f "$BACKUPDIR/${ObjInHome}" "$HOME/${ObjInHome}"
        fi
    done
    if [ ! $flag ] ; then 
        echo "No backup found in $BACKUPDIR"
    fi
}
function uninstallAll(){
    for ObjInConfig in $(ls -A1 dotfiles/.config) ;do
        if [[ -L "$HOME/.config/${ObjInConfig}" ]];then
            echo remove $HOME/.config/${ObjInConfig}
            rm "$HOME/.config/${ObjInConfig}"
        fi
    done
    for ObjInHome in $(ls -A1 dotfiles|grep -v '^\.config$') ;do
        if [[ -L "$HOME/${ObjInHome}" ]];then
            echo remove "$HOME/${ObjInHome}"
            rm "$HOME/${ObjInHome}"
        fi
    done
}
function beforebackup() {
    BACKUPDIR="$BACKDIR/$(date +%y_%m%d_%k%0l_%N)"
    echo "Will backup old config to $BACKUPDIR and install new config from dotfiles"
    mkdir -p "$BACKUPDIR/.config" &>/dev/null|| { echo "mkdir $BACKUPDIR failed" && exit 1; } 
}
function beforerestore(){
    echo "Please Select backup to restore"
    select i in $(ls -1 "$BACKDIR");do
        BACKUPDIR="$BACKDIR/$i"
        break
    done
    [[ -z "$BACKUPDIR" ]] && { echo "No backup found in $BACKDIR" ;return 1; }
    echo "You select $BACKUPDIR to restore"
    return 0
}
BACKUPDIR=;
opt1="Install nvim config" 
opt2="Install zsh config" 
opt3="Install all config" 
opt4="Uninstall all config" 
opt5="Restore old config" 
if [[ ! -d "$HOME/.config" ]] ;then
	mkdir "$HOME/.config" &>/dev/null || { echo "create $HOME/.config error" ; exit 1 ; }
fi
select i in "$opt1" "$opt2" "$opt3" "$opt4" "$opt5";do
    case "$i" in
        "$opt1")
            beforebackup
            bakupNvim
            installNvim
            break
            ;;
        "$opt2")
            beforebackup
            bakupZsh
            installZsh
            break
            ;;
        "$opt3")
            beforebackup
            bakupAll
            installAll
            break
            ;;
        "$opt4")
            uninstallAll
            break
            ;;
        "$opt5")
            uninstallAll
            beforerestore && restoreAll
            break
            ;;
    esac
done
