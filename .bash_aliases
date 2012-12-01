##############
# Alias file #
##############

alias rm='delete_securely'
alias grep='grep -i --color=auto'
alias ls='ls -Alh --color=auto'

function delete_securely {

    # Most secure
    if [ $(command -v srm) ]; then
        srm "$@"
        return
    fi  

    # Less secure
    if [ $(command -v shred) ]; then
        shred --remove --random-source=/dev/urandom "$@"
        return
    fi  

    # Not secure
    command -v rm "$@"
    return
}
