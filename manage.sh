#!/usr/bin/env bash
#
# manage.sh  —  install / update / remove / uninstall dot-files with GNU Stow
#
#   install    clone or use existing ~/dotfiles repo, back-up collisions,
#              then stow every package
#   update     git pull && restow (refresh links after you edit files)
#   remove     unstow everything but keep the repo
#   uninstall  unstow and delete ~/dotfiles entirely
#
#   Example:   ./manage.sh install
#
set -euo pipefail

REPO_URL="https://github.com/breadtk/dotfiles.git"
DOTFILES_DIR="${HOME}/dotfiles"
BACKUP_DIR="${DOTFILES_DIR}/.backup_pre_stow"
SKIP_RE='^\.(git|backup_pre_stow)|^\.?github$'
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOOLS_FILE="${DOTFILES_DIR}/tools.json"
[[ -f "$TOOLS_FILE" ]] || TOOLS_FILE="${SCRIPT_DIR}/tools.json"

packages() {
    find "${DOTFILES_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
        grep -Ev "${SKIP_RE}" | sort
}

dry_ok() {
    ! stow -nv "$1" 2>&1 | grep -q 'existing target is neither'
}

backup_conflicts() {
    local pkg=$1 line file
    stow -nv "${pkg}" 2>&1 | while read -r line; do
        [[ $line =~ existing\ target\ is\ neither ]] || continue
        file=${line##*: }
        mkdir -p "${BACKUP_DIR}/${pkg}/$(dirname "${file}")"
        mv -v "${HOME}/${file}" "${BACKUP_DIR}/${pkg}/${file}"
    done
}

detect_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then echo "apt-get"
    elif command -v dnf    >/dev/null 2>&1; then echo "dnf"
    else return 1
    fi
}

ensure_packages_installed() {
    [[ -f "$TOOLS_FILE" ]] || { echo "❌  tools manifest missing at $TOOLS_FILE"; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "❌  jq is required. Install it first."; exit 1; }

    local manager
    manager=$(detect_package_manager) || { echo "❌  No supported package manager (apt-get or dnf)."; exit 1; }

    local -a missing=()
    while IFS=$'\t' read -r cmd pkg; do
        command -v "$cmd" &>/dev/null || missing+=("$pkg")
    done < <(jq -r --arg mgr "$manager" '
        .system_package[]? |
        if   type == "string" then [., .]
        elif has($mgr)        then [.cmd, .[$mgr]]
        else                       [.cmd, .pkg]
        end | @tsv
    ' "$TOOLS_FILE")

    ((${#missing[@]} == 0)) && return

    echo "❌  Missing tools: ${missing[*]}"
    echo "    Run: sudo $manager install ${missing[*]}"
    exit 1
}

install_pkg() { backup_conflicts "$1"; stow -v  "$1"; }
restow_pkg()  { backup_conflicts "$1"; stow -vR "$1"; }
unstow_pkg()  { stow -vD "$1"; }

cmd=${1:-help}

case $cmd in
    install|update)
        ensure_packages_installed
        [[ -d ${DOTFILES_DIR}/.git ]] || git clone --recursive "$REPO_URL" "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
        [[ $cmd == update ]] && git pull --ff-only

        to_do=()
        for p in $(packages); do
            dry_ok "$p" && to_do+=("$p")
        done

        if ((${#to_do[@]} == 0)); then
            echo "Nothing to $cmd — every package has a conflict."
            exit 0
        fi

        echo "Packages with NO conflicts:"
        printf '  - %s\n' "${to_do[@]}"
        read -rp "Proceed to $cmd these packages? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

        for p in "${to_do[@]}"; do
            if [[ $cmd == install ]]; then install_pkg "$p"; else restow_pkg "$p"; fi
        done
        echo "✅  $cmd complete. Backups in ${BACKUP_DIR}"
        ;;

    remove)
        cd "$DOTFILES_DIR"
        for p in $(packages); do unstow_pkg "$p"; done
        echo "✅  Symlinks removed, repo kept."
        ;;

    uninstall)
        cd "$DOTFILES_DIR"
        for p in $(packages); do unstow_pkg "$p"; done
        cd "$HOME" && rm -rf "$DOTFILES_DIR"
        echo "✅  Repo and links deleted."
        ;;

    *)
        echo "Usage: $(basename "$0") { install | update | remove | uninstall }"
        exit 1 ;;
esac
