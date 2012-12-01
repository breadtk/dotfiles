# If not running interactively, don't do anything
[ -z "$PS1" ] && return

#
set EDITOR=vim

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

# Allows for any file to be extracted using: x $1
x () {
  if [ -f $1 ] ; then
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
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file to extra."
  fi
}
