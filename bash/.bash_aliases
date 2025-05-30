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
alias df='df -h'                                 # Readable sizes
alias du='du -h'                                 # Readable sizes
alias fuck='sudo $(history -p \!\!)'             # Retry last command via sudo
alias grep='grep -i --color=auto'                # Enable color and case insensitivity
alias less='less --incsearch --use-coor'
alias mkdir='mkdir -p'                           # Make dir and all intermediary dirs
alias rg='rg -i'                                 # Enable case insensitivity
alias scp='scp -Cpr'                             # Compress, preserve file metadata, and
                                                 # copy recursively.
alias sudo='sudo '                               # Allows aliased commands to carry over
                                                 # when sudoing.
alias vi='nvim'                                  # The one true god
alias vim='nvim'
alias weather='curl http://wttr.in/Seattle?FQnu' # Terminal weather. More options
                                                 # via /:help request.


#############
# Functions #
#############
# Compress files into various formats
c() {
    if [ "$#" -lt 2 ]; then
        echo "Usage: c <file/directory> [<file/directory> ...] <target.tar.[gz|bz2|xz|lz|Z|...]> or <target.zip>"
        return 1
    fi

    local target="${!#}"                # Last argument is the target
    local src=("${@:1:$#-1}")           # All arguments except the last one

    # Verify that all source files/directories exist
    for item in "${src[@]}"; do
        if [ ! -e "$item" ]; then
            echo "Error: '$item' does not exist."
            return 1
        fi
    done

    case "$target" in
        *.tar.*|*.tar)
            if command -v tar >/dev/null 2>&1; then
                if tar -caf "$target" "${src[@]}"; then
                    echo "Created archive '$target'."
                else
                    echo "Error: Failed to create archive."
                    return 1
                fi
            else
                echo "Error: 'tar' is not installed."
                return 1
            fi ;;
        *.zip)
            if command -v zip >/dev/null 2>&1; then
                if zip -r "$target" "${src[@]}"; then
                    echo "Created archive '$target'."
                else
                    echo "Error: Failed to create archive."
                    return 1
                fi
            else
                echo "Error: 'zip' is not installed."
                return 1
            fi ;;
        *)
            echo "Unsupported compression format: '$target'"
            echo "Supported formats are: .tar, .tar.gz, .tar.bz2, .tar.xz, .tar.lz, .tar.Z, .zip"
            return 1 ;;
    esac
}


# Extract/decompress common archive formats.
x() {
    if [ -z "$1" ]; then
        echo "Usage: x <archive-file>"
        return 1
    fi

    local archive="$1"

    if [ ! -f "$archive" ]; then
        echo "Error: '$archive' is not a valid archive file to extract."
        return 1
    fi

    case "$archive" in
        *.tar.*|*.tar)
            if command -v tar >/dev/null 2>&1; then
                if tar -xaf "$archive"; then
                    echo "Extracted '$archive'."
                else
                    echo "Error: Extraction failed."
                    return 1
                fi
            else
                echo "Error: 'tar' is not installed."
                return 1
            fi ;;
        *.zip)
            if command -v unzip >/dev/null 2>&1; then
                if unzip "$archive"; then
                    echo "Extracted '$archive'."
                else
                    echo "Error: Extraction failed."
                    return 1
                fi
            else
                echo "Error: 'unzip' is not installed."
                return 1
            fi ;;
        *)
            echo "Error: Unsupported archive format."
            echo "Supported formats are: .tar, .tar.gz, .tar.bz2, .tar.xz, .tar.lz, .tar.Z, .zip"
            return 1 ;;
    esac
}


# ls after every cd.
cd() {
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
