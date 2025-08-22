################WSL适配#################
if test $ISWSL ;then
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
function wsl_auto_proxy(){
    local cmd=''
    local ports=(7890 7891 1080 8080)
    if command -v curl &>/dev/null; then
        cmd='curl --max-time 1 -sf -x $ip:$port http://www.msftconnecttest.com/connecttest.txt -o/dev/null'
    elif command -v nc &>/dev/null; then 
        cmd='nc -vz $ip $port' 
    else
        echo "No curl or nc found, cannot auto detect proxy." >&2
        return
    fi
    local ipconfig_exe=$(get_winbin ipconfig.exe)
    [[ -z ${ipconfig_exe} ]] && return
    local arr=("127.0.0.1" $($ipconfig_exe | grep --binary-files=text -i 'IPV4'|grep -Eo '([0-9]{1,3}\.){3}([0-9]{1,3})'))
    for ip in ${arr[@]}; do
        for port in ${ports[@]}; do
            echo "try: $ip:$port"
            if eval $cmd &>/dev/null; then
                set_proxy $ip:$port
                echo "set proxy to $ip:$port"
                return
            fi
        done
    done
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
