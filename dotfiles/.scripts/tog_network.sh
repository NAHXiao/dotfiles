#!/bin/bash
WIFINAME=wlan0
ETHNAME=p11p1
JLUIP='49.140'
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
if ip addr show $ETHNAME | grep $JLUIP ; then 
		killall drcom ; sleep 0.1 ; drcom 
fi
}
switch_interface
if_JLU_then_drcom
