################WSL适配#################
if (( ISWSL )) ;then
    function split_winpath(){
        export WINPATH=$(command printenv PATH | command perl -ne 'print join(":", grep { /\/mnt\/[a-z]/ } split(/:/));')
        export PATH=$(command printenv PATH | command perl -ne 'print join(":", grep { !/\/mnt\/[a-z]/ } split(/:/));')
    }
    function get_winbin(){
        env PATH=$WINPATH /bin/which "$*"
    }
    function get_allbin(){
        env PATH=$PATH:$WINPATH /bin/which "$*"
    }
    function winexec(){
        env PATH=$WINPATH "$1" "${@:2}"
    }
    function wslexec(){
        env PATH=$WINPATH:$PATH "$1" "${@:2}"
    }
    function get_winHome(){
        local pwsh_path=$(get_winbin powershell.exe)
        if [[ -n $pwsh_path ]];then
            echo "/mnt/$($pwsh_path -Command '$env:UserProfile' |sed 's#\\#/#g;s#[A-Z]:#\L&#;s#:##;s#\r##')"
            return 0
        fi
        return 1
    }
    command -v wslpath &>/dev/null && function cdwin(){
        [[ -n $1 ]] && cd "$(wslpath $1)"
    }
    function wsl_auto_proxy(){
        local cmd=''
        local ports=(7890 7891 1080 8080)
        local arr=("127.0.0.1")
        local ipconfig_exe=$(get_winbin ipconfig.exe)
        local gateway=$(command -v ip &>/dev/null && command -v jq &>/dev/null && ip -j route | jq -r '.[]|select(.dst=="default")|.gateway')
        if [[ -n $gateway ]] then
            arr+=($gateway)
        fi
        if [[ -n ${ipconfig_exe} ]] then
            arr+=($(${ipconfig_exe} | grep --binary-files=text -i 'IPV4'|grep -Eo '([0-9]{1,3}\.){3}([0-9]{1,3})'))
        fi
        for port in ${ports[@]}; do
            for ip in ${arr[@]}; do
                echo "try: $ip:$port"
                if try_proxy $ip $port;then
                    set_proxy $ip:$port
                    echo "set proxy to $ip:$port"
                    return
                fi
            done
        done
        return false
    }
    function wsl_notify(){
        [[ $# -eq 0 ]] && set -- "'WSL Notification'"
        winexec pwsh.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Import-Module BurntToast;New-BurntToastNotification -Sound Alarm2 -Text $*"
    }
    [[ -z $WINPATH ]] && split_winpath


    # fix MESA:ZINK(VK_ERROR_INCOMPATIBLE_DRIVER) error
    export GALLIUM_DRIVER=llvmpipe
fi
################WSL适配#################
