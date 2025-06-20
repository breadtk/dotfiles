# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Automatically start or attach to a tmux session if not already in one.
if [ -z "$TMUX" ]; then
  if command -v tmux >/dev/null; then
    tmux new-session -A -s default
  fi
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
[[ -r "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"

# Use bash-completion, if available
[[ -r "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"

# Homebrew's 'bash-completion' package
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && source "/usr/local/etc/profile.d/bash_completion.sh"

# Various commands for $PROMPT_COMMAND.
__bashrc_prompt_command() {
    # Maintain a merged history across all shells.
    history -a
    history -c
    history -r
}
PROMPT_COMMAND="__bashrc_prompt_command"

[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

# Print your daily fortune.
if command -v fortune >/dev/null 2>&1; then
    fortune
fi
