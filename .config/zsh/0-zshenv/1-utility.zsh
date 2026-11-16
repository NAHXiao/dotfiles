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
build_no_proxy() {
    if command -v ip &>/dev/null  && command -v jq &>/dev/null ;then
        {
            # 1) 回环 + 常见别名
            printf '%s\n' localhost 127.0.0.1 ::1 '[::1]' 127.0.0.0/8
            hostname
            hostname -f 2>/dev/null || true

            # 2) IPv4 直连路由：connected 路由的 scope 是 link，dst 已是规范网段
            ip -j -4 route show |
            jq -r '.[] | select(.scope == "link") | .dst // empty'

            # 3) IPv6 on-link 路由：无 gateway，排除 default 和组播 ff00::/8
            ip -j -6 route show |
            jq -r '.[] | select(.gateway == null) | .dst // empty
             | select(. != "default" and (startswith("ff") | not))'

            # 4) 本机各接口地址：给不支持 CIDR 的老客户端留精确 IP
            ip -j addr show |
            jq -r '.[] | select(.ifname != "lo") | .addr_info[]?
             | select(.family == "inet") | .local'
        } | sed -e 's:/32$::' -e 's:/128$::' | sort -u | paste -sd, -
    else
        echo "localhost,127.0.0.1,::1"
    fi
}

NO_PROXY="$(build_no_proxy)"; export NO_PROXY
no_proxy="$NO_PROXY";            export no_proxy   # 两个都设
#@param ip
#@param port
#no param ip/port: only-check-dependency
#output: only stderr
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
    [[ -z $ip || -z $port ]] && echo "no ip/port provided,only check dependency" >&2 && return
    if eval $cmd &>/dev/null; then
        return 0
    fi
    return 1
}
function auto_proxy(){
    try_proxy || return 0
    local ports=(7890 7891 1080 8080)
    local arr=("127.0.0.1")
    command -v ip &>/dev/null && local gw=$(ip route show default | awk '{print $3}') && arr+=("$gw")
    for ip in ${arr[@]}; do
        for port in ${ports[@]}; do
            echo "try: $ip:$port" >&2
            if try_proxy $ip $port; then
                set_proxy $ip:$port
                echo "set proxy to $ip:$port"
                return
            fi
        done
    done
    return 0
}
