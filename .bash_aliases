##############
# Alias file #
##############

# macOS vs Linux specific aliases
if [[ $(uname -a) == "Darwin"* ]]; then
    alias ls='ls -alhG'
else
    alias ls='ls -alh --color=always'
fi

###################
# General aliases #
###################
alias df='df -h'                     # Readable sizes
alias du='du -h'                     # Readable sizes
alias fuck='sudo $(history -p \!\!)' # Retry last command via sudo
alias grep='grep -i --color=auto'    # Enable color and case insensitivity
alias less='less --incsearch --use-color'
alias mkdir='mkdir -p'               # Make dir and all intermediary dirs
alias rg='rg -i'                     # Enable case insensitivity
alias scp='scp -Cpr'                 # Compress, preserve file metadata, and
                                     # copy recursively.
alias sudo='sudo '                   # Allows aliased commands to carry over
                                     # when sudoing.
alias vi='v'                         # The one true god
alias vim='v'
alias weather='curl http://wttr.in/Seattle?FQnu' # Terminal weather. More options
                                                 # via /:help request.

#############
# Functions #
#############

# Compress files into various formats
c () {
    if [ -z "$2" ]; then
        echo "Usage: c <file/directory> <target.extension>"
        return 1
    fi

    local src="$1"
    local target="$2"

    if [ ! -e "$src" ]; then
        echo "'$src' does not exist."
        return 1
    fi

    case "$target" in
        *.tar.bz2|*.tbz2)
            command -v tar >/dev/null 2>&1 && tar cvjf "$target" "$src" || echo "tar is not installed." ;;
        *.tar.gz|*.tgz)
            command -v tar >/dev/null 2>&1 && tar cvzf "$target" "$src" || echo "tar is not installed." ;;
        *.tar.xz|*.txz)
            command -v tar >/dev/null 2>&1 && tar cvJf "$target" "$src" || echo "tar is not installed." ;;
        *.tar)
            command -v tar >/dev/null 2>&1 && tar cvf "$target" "$src" || echo "tar is not installed." ;;
        *.7z)
            command -v 7z >/dev/null 2>&1 && 7z a "$target" "$src" || echo "7z is not installed." ;;
        *.rar)
            command -v rar >/dev/null 2>&1 && rar a "$target" "$src" || echo "rar is not installed." ;;
        *.gz)
            if [ -d "$src" ]; then
                echo "gzip does not support compressing directories."
            else
                command -v gzip >/dev/null 2>&1 && gzip -c "$src" > "$target" || echo "gzip is not installed."
            fi ;;
        *.bz2)
            if [ -d "$src" ]; then
                echo "bzip2 does not support compressing directories."
            else
                command -v bzip2 >/dev/null 2>&1 && bzip2 -c "$src" > "$target" || echo "bzip2 is not installed."
            fi ;;
        *.xz)
            if [ -d "$src" ]; then
                echo "xz does not support compressing directories."
            else
                command -v xz >/dev/null 2>&1 && xz -c "$src" > "$target" || echo "xz is not installed."
            fi ;;
        *.zip)
            command -v zip >/dev/null 2>&1 && zip -r "$target" "$src" || echo "zip is not installed." ;;
        *) echo "Unsupported compression format: '$target'" ;;
    esac
}


x () {
    if [[ -f "$1" ]]; then
        case $1 in
            *.tar.bz2|*.tbz2)
                command -v tar >/dev/null 2>&1 && tar xvjf "$1" || echo "tar is not installed. Consider installing it." ;;
            *.tar.gz|*.tgz)
                command -v tar >/dev/null 2>&1 && tar xvzf "$1" || echo "tar is not installed. Consider installing it." ;;
            *.tar.xz|*.txz)
                command -v tar >/dev/null 2>&1 && tar xvJf "$1" || echo "tar is not installed. Consider installing it." ;;
            *.tar)
                command -v tar >/dev/null 2>&1 && tar xvf "$1" || echo "tar is not installed. Consider installing it." ;;
            *.7z)
                command -v 7z >/dev/null 2>&1 && 7z x "$1" || echo "7z is not installed. Consider installing p7zip or a similar package." ;;
            *.rar)
                if command -v unrar >/dev/null 2>&1; then
                    unrar x "$1"
                elif command -v rar >/dev/null 2>&1; then
                    rar x "$1"
                else
                    echo "Neither rar nor unrar is installed. Consider installing one of these utilities."
                fi ;;
            *.gz)
                command -v gunzip >/dev/null 2>&1 && gunzip "$1" || echo "gunzip is not installed. Consider installing it." ;;
            *.bz2)
                command -v bunzip2 >/dev/null 2>&1 && bunzip2 "$1" || echo "bunzip2 is not installed. Consider installing it." ;;
            *.Z)
                command -v uncompress >/dev/null 2>&1 && uncompress "$1" || echo "uncompress is not installed. Consider installing ncompress or a similar package." ;;
            *.xz)
                command -v xz >/dev/null 2>&1 && xz -d "$1" || echo "xz is not installed. Consider installing xz-utils or a similar package." ;;
            *.zip)
                command -v unzip >/dev/null 2>&1 && unzip "$1" || echo "unzip is not installed. Consider installing it." ;;
            *) echo "'$1' cannot be extracted via x()" ;;
        esac
    else
        echo "'$1' is not a valid file to extract."
    fi
}


# ls after every cd.
cd () {
    builtin cd "$@" && ls;
}


# Search for files matching particular filenames using fzf and ripgrep.
f() {
  if [ "$#" -eq 0 ]; then
    echo "Need a string to search for!"
    return 1
  fi
  rg --files-with-matches --hidden --no-ignore --no-messages "$1" | \
  fzf --query="$1" \
      --preview "highlight -O ansi -l {} 2> /dev/null | \
                 rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' {} || \
                 rg --ignore-case --pretty --context 10 '$1' {}"
}

# Edit file with nvim or use fzf, through f(), to look for it, and then open it.
v() {
    if [ -n "$1" ] && [ -f "$1" ]; then
        # If the file exists, open it
        $EDITOR "$1"
    else
        local pattern="$1"
        # Expand tilde to $HOME if present
        pattern="${pattern/#\~/$HOME}"

        # Use fd if available for better performance
        if command -v fd >/dev/null 2>&1; then
            local file
            # Use fd to find files matching the pattern, including hidden files
            file=$(fd --hidden --no-ignore --type f --glob "$(basename "$pattern")*" "$(dirname "$pattern")" 2>/dev/null | \
                   fzf --query="$pattern" \
                       --preview "highlight -O ansi -l {} 2> /dev/null || cat {}")
        else
            # Fallback to find if fd is not available
            local file
            file=$(find "$(dirname "$pattern")" -type f -iname "$(basename "$pattern")*" 2>/dev/null | \
                   fzf --query="$pattern" \
                       --preview "highlight -O ansi -l {} 2> /dev/null || cat {}")
        fi

        if [[ -n $file ]]; then
            $EDITOR "$file"
        else
            # If no file is selected, open a new file with the given name
            $EDITOR "$1"
        fi
    fi
}
