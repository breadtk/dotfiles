##############
# Alias file #
##############

alias vi='vim'

alias grep='grep -i --color=auto'
alias ls='ls -Alh --color=auto'

alias rm='delete_securely'

# Allows aliased commands to carry over when sudoing.
alias sudo="sudo "

# Tries to delete using most to least secure method
function delete_securely {

    # Best option
    if [ $(command -v /usr/bin/srm) ]; then
        srm "$@"
        return
    fi  

    command -v rm "$@"
    return
}

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
    echo "'$1' is not a valid file to extract."
  fi  
}

