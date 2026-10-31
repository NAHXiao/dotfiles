##
## Utility Functions For InterActive
##
# 循环向上cd
autoload -Uz compinit && compinit
function g/(){
    local next=;
    while [[ $(pwd) != '/' ]] ; do
        builtin cd ..
        echo "\033[31m"$(pwd)"\033[0m" "\033[32m[press enter to continue]\033[0m"
        ls
        read next;
        [[ -n $next ]] && break
    done
}
function clear_invalid_link(){
    if [ $# -ne 1 ]; then
        echo "Usage: $0 <directory>"
        return 1
    fi
    dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: Directory '$dir' does not exist" >&2
        return 1
    fi
    deleted_count=0
    _IFS=$IFS;IFS=$'\n'
    for link in $(find "$dir" -type l -print);do
        if [ ! -e "$link" ]; then
            echo "delete $link"
            command rm -- "$link"
            ((deleted_count++))
        fi
    done
    IFS=$_IFS;unset _IFS
    if [ $deleted_count -eq 0 ]; then
        echo "nothing to do"
    fi
}
function git-svn(){
    if [[ ! -z "$1" && ! -z "$2" ]]; then
        echo "Starting clone/copy ..."
        repo=$(echo $1 | sed 's/\/$\|.git$//')
        svn export "$repo/trunk/$2"
    else
        echo "Use: git-svn <repository> <subdirectory>"
    fi
}
function prompt(){
    zinit ice as'command' from'gh-r' atload'export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml; eval $(starship init zsh)' atclone'./starship init zsh > init.zsh; ./starship completions zsh > _starship' atpull'%atclone' src'init.zsh'
    zinit light starship/starship
}
function set_title(){
    echo -n $'\e'"]0;$1"$'\a'
    [[ -n $WEZTERM_EXECUTABLE ]] && command -v wezterm 2>/dev/null >/dev/null && wezterm cli set-tab-title "$1"
}
function set_title(){
    echo -n $'\e'"]0;$1"$'\a'
    [[ -n $WEZTERM_EXECUTABLE ]] && command -v wezterm 2>/dev/null >/dev/null && wezterm cli set-tab-title "$1"
}


#usage:MAN <cmdname>

# stdout:Mdndocpath
# stderr:
function __getmanpath__(){
    local Mandocpath;
    if [[ -n $MANDOCPATH ]];then
        Mandocpath=$MANDOCPATH
    else
        Mandocpath="$HOME/.config/zsh/man"
    fi
    if [[ ! -d $Mandocpath ]];then
        echo 'mandocpath:'$Mandocpath' not found' >&2
        echo 'instead,you can export MANDOCPATH to use custom mandoc' >&2
        return 1
    fi
    echo $Mandocpath
    return 0
}
function MAN(){
    local Mandocpath;
    Mandocpath=$(__getmanpath__) || return 1

    if [[ $# -eq 0 ]];then
        command -v nvim && nvim --cmd "cd $Mandocpath" $Mandocpath && return 0
        command -v vim && vim --cmd "cd $Mandocpath" $Mandocpath && return 0
        ${EDITOR} $Mandocpath && return 0
        echo "no editor to edit $Mandocpath" && return 1
    fi
    if [[ $# -eq 1 && ($1 == '-h'||$1 == '--help') ]];then
        echo 'usage:'
        echo "\t$0                      编辑文档"
        echo "\t$0 <cmdname>            查阅文档"
        return 0;
    fi
    local cmdname=$1
    local prevtool;
    if command -v mdcat &>/dev/null;then
        prevtool="mdcat --paginate"
        elif command -v bat &>/dev/null;then
        prevtool="bat"
        elif command -v less &>/dev/null;then
        prevtool="less"
    else
        prevtool="more"
    fi
    local docpath="$Mandocpath/$cmdname.md"
    eval $prevtool "$docpath"
    return 0
}

function __MAN_completion__() {
    local Mandocpath;
    Mandocpath=$(__getmanpath__) || return 1
    local -a completions
    completions=( ${(f)"$( for i in $(command ls -A1 $Mandocpath); do echo ${i%.md}; done )"} )
    _describe 'command' completions
}
compdef __MAN_completion__ MAN
