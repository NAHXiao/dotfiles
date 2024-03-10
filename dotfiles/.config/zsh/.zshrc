## ░▀▀█░█▀▀░█░█░█▀▄░█▀▀
## ░▄▀░░▀▀█░█▀█░█▀▄░█░░
## ░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀
##
## rxyhn's Z-Shell configuration
## https://github.com/rxyhn

while read file
do 
  source "$ZDOTDIR/$file.zsh"
done <<-EOF
theme
env
utility
options
plugins
keybinds
prompt
EOF
# vim:ft=zsh:nowrap
[[ $(uname -r) =~ ".*WSL.*" ]] && auto_proxy >/dev/null
mkdir -p "$HOME/.cache/zsh" &>/dev/null
source "$ZDOTDIR/aliases.zsh"
