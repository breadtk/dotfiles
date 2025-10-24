# If not running interactively, don't do anything.
[ -z "$PS1" ] && return

#################
# BASH/Terminal #
#################

# Colorized prompt
export PS1="\[\e[32m\][\u@\h \W]\$\[\e[0m\] "

# <3
export VISUAL=nvim
export EDITOR=nvim

# Include common PATH entries.
export PATH=/usr/local/sbin:$PATH
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$PATH:"$HOME/.lmstudio/bin"

# Homebrew paths
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# shellcheck disable=SC1091
[[ -r "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

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
# shellcheck disable=SC1091
[[ -r "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"


###############
# Completions #
###############
# Setup bash-completion.
# shellcheck disable=SC1091
[[ -r "/usr/share/bash-completion/bash_completion" ]] && source "/usr/share/bash-completion/bash_completion"

# Homebrew's 'bash-completion' package
# shellcheck disable=SC1091
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && source "/usr/local/etc/profile.d/bash_completion.sh"

# GitHub CLI completions
if command -v gh >/dev/null 2>&1; then
    eval "$(gh completion -s bash)"
fi

# HACK: Maintain a merged history across all shells. This allows `history` to
# persist across shells.
__bashrc_prompt_command() {
    history -a
    history -c
    history -r
}
PROMPT_COMMAND="__bashrc_prompt_command"


########################
# Application Specific #
########################

# Automatically start and/or attach to a tmux session if not currently in one.
# This _must_ occur after XDG setup since there are settings which depend on
# those being setup.
if [ -z "$TMUX" ]; then
    if command -v tmux >/dev/null; then
        tmux new-session -A -s default
    fi
fi

# Hledger options
export LEDGER_FILE="$HOME/blackhole/docs/finance/hledger/surkatty_books.journal"

# Print your daily fortune.
if command -v fortune >/dev/null 2>&1; then
    fortune -s
fi


#############
# fzf setup #
#############
## Preview command helper, used by other fzf options.
if command -v bat >/dev/null 2>&1; then
    _fzf_preview='bat -n --color=always --line-range :300 {}'
else
    _fzf_preview='head -n 300 {} 2>/dev/null'
fi

# Avoid conflict with bash ** globstar; set BEFORE sourcing integration
export FZF_COMPLETION_TRIGGER='//'

# Prefer built-in integration (fzf >= 0.48)
if fzf --bash >/dev/null 2>&1; then
    # FZF_CTRL_T_OPTS: assign, then export (no SC2155)
    FZF_CTRL_T_OPTS="$(
        cat <<EOF
        --height=40%
        --layout=reverse
        --border
        --walker file,dir,follow,hidden
        --walker-skip .git,node_modules,target,.venv
        --preview '$_fzf_preview'
        --bind ctrl-/:toggle-preview,ctrl-f:toggle-sort,ctrl-d:half-page-down,ctrl-u:half-page-up
EOF
)"
export FZF_CTRL_T_OPTS

FZF_ALT_C_OPTS="$(
    cat <<'EOF'
    --height=40%
    --layout=reverse
    --border
    --walker dir,follow,hidden
    --walker-skip .git,node_modules,target
    --preview 'tree -C {} | head -n 200'
EOF
)"
export FZF_ALT_C_OPTS

export FZF_CTRL_R_OPTS=$'--height=40%\n--layout=reverse\n--border\n--exact'

eval "$(fzf --bash)"
else
    # Fedora auto-completion
    if [[ -r /usr/share/fzf/shell/key-bindings.bash ]]; then
        # shellcheck source=/usr/share/fzf/shell/key-bindings.bash
        # shellcheck disable=SC1091
        . /usr/share/fzf/shell/key-bindings.bash
    elif [[ -r /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
        # shellcheck source=/usr/share/doc/fzf/examples/key-bindings.bash
        # shellcheck disable=SC1091
        . /usr/share/doc/fzf/examples/key-bindings.bash
    fi

    # Debian auto-completion
    if [[ -r /usr/share/fzf/shell/completion.bash ]]; then
        # shellcheck source=/usr/share/fzf/shell/completion.bash
        # shellcheck disable=SC1091
        . /usr/share/fzf/shell/completion.bash
    elif [[ -r /usr/share/doc/fzf/examples/completion.bash ]]; then
        # shellcheck source=/usr/share/doc/fzf/examples/completion.bash
        # shellcheck disable=SC1091
        . /usr/share/doc/fzf/examples/completion.bash
    elif [[ -r /etc/bash_completion.d/fzf ]]; then
        # shellcheck source=/etc/bash_completion.d/fzf
        # shellcheck disable=SC1091
        . /etc/bash_completion.d/fzf
    fi

    FZF_DEFAULT_OPTS="$(
        cat <<EOF
        --height=40%
        --layout=reverse
        --border
        --preview '$_fzf_preview'
        --bind ctrl-/:toggle-preview,ctrl-f:toggle-sort,ctrl-d:half-page-down,ctrl-u:half-page-up
EOF
)"
export FZF_DEFAULT_OPTS
export FZF_CTRL_R_OPTS=$'--height=40%\n--layout=reverse\n--border\n--exact'
fi
