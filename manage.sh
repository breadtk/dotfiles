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
SKIP_RE='^\.(git|backup_pre_stow|claude)|^\.?github$'
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOOLS_FILE="${DOTFILES_DIR}/tools.json"
[[ -f "$TOOLS_FILE" ]] || TOOLS_FILE="${SCRIPT_DIR}/tools.json"

packages() {
    find "${DOTFILES_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
        grep -Ev "${SKIP_RE}" | sort
}

manifest_values() {
    local key=$1
    [[ -f "$TOOLS_FILE" ]] || { echo "❌  tools manifest missing at $TOOLS_FILE"; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "❌  jq is required to read ${TOOLS_FILE}. Install jq first."; exit 1; }
    jq -r --arg key "$key" '
        if has($key) and (.[$key] | type == "array") then
            .[$key][]?
        else
            empty
        end
    ' "$TOOLS_FILE"
}

detect_system_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt-get"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    else
        return 1
    fi
}

system_package_installed() {
    local manager=$1 pkg=$2
    case "$manager" in
        apt-get) dpkg -s "$pkg" >/dev/null 2>&1 ;;
        dnf)     rpm  -q "$pkg" >/dev/null 2>&1 ;;
        *)       return 1 ;;
    esac
}

install_system_packages() {
    local manager=$1; shift
    local -a maybe_sudo=(); (( EUID != 0 )) && maybe_sudo=(sudo)
    case "$manager" in
        apt-get) "${maybe_sudo[@]}" apt-get install -y "$@" ;;
        dnf)     "${maybe_sudo[@]}" dnf     install -y "$@" ;;
        *) echo "❌  Unsupported package manager: $manager"; return 1 ;;
    esac
}

brew_package_installed()         { brew list --formula "$1" >/dev/null 2>&1; }
snap_classic_package_installed() { snap list "$1" >/dev/null 2>&1; }

install_snap_classic_packages() {
    local -a maybe_sudo=(); (( EUID != 0 )) && maybe_sudo=(sudo)
    for pkg in "$@"; do
        "${maybe_sudo[@]}" snap install --classic "$pkg"
    done
}

# install_block LABEL CHECK_CMD PKGS_VAR INSTALL_CMD...
# Finds missing packages via CHECK_CMD, prompts, installs, then verifies.
install_block() {
    local label=$1 check_cmd=$2 pkgs_var=$3; shift 3
    local -n _pkgs=$pkgs_var
    [[ ${#_pkgs[@]} -eq 0 ]] && return 0

    local -a missing=()
    local pkg
    for pkg in "${_pkgs[@]}"; do
        $check_cmd "$pkg" || missing+=("$pkg")
    done
    [[ ${#missing[@]} -eq 0 ]] && return 0

    echo "${label} packages missing: ${missing[*]}"
    read -rp "Install missing ${label} packages? [y/N] " reply
    [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
    "$@" "${missing[@]}"

    local -a failed=()
    for pkg in "${missing[@]}"; do
        $check_cmd "$pkg" || failed+=("$pkg")
    done
    if ((${#failed[@]})); then
        echo "❌  Failed to install ${label} packages: ${failed[*]}"
        exit 1
    fi
}

ensure_packages_installed() {
    local -a system_packages=() snap_classic_packages=() brew_packages=()
    readarray -t system_packages       < <(manifest_values "system_package")
    readarray -t snap_classic_packages < <(manifest_values "snap_classic")
    readarray -t brew_packages         < <(manifest_values "brew")

    local manager
    manager=$(detect_system_package_manager || true)
    if ((${#system_packages[@]})) && [[ -z ${manager:-} ]]; then
        echo "❌  No supported system package manager found, but system packages are required."
        exit 1
    fi
    if ((${#snap_classic_packages[@]})); then
        command -v snap >/dev/null 2>&1 || { echo "❌  snap packages required but snap not available."; exit 1; }
    fi
    if ((${#brew_packages[@]})); then
        command -v brew >/dev/null 2>&1 || { echo "❌  Homebrew packages required but brew not available."; exit 1; }
    fi

    if [[ -n ${manager:-} ]]; then
        install_block "System (${manager})" "system_package_installed $manager" system_packages \
            install_system_packages "$manager"
    fi
    install_block "Snap (classic)" snap_classic_package_installed snap_classic_packages \
        install_snap_classic_packages
    install_block "Brew" brew_package_installed brew_packages brew install
}

require_stow() {
    command -v stow >/dev/null 2>&1 || { echo "❌  stow is required. Install stow first."; exit 1; }
}

# Back up real-file conflicts via stow -nv; re-runs stow -nv if anything was moved
# to confirm the path is clear. Returns 1 if unresolvable conflicts remain.
prepare_pkg() {
    local pkg=$1 line file needs_recheck=0
    local output
    output=$(stow -nv "$pkg" 2>&1)
    while IFS= read -r line; do
        [[ $line =~ existing\ target\ is\ neither ]] || continue
        file=${line##*: }
        mkdir -p "${BACKUP_DIR}/${pkg}/$(dirname "$file")"
        mv -v "${HOME}/${file}" "${BACKUP_DIR}/${pkg}/${file}"
        needs_recheck=1
    done <<< "$output"
    if ((needs_recheck)); then
        stow -nv "$pkg" 2>&1 | grep -q 'existing target is neither' && return 1 || return 0
    else
        grep -q 'existing target is neither' <<< "$output" && return 1 || return 0
    fi
}

install_pkg()  { stow -v  "$1"; }
restow_pkg()   { stow -vR "$1"; }
unstow_pkg()   { stow -vD "$1"; }
unstow_all()   { while IFS= read -r p; do unstow_pkg "$p"; done < <(packages); }

cmd=${1:-help}

case $cmd in
    install|update)
        ensure_packages_installed
        [[ -d ${DOTFILES_DIR}/.git ]] || git clone --recursive "$REPO_URL" "$DOTFILES_DIR"
        cd "$DOTFILES_DIR"
        [[ $cmd == update ]] && git pull --ff-only

        to_do=()
        while IFS= read -r p; do
            prepare_pkg "$p" && to_do+=("$p")
        done < <(packages)

        if ((${#to_do[@]} == 0)); then
            echo "Nothing to $cmd — every package has a conflict."
            exit 0
        fi

        echo "Packages with NO conflicts:"
        printf '  - %s\n' "${to_do[@]}"
        read -rp "Proceed to $cmd these packages? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

        if [[ $cmd == install ]]; then action=install_pkg; else action=restow_pkg; fi
        for p in "${to_do[@]}"; do $action "$p"; done
        echo "✅  $cmd complete. Backups in ${BACKUP_DIR}"
        ;;

    remove)
        require_stow
        cd "$DOTFILES_DIR"
        unstow_all
        echo "✅  Symlinks removed, repo kept."
        ;;

    uninstall)
        require_stow
        cd "$DOTFILES_DIR"
        unstow_all
        cd "$HOME" && rm -rf "$DOTFILES_DIR"
        echo "✅  Repo and links deleted."
        ;;

    *)
        echo "Usage: $(basename "$0") { install | update | remove | uninstall }"
        exit 1 ;;
esac
