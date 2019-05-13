# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Colorized prompt
export PS1="\[$(tput setaf 2)\][\u@\h \W]\\$ \[$(tput sgr0)\]"

# Enable color elsewhere
export TERM=xterm-256color
export CLICOLOR=1
export LSCOLORS=ExFxCxDxBxegedabagacad

# <3
export EDITOR=vim

# BASH history options 
export HISTFILE=~/.bash_history
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000 # Line numbers to save
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:"

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X"

# Alias definitions
if [ -f ~/.bash_aliases ]; then
    (. ~/.bash_aliases &)
fi

# Enable auto completion
if [ -f /etc/bash_completion ]; then
    (. /etc/bash_completion &)
fi
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    (. $(brew --prefix)/etc/bash_completion &)
fi
