################WSL适配#################
if test $ISWSL ;then
    [[ -z $HTTP_PROXY ]] && wsl_auto_proxy &>/dev/null
    alias -s exe='winexec'
    alias -s cmd='winexec'
fi
################WSL适配#################
