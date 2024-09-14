################WSL适配#################
if uname -a | grep -qi Microsoft ;then
    [[ -z $HTTP_PROXY ]] && wsl_auto_proxy &>/dev/null
    export WINHOME=$(get_winHome)
    alias -s exe='winexec'
    alias -s cmd='winexec'
fi
################WSL适配#################
