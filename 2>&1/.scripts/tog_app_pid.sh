#!/bin/bash
[[ -z $1 || -z $2 ]] && echo "usage $0 KeyBase REGEX" && exit 0

[[ $(hyprctl activewindow -j | jq -r .workspace.id) -lt 0 ]]  && exit 0

KeyBase="/tmp/$(whoami)/${WAYLAND_DISPLAY}/KeyBase_pid"
mkdir -v "$KeyBase" 1>&2 2>/dev/null
KeyBase=$KeyBase'/'$1

REGEX=$2

curpid=$(hyprctl activewindow -j | jq -r '.pid')
curT=$(hyprctl activewindow -j | jq -r '"\(.title)\(.class)\(.initialTitle)\(.initialClass)"')

# cur属于REGEX=>base不变(从文件读取,空则空)
# cur不属于REGEX=>base=cur
if echo "$curT" | grep -qE "$REGEX"  ; then 
		basepid=$(cat "$KeyBase" 2>/dev/null)
else
		basepid=$curpid
fi
# echo "curpid:"$curpid
# echo "basepid:"$basepid
#排序REGEX or basepid,结果一定包含curpid
# [[ -z $basepid ]] && basepid=$curpid
# 微调: pid是数字,去掉"",使用unique去重
clients_array=($( hyprctl clients -j | jq -r 'map(select(.workspace.id > 0))|map({workspace:.workspace.id,pid,T:"\(.title)\(.class)\(.initialTitle)\(.initialClass)"}) | map( select( (.pid=='"$basepid"') or (.T | test("'"$REGEX"'")) )) | sort_by(.workspace)|map(.pid)|unique |.[]'))

tofucus=${clients_array[0]}
array_length=${#clients_array[@]}
for (( i=0;i<array_length;i++ ));do
		if [[ ${clients_array[i]} == "$curpid" ]] &&  ! [[  $i -eq $((array_length - 1)) ]] ; then 
						tofucus=${clients_array[$((i+1))]}
				break
		fi
done
echo "$basepid" > "$KeyBase"
echo "${clients_array[@]}" > "$KeyBase".all
echo  $tofucus >> "$KeyBase".all
hyprctl dispatch focuswindow pid:$tofucus
