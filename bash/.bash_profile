# Normally BASH will load .bash_profile on interactive logins only, but let's
# handle everything in .bashrc.
# shellcheck disable=SC1091
[[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/osman/.lmstudio/bin"
