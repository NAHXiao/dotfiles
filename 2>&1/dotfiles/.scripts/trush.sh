#!/bin/bash
[[ -z $1 ]] && echo "Usage: $0 <file/dir>"&&exit
home_disk=$(df "$HOME" |awk 'NR==2 {print$1}')
function is_in_same_disk(){
#############################
# StdErr: df du
# Arguments: path
# Return: 1(true) / 0 (false)
#############################
IFS=$'\n';dir_disk_arr=($(df $(du $1 | awk '{print$2}')|awk 'NR>1 {print$1}'));IFS=$' \n\t'
[[ ${#dir_disk_arr[@]} -eq 1 ]] && return 1
same=1
for ((i=0;i<$((${#dir_disk_arr[@]}-1));i++));do
    [[ ${dir_disk_arr[i]} != "${dir_disk_arr[i+1]}" ]] && same=0 && break
done
[[ $same -eq 1  ]] && return 1 || return 0
}
function get_trush_dir(){
    if [[ "$1" == "$home_disk" ]];then
        trushdir="$HOME/.local/.trush"
    else
        dir_root=$(lsblk -o MOUNTPOINT --raw "$1" 2>/dev/null| awk 'NR=2' )
        trushdir="$dir_root/.trush"
    fi
    trushdir="$trushdir/$(date +%s%N)"
    mkdir -p "$trushdir" || exit 1
    echo "$trushdir"
}

function trush(){
    is_in_same_disk "$1"
    if [[  $? -eq 1 ]] ;then
        trushdir=$(get_trush_dir "$(df "$1"|awk 'NR==2 {print$1}')")
        mv -v "$1" "$trushdir"
    else
        IFS=$'\n';for dir in $(du "$1"|awk '{print$2}');do
        trush "$dir"
        done;IFS=$' \n\t'
    fi
}
for i in "$@";do
    trush "$i"
done

# trush "$1"
