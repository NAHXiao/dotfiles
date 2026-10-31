##
## Keybindings
##
#其实end-of-line就可以accept autosuggest(C-E,C-F)
# bindkey '^[l' autosuggest-accept
# bindkey "^[\'" autosuggest-accept


bindkey '^[[1;5D' emacs-backward-word
bindkey '^[[1;5C' emacs-forward-word

#Home = C-A
bindkey '^[[H' beginning-of-line
#End = C-E
bindkey '^[[F' end-of-line

bindkey -s '^J' '^M'
bindkey -s '^K' 'ls^M'

bindkey "^U" backward-kill-line
# vim:ft=zsh:nowrap
