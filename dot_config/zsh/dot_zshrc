mkdir -p "$HOME/.cache/zsh" &>/dev/null

if [ ! -e "$(readlink -f "$HOME/tmp")" ]; then
    ln -sf $(mktemp -d) "$HOME/tmp"
fi

while read file
do 
  source "$ZDOTDIR/$file.zsh"
done <<-EOF
sysenv
wslutils
env
theme
plugins
utility
options
keybinds
aliases
prompt
wslconf
EOF
[[ -z $HTTP_PROXY ]] && auto_proxy &>/dev/null
