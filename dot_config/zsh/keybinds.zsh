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

# prepend sudo on the current commmand
bindkey -M emacs '' _sudo_command_line
bindkey -M vicmd '' _sudo_command_line
bindkey -M viins '' _sudo_command_line

# fix backspace and other stuff in vi-mode
bindkey -M viins '\e/' _vi_search_fix
bindkey "^H" backward-delete-char
#
bindkey "^U" backward-kill-line
# vim:ft=zsh:nowrap
