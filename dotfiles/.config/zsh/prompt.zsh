##
## Prompt
##

# Load starship
if [[ $TERM_PROGRAM == 'WezTerm' ]]&& [[ -z $NVIM ]]; then
zinit ice as'command' from'gh-r' \
  atload'export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship/starship.toml; eval $(starship init zsh)' \
  atclone'./starship init zsh > init.zsh; ./starship completions zsh > _starship' \
  atpull'%atclone' src'init.zsh'
zinit light starship/starship
else
		export PS1="[%n %~ $] "
fi

# vim:ft=zsh
