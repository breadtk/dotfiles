# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# <3
export EDITOR=vim

# Various history related options.
export HISTFILE='~/.bash_history'
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000

# Alias definitions.
if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases 
fi

# Enable auto completion
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi
