##TODO UPDATE
## Plugins
##
# Configure and load plugins using Zinit

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
    hlissner/zsh-autopair \
    zdharma-continuum/fast-syntax-highlighting \
    MichaelAquilina/zsh-you-should-use

zinit ice wait'2' lucid
zinit light zsh-users/zsh-history-substring-search

zinit ice wait'2' lucid
zinit light zdharma-continuum/history-search-multi-word

# auto-suggestions 灰色字体补全
# zinit ice wait'1' lucid
zinit light zsh-users/zsh-autosuggestions



# FZF
if  ! command -v fzf &>/dev/null ;then
    if command -v go  &>/dev/null && command -v jq  &>/dev/null; then
        zinit pack for fzf
    else
        bpickkey=;
        if (( ISLINUX && IS_AMD64 )); then
            bpickkey='*linux*amd64*'
        elif (( ISLINUX && IS_ARM64 )); then
            bpickkey='*linux*arm64*'
        elif (( ISMAC && IS_AMD64 )); then
            bpickkey='*darwin*amd64*'
        elif (( ISMAC && IS_ARM64 )); then
            bpickkey='*darwin*arm64*'
        elif (( ISCYGWIN || ISMSYS )); then
            if (( IS_AMD64 )); then
                bpickkey='*windows*amd64*'
            elif (( IS_ARM64 )); then
                bpickkey='*windows*arm64*'
            fi
        fi
        if test $bpickkey ;then
            zinit ice from"gh-r" as"command" bpick$bpickkey
            zinit light junegunn/fzf
            unset bpickkey
        fi
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

    bpickkey=;
    if (( ISLINUX && IS_AMD64 )); then
        bpickkey='*x86_64*linux*gnu*zip'
    elif (( ISLINUX && IS_ARM64 && ISANDROID==0 )); then
        bpickkey='*aarch64*linux*gnu*zip'
    elif (( ISCYGWIN || ISMSYS )); then
        if (( IS_AMD64 )); then
            bpickkey='*x86_64*windows*gnu*zip'
        fi
    fi
    if test $bpickkey ;then
        zinit ice from"gh-r" as"command" bpick$bpickkey
        zinit light eza-community/eza
        unset bpickkey
    fi
fi

zinit light-mode for \
    Aloxaf/fzf-tab

# zinit ice depth=1
# zinit light jeffreytse/zsh-vi-mode
# ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
# zsh_vim
