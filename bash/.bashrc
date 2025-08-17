# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

# Include common path entries.
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$PATH:~/.lmstudio/bin"

# Colorized prompt
export PS1="\[\e[32m\][\u@\h \W]\$\[\e[0m\] "

# fzf
## Fast preview command for fzf later on.
if command -v bat >/dev/null 2>&1; then
    _fzf_preview='bat -n --color=always --line-range :300 {}'
else
    _fzf_preview='head -n 300 {} 2>/dev/null'
fi

# Avoid conflict with bash ** globstar; set BEFORE sourcing integration
export FZF_COMPLETION_TRIGGER='//'

# Prefer built-in integration (fzf >= 0.48)
if fzf --bash >/dev/null 2>&1; then
    # New walker-based bindings (no fd/rg needed)
    export FZF_CTRL_T_OPTS=$(
        printf "%s" \
            "--height=40% --layout=reverse --border " \
            "--walker file,dir,follow,hidden" \
            "--walker-skip .git,node_modules,target,.venv" \
            "--preview '$_fzf_preview' " \
            "--bind ctrl-/:toggle-preview,ctrl-f:toggle-sort,ctrl-d:half-page-down,ctrl-u:half-page-up"
        )
        export FZF_ALT_C_OPTS="
        --height=40%
        --layout=reverse
        --border
        --walker dir,follow,hidden
        --walker-skip .git,node_modules,target
        --preview 'tree -C {} | head -n 200'"
        export FZF_CTRL_R_OPTS="--height=40% --layout=reverse --border --exact"
        eval "$(fzf --bash)"
    else
        # Fedora auto-completion integration
        for f in \
            /usr/share/fzf/shell/key-bindings.bash \
            /usr/share/doc/fzf/examples/key-bindings.bash
        do [[ -r $f ]] && source "$f" && break; done

  # Debian auto-completion integration
  for f in \
      /usr/share/fzf/shell/completion.bash \
      /usr/share/doc/fzf/examples/completion.bash \
      /etc/bash_completion.d/fzf
  do [[ -r $f ]] && source "$f" && break; done

  # Default fzf options.
  export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border
  --preview '$_fzf_preview'
  --bind ctrl-/:toggle-preview,ctrl-f:toggle-sort,ctrl-d:half-page-down,ctrl-u:half-page-up"
  export FZF_CTRL_R_OPTS="
  --height=40%
  --layout=reverse
  --border
  --exact"
fi

# <3
export VISUAL=nvim
export EDITOR=nvim

# XDG Base Directory support
# Source: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share

# Automatically start or attach to a tmux session if not already in one. Must
# occur after XDG setup since there are settings which depend on those being
# setup.
if [ -z "$TMUX" ]; then
    if command -v tmux >/dev/null; then
        tmux new-session -A -s default
    fi
fi

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

export LEDGER_FILE="$HOME/blackhole/docs/finance/hledger/surkatty_books.journal"

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
    fortune -s
fi

# Include homebrew path funtimes
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
