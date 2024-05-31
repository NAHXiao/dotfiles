################WSL适配#################
if uname -a | grep -qi Microsoft ;then

function split_winpath(){
    export WINPATH=$(/usr/bin/printenv PATH | /usr/bin/perl -ne 'print join(":", grep { /\/mnt\/[a-z]/ } split(/:/));')
    export PATH=$(/usr/bin/printenv PATH | /usr/bin/perl -ne 'print join(":", grep { !/\/mnt\/[a-z]/ } split(/:/));')
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
function get_winHome(){
    echo "/mnt/$($(get_winbin powershell.exe) -Command '$env:UserProfile' |sed 's#\\#/#g;s#[A-Z]:#\L&#;s#:##;s#\r##')"
}
function auto_proxy(){
    [[ -n $HTTP_PROXY ]] && return
    grep_exe=$(get_winbin grep.exe)
    [[ -z ${grep_exe} ]] && return
    ipconfig_exe=$(get_winbin ipconfig.exe)
    [[ -z ${ipconfig_exe} ]] && return
    cmd=''
    port=7890
    if command -v nc &>/dev/null ;then 
        cmd='nc -vz $ip $port' 
    elif command -v curl &>/dev/null;then
        cmd='curl --connect-timeout 0.5 -s -x $ip:$port http://baidu.com -o/dev/null'
    else
        return
    fi
    for ip in "127.0.0.1" $($ipconfig_exe | $grep_exe -i 'IPv4' | cut -d ':' -f 2 |tr '\r' ' ');do
       if eval $cmd &>/dev/null ; then
           set_proxy $ip:7890
           echo "set proxy to $ip:7890"
           break
       fi
    done
}
[[ -z $WINPATH ]] && split_winpath
fi
################WSL适配#################
