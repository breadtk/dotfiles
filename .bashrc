# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Include Homebrew paths
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"

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
    . ~/.bash_aliases
fi

# Enable BASH command completion
if [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# Homebrew's 'bash-completion' package
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"


# Ensure ssh-agent is always running on logon.
# Source: http://mah.everybody.org/docs/ssh
SSH_ENV="$HOME/.ssh/environment"
function start_agent {
     echo "Initialising new SSH agent..."
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
     echo succeeded
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     /usr/bin/ssh-add;
}
# Source SSH settings, if applicable
if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi
