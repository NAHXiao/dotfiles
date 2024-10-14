##
## Utility Functions
##
function unset_proxy(){
unset http_proxy
unset https_proxy
unset HTTP_PROXY
unset HTTPS_PROXY
unset socks_proxy
}
function set_proxy(){
export http_proxy=http://$1
export https_proxy=http://$1
export HTTP_PROXY=http://$1
export HTTPS_PROXY=http://$1
export socks_proxy=socks5://$1
}
function auto_proxy(){
    local ip="localhost"
    if command -v curl &>/dev/null;then
        cmd='curl --connect-timeout 0.5 -s -x $ip:$port http://baidu.com -o/dev/null'
    elif command -v nc &>/dev/null ;then 
        cmd='nc -vz $ip $port' 
    else
        return
    fi
    echo "cmd=$cmd"
    local arr=(7890 )
    for port in ${arr[@]};do
       echo $cmd
       if eval $cmd &>/dev/null ; then
           set_proxy $ip:$port
           echo "set proxy to $ip:$port"
           break
       fi
    done
}
function _smooth_fzf() {
  local fname
  local current_dir="$PWD"
  cd "${XDG_CONFIG_HOME:-~/.config}"
  fname="$(fzf)" || return
  $EDITOR "$fname"
  cd "$current_dir"
}
function _sudo_replace_buffer() {
  local old=$1 new=$2 space=${2:+ }
  # if the cursor is positioned in the $old part of the text, make
  # the substitution and leave the cursor after the $new text
  if [[ $CURSOR -le ${#old} ]]; then
    BUFFER="${new}${space}${BUFFER#$old }"
    CURSOR=${#new}
  # otherwise just replace $old with $new in the text before the cursor
  else
    LBUFFER="${new}${space}${LBUFFER#$old }"
  fi
}
function _sudo_command_line() {
  # If line is empty, get the last run command from history
  [[ -z $BUFFER ]] && LBUFFER="$(fc -ln -1)"
  # Save beginning space
  local WHITESPACE=""
  if [[ ${LBUFFER:0:1} = " " ]]; then
    WHITESPACE=" "
    LBUFFER="${LBUFFER:1}"
  fi
  {
    # If $SUDO_EDITOR or $VISUAL are defined, then use that as $EDITOR
    # Else use the default $EDITOR
    local EDITOR=${SUDO_EDITOR:-${VISUAL:-$EDITOR}}

    # If $EDITOR is not set, just toggle the sudo prefix on and off
    if [[ -z "$EDITOR" ]]; then
      case "$BUFFER" in
        sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "" ;;
        sudo\ *) _sudo_replace_buffer "sudo" "" ;;
        *) LBUFFER="sudo $LBUFFER" ;;
      esac
      return
    fi

    # Check if the typed command is really an alias to $EDITOR
    # Get the first part of the typed command
    local cmd="${${(Az)BUFFER}[1]}"
    # Get the first part of the alias of the same name as $cmd, or $cmd if no alias matches
    local realcmd="${${(Az)aliases[$cmd]}[1]:-$cmd}"
    # Get the first part of the $EDITOR command ($EDITOR may have arguments after it)
    local editorcmd="${${(Az)EDITOR}[1]}"

    # Note: ${var:c} makes a $PATH search and expands $var to the full path
    # The if condition is met when:
    # - $realcmd is '$EDITOR'
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "cmd --with --arguments"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "cmd"
    # - $realcmd is "/path/to/cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is "cmd"
    # - $realcmd is "cmd" and $EDITOR is "/path/to/cmd"
    # or
    # - $realcmd is "cmd" and $EDITOR is /alternative/path/to/cmd that appears in $PATH
    if [[ "$realcmd" = (\$EDITOR|$editorcmd|${editorcmd:c}) \
      || "${realcmd:c}" = ($editorcmd|${editorcmd:c}) ]] \
      || builtin which -a "$realcmd" | command grep -Fx -q "$editorcmd"; then
      _sudo_replace_buffer "$cmd" "sudo -e"
      return
    fi

    # Check for editor commands in the typed command and replace accordingly
    case "$BUFFER" in
      $editorcmd\ *) _sudo_replace_buffer "$editorcmd" "sudo -e" ;;
      \$EDITOR\ *) _sudo_replace_buffer '$EDITOR' "sudo -e" ;;
      sudo\ -e\ *) _sudo_replace_buffer "sudo -e" "$EDITOR" ;;
      sudo\ *) _sudo_replace_buffer "sudo" "" ;;
      *) LBUFFER="sudo $LBUFFER" ;;
    esac
  } always {
    # Preserve beginning space
    LBUFFER="${WHITESPACE}${LBUFFER}"

    # Redisplay edit buffer (compatibility with zsh-syntax-highlighting)
    zle redisplay
  }
}
function _vi_search_fix() {
  zle vi-cmd-mode
  zle .vi-history-search-backward
}
function toppy() {
    history | awk '{CMD[$2]++;count++;}END { for (a in CMD)print CMD[a] " " CMD[a]/count*100 "% " a;}' | grep -v "./" | column -c3 -s " " -t | sort -nr | nl |  head -n 21
}
function cd() {
	builtin cd "$@" && command ls --group-directories-first --color=auto -F
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
function MAN(){
    if [[ $# -eq 0 ]];then 
        echo 'usage:MAN <cmdname>'
        return;
    fi
    local cmdname=$1
    local prevtool;
    if command -v bat &>/dev/null;then
        prevtool="bat"
    elif command -v less &>/dev/null;then
        prevtool="less"
    else
        prevtool="more"
    fi
    local Mandocpath;
    if [[ -n $mandocpath ]];then
        Mandocpath=$mandocpath
    else
        Mandocpath="$HOME/.config/zsh/man"
    fi
    if [[ ! -d $Mandocpath ]];then
        echo 'mandocpath:'$Mandocpath' not found'
        echo 'instead,you can export mandocpath to use custom mandoc'
        return
    fi
    local docpath="$Mandocpath/$cmdname.md"
    eval $prevtool "$docpath"
}

function _MAN_completion() {
    local Mandocpath;
    if [[ -n $mandocpath ]];then
        Mandocpath=$mandocpath
    else
        Mandocpath="$HOME/.config/zsh/man"
    fi
    
    local -a completions
    completions=( ${(f)"$( for i in $(command ls -A1 $Mandocpath); do echo ${i%.md}; done )"} )
    
    _describe 'command' completions
}
compdef _MAN_completion MAN
