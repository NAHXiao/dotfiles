#!/bin/bash
WIFINAME=wlan0
ETHNAME=p11p1
JLUIP='49.140'
[[ -f  "$XDG_RUNTIME_DIR/drcomloop.pid" ]]  && kill $(cat "$XDG_RUNTIME_DIR/drcomloop.pid" 2>/dev/null)  && rm "$XDG_RUNTIME_DIR/drcomloop.pid"
function is_connected_to_wifi(){
        iw dev "$1" link 2>&1 | grep -E '^Connected to' > /dev/null 2>&1 && return 0
		return 1
}
function switch_interface(){
if is_connected_to_wifi $WIFINAME; then 
		nmcli d d $WIFINAME 2>/dev/null; nmcli d u $ETHNAME
else
		nmcli d d $ETHNAME 2>/dev/null; nmcli d u $WIFINAME 
fi
}
function if_JLU_then_drcom(){
    killall drcom
    if ip addr show $ETHNAME | grep $JLUIP  && ! is_connected_to_wifi $WIFINAME ; then 
        drcom 
        while true ; do 
            ping -c 1 baidu.com | grep '1 received' >/dev/null 2>&1 || {
                killall drcom ; sleep 0.1 ; drcom
            }
        done &
        echo $! > "$XDG_RUNTIME_DIR/drcomloop.pid"
    fi
}
switch_interface
if_JLU_then_drcom
