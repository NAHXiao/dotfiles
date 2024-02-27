#!/bin/bash 
unset HTTP_PROXY
unset HTTPS_PROXY
unset http_proxy
unset https_proxy
unset ALL_PROXY

cd $HOME/alist || ( echo "cd $HOME/alist error" && exit 1 )
./alist server
# sleep 1
# localip=$(ip -4 -j addr show eth0 |jq -r '.[]|.addr_info|.[]|.local')
# powershell.exe sudo netsh interface portproxy add v4tov4 listenaddress=$localip listenport=5244 connectaddress=127.0.0.1 connectport=5244
