## ░▀▀█░█▀▀░█░█░█▀▄░█▀▀
## ░▄▀░░▀▀█░█▀█░█▀▄░█░░
## ░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀

mkdir -p "$HOME/.cache/zsh" &>/dev/null
mkdir -p /tmp/$(whoami) &>/dev/null
#
while read file
do 
  source "$ZDOTDIR/$file.zsh"
done <<-EOF
env
utility
wsl1
theme
plugins
options
keybinds
aliases
prompt
wsl2
EOF
[[ -z $HTTP_PROXY ]] && auto_proxy &>/dev/null
