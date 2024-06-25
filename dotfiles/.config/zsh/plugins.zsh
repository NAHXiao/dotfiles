##TODO UPDATE
## Plugins
##

# Configure and load plugins using Zinit's
arch=$(uname -m)
if command uname -r &>/dev/null|command grep 'WSL' &>/dev/null ; then 
    isWSL=true
else
    isWSL=false
fi

ZINIT_HOME="${ZINIT_HOME:-${XDG_DATA_HOME:-${HOME}/.local/share}/zinit}"
# Added by Zinit's installer
if [[ ! -f ${ZINIT_HOME}/zinit.git/zinit.zsh ]]; then
    print -P "%F{14}▓▒░ Installing Flexible and fast ZSH plugin manager %F{13}(zinit)%f"
    command mkdir -p "${ZINIT_HOME}" && command chmod g-rwX "${ZINIT_HOME}"
    command git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}/zinit.git" && \
        print -P "%F{10}▓▒░ Installation successful.%f%b" || \
        print -P "%F{9}▓▒░ The clone has failed.%f%b"
fi

source "${ZINIT_HOME}/zinit.git/zinit.zsh"

zinit ice blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

autoload compinit
compinit

zinit light-mode for \
  Aloxaf/fzf-tab

zinit light-mode for \
  hlissner/zsh-autopair \
  zdharma-continuum/fast-syntax-highlighting \
  MichaelAquilina/zsh-you-should-use

zinit ice wait'3' lucid
zinit light zsh-users/zsh-history-substring-search

zinit ice wait'2' lucid
zinit light zdharma-continuum/history-search-multi-word

#auto-suggestions 灰色字体补全
zinit ice wait'1' lucid
zinit light zsh-users/zsh-autosuggestions

# FZF
if  ! command -v fzf &>/dev/null ;then
    if command -v go  &>/dev/null && command -v jq  &>/dev/null; then
        zinit pack for fzf
    else
        if [[ $arch == 'x86_64' ]];then
            zinit ice from"gh-r" as"command" 
        elif [[ $arch == 'aarch64' ]];then
            zinit ice from"gh-r" as"command" bpick"*arm8*"
        fi
        zinit light junegunn/fzf-bin 
    fi
fi
#EZA
if  ! command -v eza &>/dev/null ;then
    zinit ice from"gh-r" as"completion" \
        bpick"*completions*" \
        id-as"eza-community--eza--completion" \
        atclone"zinit creinstall -q ." \
        atpull"%atclone" \
        extract
    zinit load eza-community/eza
    if [[ $arch == 'x86_64' ]];then
        zinit ice from"gh-r" as"command" bpick"*x86_64*gnu*zip"
    elif [[ $arch == 'aarch64' ]];then
        zinit ice from"gh-r" as"command" bpick"*aarch64*gnu*zip"
    fi
    zinit light eza-community/eza
fi

# zsh_vim
# zinit ice depth=1
# zinit light jeffreytse/zsh-vi-mode
# ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
