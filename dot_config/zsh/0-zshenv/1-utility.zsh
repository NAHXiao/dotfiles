##
## Utility Functions For Any Environment
##
function unset_proxy(){
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset socks_proxy
}
function set_proxy(){
    export http_proxy=http://$1
    export https_proxy=http://$1
    export HTTP_PROXY=http://$1
    export HTTPS_PROXY=http://$1
    export socks_proxy=socks5://$1
}
#@param ip
#@param port
#no param ip/port: only-check-dependency
function try_proxy(){
    local cmd=""
    if command -v curl &>/dev/null; then
        cmd='curl --max-time 3  --connect-timeout 0.5 -Is -x $ip:$port http://223.5.5.5 -o/dev/null'
    elif command -v wget &>/dev/null; then
        cmd='env http_proxy=http://$ip:$port https_proxy=http://$ip:$port wget --timeout=3 --tries=1 --content-on-error --no-check-certificate --spider -O /dev/null http://223.5.5.5 ; [[ $? == 0 || $? == 8 ]]'
    else
        echo "No curl or wget found, cannot auto detect proxy." >&2
        return 1
    fi
    local ip=$1
    local port=$2
    [[ -z $ip || -z $port ]] && echo "no ip/port provided,only check dependency" && return
    if eval $cmd &>/dev/null; then
        return 0
    fi
    return 1
}
function auto_proxy(){
    try_proxy || return
    local ports=(7890 7891 1080 8080)
    local arr=("127.0.0.1")
    command -v ip 2>/dev/null && local gw=$(ip route show default | awk '{print $3}') && arr+=("$gw")
    for ip in ${arr[@]}; do
        for port in ${ports[@]}; do
            echo "try: $ip:$port"
            if try_proxy $ip $port; then
                set_proxy $ip:$port
                echo "set proxy to $ip:$port"
                return
            fi
        done
    done
}
