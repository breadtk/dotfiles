# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Automatically start or attach to a tmux session if not already in one.
if [ -z "$TMUX" ]; then
  tmux new-session -A -s default
fi

# Include Homebrew paths
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"

# Colorized prompt
export PS1="\[\e[32m\][\u@\h \W]\$\[\e[0m\] "

# <3
export VISUAL=nvim
export EDITOR=nvim

# XDG Base Directory support
# Source: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share

# BASH history options 
[ ! -d "$XDG_CACHE_HOME/bash/" ] && mkdir "$XDG_CACHE_HOME/bash/"
export HISTFILE=$XDG_CACHE_HOME/bash/.bash_history
export HISTCONTROL=ignoreboth
export HISTFILESIZE=1000000 # Line numbers to save
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:"
shopt -s histappend     # Always append, don't clobber the history file.

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X --incsearch --use-color"

# Alias definitions
if [ -f ~/.bash_aliases ]; then
    source ~/.bash_aliases
fi

# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    source /usr/share/bash-completion/bash_completion


# Homebrew's 'bash-completion' package
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && source "/usr/local/etc/profile.d/bash_completion.sh"

# Various commands for $PROMPT_COMMAND.
__bashrc_prompt_command() {
    # Catch exit code
    local ec=$?

    # Display exit code of last command in red text, unless zero.
    if [ $ec -ne 0 ];then
        echo -e "\033[31;1m[$ec]\033[0m"
    fi

    # Maintain a merged history across all shells.
    history -a
    history -c
    history -r
}
PROMPT_COMMAND="__bashrc_prompt_command"

. "$HOME/.local/share/../bin/env"
