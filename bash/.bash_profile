# Normally BASH will load .bash_profile on interactive logins only, but let's
# handle everything in .bashrc.
[[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
