################WSL适配#################
if test $ISWSL ;then
    [[ -z $HTTP_PROXY ]] && wsl_auto_proxy &>/dev/null
    alias -s exe='winexec'
    alias -s cmd='winexec'
    test $ISWSL || {
        export LC_ALL=en_US.UTF-8  
        export LANG=zh.CN.UTF-8
        export LANGUAGE=zh.CN.UTF-8
    }
fi
################WSL适配#################
