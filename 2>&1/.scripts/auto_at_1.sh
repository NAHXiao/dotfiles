while true;do
    # ws=socat -U - UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock
    ws=$(hyprctl activeworkspace -j | jq -r .id)
    if [[ '1' == $ws ]];then
               hyprctl plugin load /usr/lib/hyprland-plugins/hyprbars.so 
           else      
               hyprctl plugin unload /usr/lib/hyprland-plugins/hyprbars.so 
    fi
    sleep 0.1
done

