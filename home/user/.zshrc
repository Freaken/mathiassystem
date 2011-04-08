# my silly prompt {{{
#autoload -U promptinit
#promptinit
#prompt adam2 gray yellow green white
RPS1='[%*]'
PS1=$'%{\e[01;%(!.31.32)m%}%n@%m:%{\e[01;34m%}%~%(!.#.$) %{\e[0m%}'
# }}}
# completion {{{
. ~/.zshcomplete
# }}}
# history {{{
HISTFILE=$HOME/.history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_expire_dups_first
# }}}
# plugins {{{
autoload copy-earlier-word
zle -N copy-earlier-word

autoload edit-command-line
zle -N edit-command-line
# }}}
# miscellaneous options {{{
setopt nobeep # I hates the beeps
setopt multios # built-in tee
setopt extended_glob
setopt nullglob # it's not an error for a glob to expand to nothing
setopt list_ambiguous
setopt no_nomatch
setopt interactivecomments # Allow comments even in the interactive shell
setopt listpacked # column width doesn't have to be constant
setopt complete_in_word # hitting tab on the f in Mafile does the right thing
setopt nohup # Don't kill jobs when I exit
# }}}
# replace default utilities {{{
alias top="htop"
# }}}
# add color to some things {{{
alias ls='ls -G --color'
alias grep='grep --color=auto'
alias ack='ack --color'
# }}}
# shortcuts {{{
alias less='less -R'
# }}}
# keybinds {{{
bindkey -v

bindkey '^[[A' up-history
bindkey '^[[B' down-history

# Fix a few keys in putty
bindkey '^[OH' beginning-of-line
bindkey '^[[2~' overwrite-mode
bindkey '^[[3~' delete-char
bindkey '^[OF' end-of-line

bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# History search on ^R
bindkey '^R' history-incremental-search-backward
# }}}
# utilities {{{
# Enable autojump goodness
.  /usr/share/autojump/autojump.zsh
# }}}
# aliases {{{
alias grep='grep --color=auto'
alias ls='ls --color=auto'

alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
alias ssh='(ssh-add -l | grep -q "id_dsa" || ssh-add ~/.ssh/id_dsa); ssh'
alias scp='(ssh-add -l | grep -q "id_dsa" || ssh-add ~/.ssh/id_dsa); scp'
alias apt-get='sudo apt-get'
alias dpkg='sudo dpkg'
# }}}
