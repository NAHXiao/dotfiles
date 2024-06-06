################WSL适配#################
if uname -a | grep -qi Microsoft ;then
    [[ -z $HTTP_PROXY ]] && auto_proxy &>/dev/null
    export WINHOME=$(get_winHome)
fi
################WSL适配#################
