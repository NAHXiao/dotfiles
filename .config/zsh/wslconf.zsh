################WSL适配#################
if test $ISWSL ;then
    [[ -z $HTTP_PROXY ]] && wsl_auto_proxy &>/dev/null
fi
################WSL适配#################
