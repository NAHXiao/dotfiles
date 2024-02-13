oldpid="$(cat "/tmp/$(whoami)/${WAYLAND_DISPLAY}/mpvpaper.pid" 2>/dev/null)" >/dev/null 2>&1
[[ -z $oldpid ]] && oldpid="$(cat "/tmp/$(whoami)/${WAYLAND_DISPLAY}/swaybg.pid" 2>/dev/null)" >/dev/null 2>&1
echo $oldpid
rm "/tmp/$(whoami)/${WAYLAND_DISPLAY}/mpvpaper.pid" "/tmp/$(whoami)/${WAYLAND_DISPLAY}/swaybg.pid"  2>/dev/null
mkdir -v /tmp/$(whoami)/${WAYLAND_DISPLAY} 2>/dev/null
case $1 in
		*mp4)
		mpvpaper -vs -o "loop no-audio" '*' "$1"  >/dev/null 2>&1 &
echo $! > "/tmp/$(whoami)/${WAYLAND_DISPLAY}/mpvpaper.pid"
		;;
		*png)
		swaybg -i "$1"&
echo $! > "/tmp/$(whoami)/${WAYLAND_DISPLAY}/swaybg.pid"
		;;
esac

{ 
sleep 3  && kill "$oldpid" 2>/dev/null
}&

