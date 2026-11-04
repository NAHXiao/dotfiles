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

# Set ZDOTDIR here so ~/.zshenv can be a symlink to this file.
export ZDOTDIR="$HOME/.config/zsh"

########################################## TEMP DIR SETUP ###########################################
mkdir -p "$HOME/.cache/zsh" &>/dev/null
if [ ! -e "$(readlink -f "$HOME/tmp")" ]; then
    ln -sf $(mktemp -d) "$HOME/tmp"
fi

# Load 0-zshenv fragments in filename order.
# Use find instead of zsh's (N) glob qualifier so bash can source this file too.
if [ -d "$ZDOTDIR/0-zshenv" ]; then
    while IFS= read -r f; do
        [ -f "$f" ] || continue
        . "$f"
    done < <(find "$ZDOTDIR/0-zshenv" -maxdepth 1 -name '*.zsh' -print | LC_ALL=C sort)
fi
