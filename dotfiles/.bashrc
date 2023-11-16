alias ll='ls -al --color='auto''
alias ls='ls --color='auto''
alias CC='cc'
#fzf使用ripgrep
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
  export FZF_DEFAULT_OPTS='-m'
fi


. "$HOME/.cargo/env"
