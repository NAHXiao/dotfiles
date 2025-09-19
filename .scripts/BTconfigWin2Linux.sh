#!/usr/bin/env bash
#
# convert bluetooth config from windows to linux
# Uasge: ./BTconfigWin2Linux.sh BTKeys.reg
# @Step?
# 1. pair bluetooth device in linux
# 2. pair bluetooth device in windows and get BTKeys.reg
# 3. run this script
# @howToGetBTKeys.reg? 
# 1. download pstools
# 2. psexec.exe -s -i regedit /e C:\BTKeys.reg HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTHPORT\Parameters\Keys
# @Tips
# Old Btconfig will be backup to BTbakup
# parse result will be saved in dir named by HostMac
# @Author: NAHxiao
HostMac=;
Dev=;
function process(){
while read -r key; do 
    echo "$1" | grep -oPq '(?<="'"${key}"'"=).*$' && {
        "process_${key}" "$1" 
        return
    }
done<<-EOF
LTK
KeyLength
ERand
IRK
Address
AddressType
CSRKInbound
InboundSignCounter
CSRK
OutboundSignCounter
CEntralIRKStatus
AuthReq
EOF
}
# hex2std hex:00,11,22,33,44,55 -> 001122334455
function hex2std(){
    grep -oP "(?<=hex:)[0-9a-f,]+"|sed 's/,//g'|tr 'a-f' 'A-F'
}
# mac2serialmac 001122334455 -> 00:11:22:33:44:55
function mac2serialmac(){
    tr 'a-f' 'A-F'|sed 's/../&:/g; s/:$//'
}
function process_LINKKEY(){
        K=$(echo "$1" | hex2std)
        sed -i '/LinkKey/ {N; s/Key=.*/'"Key=$K"'/}' "/var/lib/bluetooth/$(echo "$HostMac"|mac2serialmac)/$(echo "$2"|mac2serialmac)/info"
        echo  "LinkKey=$K" >> "$HostMac/$2"
}
function process_LTK(){
        K=$(echo "$1" | hex2std)
        sed -i '/LongTermKey/ {N; s/Key=.*/'"Key=$K"'/}' "/var/lib/bluetooth/$(echo "$HostMac"|mac2serialmac)/$(echo "$Dev"|mac2serialmac)/info"
        echo  "LongTermKey=$K">> "$HostMac/$Dev"
}
function process_KeyLength(){
    return
}
function process_ERand(){
    return
}
function process_IRK(){
        K=$(echo "$1" | hex2std)
        sed -i '/IdentityResolvingKey/ {N; s/Key=.*/'"Key=$K"'/}' "/var/lib/bluetooth/$(echo "$HostMac"|mac2serialmac)/$(echo "$Dev"|mac2serialmac)/info"
        echo  "IdentityResolvingKey=$K" >> "$HostMac/$Dev"
}
function process_Address(){
    return
}
function process_AddressType(){
    return
}
function process_CSRKInbound(){
        K=$(echo "$1" | hex2std)
        sed -i '/RemoteSignatureKey/ {N; s/Key=.*/'"Key=$K"'/}' "/var/lib/bluetooth/$(echo "$HostMac"|mac2serialmac)/$(echo "$Dev"|mac2serialmac)/info"
        echo  "RemoteSignatureKey=$K" >> "$HostMac/$Dev"
}
function process_InboundSignCounter(){
    return
}
function process_CSRK(){
        K=$(echo "$1" | hex2std)
        sed -i '/LocalSignatureKey/ {N; s/Key=.*/'"Key=$K"'/}' "/var/lib/bluetooth/$(echo "$HostMac"|mac2serialmac)/$(echo "$Dev"|mac2serialmac)/info"
        echo  "LocalSignatureKey=$K" >> "$HostMac/$Dev"
}
function process_OutboundSignCounter(){
    return
}
function process_CEntralIRKStatus(){
    return
}
function process_AuthReq(){
    return
}
if [[ -z "$1" ]]; then
    echo "Usage: $0 BTKeys.reg"
    exit 1
fi
while read -r line ; do 
    tmp=$(echo "$line" |grep -oP '(?<=Keys\\)[0-9a-z]+(?=])')
    if [[ -n $tmp ]] ; then
        HostMac=$tmp
        mkdir -p "$HostMac"
        mkdir -p BTbakup
        cp -r "/var/lib/bluetooth/$(echo "$HostMac"|mac2serialmac)" ./BTbakup
        Dev=;
        continue;
    fi
    if [[ -n $HostMac ]] ; then 
        tmp=$(echo "$line" |grep -oP '(?<='"$HostMac"'\\)[0-9a-z]+')
        if [[ -n $tmp ]] ; then 
            Dev=$tmp
            continue;
        fi
        tmp2=$(echo "$line" |grep -oP 'hex:[0-9a-f,]+' )
        tmpdev=$(echo "$line" |grep -oP '(?<=\")[0-9a-f]+' )
        if [[ -n $tmp2  && -n $tmpdev && -z $Dev ]] ; then 
            process_LINKKEY "$tmp2" "$tmpdev"
            continue
        fi
        process "$line"
    fi
done < "$1"
systemctl restart bluetooth
