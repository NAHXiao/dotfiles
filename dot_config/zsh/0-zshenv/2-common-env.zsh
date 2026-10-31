##
## PATH && ENV Var
##
########################################### UTILS ###################################################
function export_chk_exist(){
    local val="${1#*=}"
    [[ -e "$val" ]] && export "$1"
}
function prepend_path(){
    export PATH="$1:$PATH"
}
function append_path(){
    export PATH="$PATH:$1"
}
function prepend_path_chk_exist(){
    [[ -e "$1" ]] && prepend_path "$1"
}
function append_path_chk_exist(){
    [[ -e "$1" ]] && append_path "$1"
}
function prepend_path_chk_exist_dup(){
    [[ -e "$1" ]] || return
    case ":$PATH:" in
        *":$1:"*) ;;
        *) prepend_path "$1" ;;
    esac
}
function append_path_chk_exist_dup(){
    [[ -e "$1" ]] || return
    case ":$PATH:" in
        *":$1:"*) ;;
        *) append_path "$1" ;;
    esac
}

############################################# XDG ##################################################
[[ -z $XDG_DESKTOP_DIR ]] && export XDG_DESKTOP_DIR="$HOME/Desktop"
[[ -z $XDG_DOWNLOAD_DIR ]] && export XDG_DOWNLOAD_DIR="$HOME/Downloads"
[[ -z $XDG_TEMPLATES_DIR ]] && export XDG_TEMPLATES_DIR="$HOME/Templates"
[[ -z $XDG_DOCUMENTS_DIR ]] && export XDG_DOCUMENTS_DIR="$HOME/Documents"
[[ -z $XDG_MUSIC_DIR ]] && export XDG_MUSIC_DIR="$HOME/Music"
[[ -z $XDG_PICTURES_DIR ]] && export XDG_PICTURES_DIR="$HOME/Pictures"
[[ -z $XDG_VIDEOS_DIR ]] && export XDG_VIDEOS_DIR="$HOME/Videos"
[[ -z $XDG_PUBLICSHARE_DIR ]] && export XDG_PUBLICSHARE_DIR="$HOME/Public"

[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME="$HOME/.config"
[[ -z $XDG_CACHE_HOME ]] && export XDG_CACHE_HOME="$HOME/.cache"
[[ -z $XDG_DATA_HOME ]] && export XDG_DATA_HOME="$HOME/.local/share"
[[ -z $XDG_STATE_HOME ]] && export XDG_STATE_HOME="$HOME/.local/state"

[[ -z $XDG_RUNTIME_DIR ]] && export_chk_exist XDG_RUNTIME_DIR="/run/user/$(id -u)"
[[ -z $XDG_RUNTIME_DIR ]] && export XDG_RUNTIME_DIR="$(mktemp -u|xargs dirname)/XDG_RUNTIME_DIR-$(id -u)" && mkdir $XDG_RUNTIME_DIR &>/dev/null && chown $(id -u):$(id -u) -R $XDG_RUNTIME_DIR && chmod 700 $XDG_RUNTIME_DIR

[[ -z $XDG_CONFIG_DIRS ]] && export_chk_exist XDG_CONFIG_DIRS="/etc/xdg"

if (( ! ISANDROID )) ;then #Termux不支持
    export LANG=zh_CN.UTF-8
    export LC_ALL=zh_CN.UTF-8
fi
############################################# PATH #################################################
#  NODE
#FNM管理node版本和npm版本,不设置npm prefix时npm package默认按nodejs版本隔离,设置npm prefix时npm package不隔离,pnpm不归fnm管始终不隔离

#本地fnm本身的位置
prepend_path_chk_exist_dup "$HOME/.local/share/fnm"
#非交互式用node绝对路径

#npm package binary位置: ~/.npmrc设置了prefix -> npm package不隔离
prepend_path_chk_exist_dup "$HOME/.npm-global/bin"

#本地pnpm本身的位置+pnpm package binary位置
export_chk_exist PNPM_HOME="$HOME/.local/share/pnpm"
prepend_path_chk_exist_dup "$PNPM_HOME"
# Other
prepend_path_chk_exist_dup "$HOME/.scripts"
prepend_path_chk_exist_dup "$HOME/.local/bin"
prepend_path_chk_exist_dup "$HOME/.cargo/bin"
prepend_path_chk_exist_dup "/snap/bin"
prepend_path_chk_exist_dup "/usr/local/go/bin"

############################################ ZSH CONF ##############################################


command -v vim &>/dev/null && {
    export VISUAL="vim"
    export EDITOR="vim"
}
command -v nvim &>/dev/null && {
    export VISUAL="nvim"
    export EDITOR="nvim"
}

export_chk_exist MANDOCPATH="$HOME/.local/Obsidian/main/CLIMAN"

############################################# APPS #################################################
export_chk_exist MANDOCPATH="$HOME/.local/share/Obsidian/main/计算机/CLIMAN"

# [[ -f ~/.DEEPSEEK_API_KEY ]] && export DEEPSEEK_API_KEY=$(cat ~/.DEEPSEEK_API_KEY)
[[ -f ~/.GPTENV ]] && while IFS= read -r line; do
    [ -z "$line" ] && continue
    key=${line%%=*}
    value=${line#*=}
    export "$key=$value"
done < ~/.GPTENV
############################################# BUGFIX ###############################################
export CRYPTOGRAPHY_OPENSSL_NO_LEGACY=true #inconda报错 旧SSL算法问题
############################################# PROXY ###############################################
export NO_PROXY="localhost,127.0.0.1,::1"
export no_proxy="$NO_PROXY"
[[ -z HTTP_PROXY ]] && auto_proxy
############################################# END ##################################################
# vim:ft=zsh:nowrap
