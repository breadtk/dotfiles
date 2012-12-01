##############
# Alias file #
##############

alias grep='grep -i --color=auto'
alias ls='ls -Alh --color=auto'

alias rm='delete_securely'
alias cd='cd_then_ls'

# Allows aliased commands to carry over when sudoing.
alias sudo="sudo "

# Tries to delete using most to least secure method
function delete_securely {

    if [ $(command -v srm) ]; then
        srm "$@"
        return
    fi  

    if [ $(command -v shred) ]; then
        shred --remove --random-source=/dev/urandom "$@"
        return
    fi  

    command -v rm "$@"
    return
}


function cd_then_ls {
	if [ $# -ge 1 ]; then
		cd $1
	else
		cd $HOME
	fi
	
	ls
	echo "Directory: $(pwd)"
}
