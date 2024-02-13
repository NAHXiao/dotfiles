#!/bin/bash
[[ -z $1 || -z $2 ]] && echo "usage $0 KeyBase REGEX" && exit 0

[[ $(hyprctl activewindow -j | jq -r .workspace.id) -lt 0 ]]  && exit 0

KeyBase="/tmp/$(whoami)/${WAYLAND_DISPLAY}/KeyBase"
mkdir -v "$KeyBase" 1>&2 2>/dev/null
KeyBase=$KeyBase'/'$1

REGEX=$2

curaddress=$(hyprctl activewindow -j | jq -r '.address')
curT=$(hyprctl activewindow -j | jq -r '"\(.title)\(.class)\(.initialTitle)\(.initialClass)"')

# cur属于REGEX=>base不变(从文件读取,空则空)
# cur不属于REGEX=>base=cur
if echo "$curT" | grep -qE "$REGEX"  ; then 
		baseaddress=$(cat "$KeyBase" 2>/dev/null)
else
		baseaddress=$curaddress
fi
# echo "curaddress:"$curaddress
# echo "baseaddress:"$baseaddress
#排序REGEX or baseaddress,结果一定包含curaddress
# [[ -z $baseaddress ]] && baseaddress=$curaddress
clients_array=($( hyprctl clients -j | jq -r 'map(select(.workspace.id > 0))|map({workspace:.workspace.id,address,T:"\(.title)\(.class)\(.initialTitle)\(.initialClass)"}) | map( select( (.address=="'"$baseaddress"'") or (.T | test("'"$REGEX"'")) )) | sort_by(.workspace)|map(.address)|.[]'))

tofucus=${clients_array[0]}
array_length=${#clients_array[@]}
for (( i=0;i<array_length;i++ ));do
		if [[ ${clients_array[i]} == "$curaddress" ]] &&  ! [[  $i -eq $((array_length - 1)) ]] ; then 
						tofucus=${clients_array[$((i+1))]}
				break
		fi
done
echo "$baseaddress" > "$KeyBase"
echo "${clients_array[@]}" > "$KeyBase".all
echo  $tofucus >> "$KeyBase".all
hyprctl dispatch focuswindow address:$tofucus
