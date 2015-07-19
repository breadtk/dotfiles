##############
# Alias file #
##############

# OS X vs Linux specific aliases
if [[ $(uname -a) == "Darwin"* ]]; then
    alias f='find . | grep -iE --color $*'
    alias ls='ls -alhG'
    alias rm='srm -fsz' # Not forensically sound, but better than nothing.
else
    alias f='find . | grep -iP --color $*'
    alias ls='ls -alh --color=auto'
fi

###################
# General aliases #
###################
alias df='df -h'                    # Readable sizes
alias du='du -h'                    # Readable sizes
alias grep='grep -i --color=auto'   # Enable color and case insensitivity
alias mkdir='mkdir -p'              # Make dir but create intermediary dirs
alias scp='scp -p'                  # Scp with preserving times and recursion
alias sudo='sudo '                  # Allows aliased commands to carry over when sudoing.
alias vi='vim'                      # The one true god

#############
# Functions #
#############

# Extract just about any file using: x $1
x () {
    if [ -f $1 ]; then
        case $1 in
            *.tar.bz2)   tar xjf $1 ;;
            *.tar.gz)    tar xzf $1 ;;
            *.bz2)       bunzip2 $1 ;;
            *.rar)       rar x $1 ;;
            *.gz)        gunzip $1 ;;
            *.tar)       tar xvf $1 ;;
            *.tbz2)      tar xjf $1 ;;
            *.tgz)       tar xzf $1 ;;
            *.zip)       unzip $1 ;;
            *.Z)         uncompress $1 ;;
            *.7z)        7za x $1 ;;
            *.xz)        xz -d $1 ;;
            *)           echo "'$1' cannot be extracted via x()" ;;
        esac
    else
        echo "'$1' is not a valid file to extract."
    fi
}
