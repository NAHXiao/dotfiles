##TODO UPDATE
## Plugins
##

# Configure and load plugins using Zinit's
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

#WSL的垃圾性能会导致卡顿(好像arch不怎么卡)
if [[ ! $(uname -r) =~ ".*WSL.*"  ||  $(cat /etc/*release|grep NAME) =~ ".*Arch.*" ]];then
zinit light-mode for \
  hlissner/zsh-autopair \
  zdharma-continuum/fast-syntax-highlighting \
  MichaelAquilina/zsh-you-should-use
fi
zinit ice wait'3' lucid
zinit light zsh-users/zsh-history-substring-search

zinit ice wait'2' lucid
zinit light zdharma-continuum/history-search-multi-word

# FZF
if  command -v fzf &>/dev/null ;then
if [[ $(uname -a ) =~ '.*x86_64.*' ]];then
zinit ice from"gh-r" as"command" 
elif [[ $(uname -a ) =~ '.*aarch64.*' ]];then
zinit ice from"gh-r" as"command" bpick"*arm8*"
fi
zinit light junegunn/fzf-bin 
fi


# vim:ft=zsh
