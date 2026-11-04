#
# ~/.bash_profile
#

# Load shared environment from the zsh config (bash-compatible subset).
if [ -f "$HOME/.zshenv" ]; then
    . "$HOME/.zshenv"
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc
