#  Always
#   /etc/zshenv
#   $ZDOTDIR/.zshenv
#  LoginShell
#   /etc/zprofile
#   $ZDOTDIR/.zprofile
#  InterActive
#   /etc/zshrc
#   $ZDOTDIR/.zshrc
#  LoginShell
#   /etc/zlogin
#   $ZDOTDIR/.zlogin

########################################## TEMP DIR SETUP ###########################################
mkdir -p "$HOME/.cache/zsh" &>/dev/null
if [ ! -e "$(readlink -f "$HOME/tmp")" ]; then
    ln -sf $(mktemp -d) "$HOME/tmp"
fi

# on = order by name
for f in "$ZDOTDIR/0-zshenv"/*.zsh(Non); do
    source "$f"
done
