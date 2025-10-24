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

dry_ok() {                      # 0 if stow -nv shows **no** conflicts
    ! stow -nv "$1" 2>&1 | grep -q 'existing target is neither'
}

backup_conflicts() {            # move real files aside
    local pkg=$1 line file
    stow -nv "${pkg}" 2>&1 | while read -r line; do
    [[ $line =~ existing\ target\ is\ neither ]] || continue
    file=${line##*: }
    mkdir -p "${BACKUP_DIR}/${pkg}/$(dirname "${file}")"
    mv -v "${HOME}/${file}" "${BACKUP_DIR}/${pkg}/${file}"
done
}

detect_system_package_manager() {
    if command -v apt-get >/dev/null 2>&1; then
        echo "apt-get"
        return 0
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
        return 0
    fi
    return 1
}

system_package_installed() {
    local manager=$1 pkg=$2
    case "$manager" in
        apt-get)
            if dpkg -s "$pkg" >/dev/null 2>&1; then
                return 0
            else
                return 1
            fi
            ;;
        dnf)
            if rpm -q "$pkg" >/dev/null 2>&1; then
                return 0
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac
}

install_system_packages() {
    local manager=$1; shift
    case "$manager" in
        apt-get)
            if (( EUID == 0 )); then
                apt-get install -y "$@"
            else
                sudo apt-get install -y "$@"
            fi
            ;;
        dnf)
            if (( EUID == 0 )); then
                dnf install -y "$@"
            else
                sudo dnf install -y "$@"
            fi
            ;;
        *)
            echo "❌  Unsupported system package manager: $manager"
            return 1
            ;;
    esac
}

brew_package_installed() {
    local pkg=$1
    if brew list --formula "$pkg" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

flatpak_package_installed() {
    local pkg=$1
    if flatpak info "$pkg" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

ensure_packages_installed() {
    local -a system_packages=() brew_packages=() flatpak_packages=()
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        system_packages+=("$pkg")
    done < <(manifest_values "system_package")

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        brew_packages+=("$pkg")
    done < <(manifest_values "brew")

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        flatpak_packages+=("$pkg")
    done < <(manifest_values "flatpak")

    local manager
    manager=$(detect_system_package_manager || true)
    if [[ ${#system_packages[@]} -gt 0 ]]; then
        if [[ -z ${manager:-} ]]; then
            echo "❌  No supported system package manager found, but system packages are required."
            exit 1
        fi
    fi

    local -a missing_system=() missing_brew=() missing_flatpak=()
    if [[ -n ${manager:-} ]]; then
        local pkg
        for pkg in "${system_packages[@]}"; do
            system_package_installed "$manager" "$pkg" || missing_system+=("$pkg")
        done
    fi

    if ((${#brew_packages[@]})) && command -v brew >/dev/null 2>&1; then
        local pkg
        for pkg in "${brew_packages[@]}"; do
            brew_package_installed "$pkg" || missing_brew+=("$pkg")
        done
    elif ((${#brew_packages[@]})); then
        echo "❌  Homebrew packages required but brew not available."
        exit 1
    fi

    if ((${#flatpak_packages[@]})) && command -v flatpak >/dev/null 2>&1; then
        local pkg
        for pkg in "${flatpak_packages[@]}"; do
            flatpak_package_installed "$pkg" || missing_flatpak+=("$pkg")
        done
    elif ((${#flatpak_packages[@]})); then
        echo "❌  Flatpak packages required but flatpak not available."
        exit 1
    fi

    if ((${#missing_system[@]} == 0 && ${#missing_brew[@]} == 0 && ${#missing_flatpak[@]} == 0)); then
        return
    fi

    if ((${#missing_system[@]})); then
        echo "System packages missing (${manager}): ${missing_system[*]}"
        read -rp "Install missing system packages? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
        install_system_packages "$manager" "${missing_system[@]}"
        missing_system=()
        for pkg in "${system_packages[@]}"; do
            system_package_installed "$manager" "$pkg" || missing_system+=("$pkg")
        done
        if ((${#missing_system[@]})); then
            echo "❌  Failed to install system packages: ${missing_system[*]}"
            exit 1
        fi
    fi

    if ((${#missing_brew[@]})); then
        echo "Brew packages missing: ${missing_brew[*]}"
        read -rp "Install missing Brew packages? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
        brew install "${missing_brew[@]}"
        missing_brew=()
        for pkg in "${brew_packages[@]}"; do
            brew_package_installed "$pkg" || missing_brew+=("$pkg")
        done
        if ((${#missing_brew[@]})); then
            echo "❌  Failed to install Brew packages: ${missing_brew[*]}"
            exit 1
        fi
    fi

    if ((${#missing_flatpak[@]})); then
        echo "Flatpak packages missing: ${missing_flatpak[*]}"
        read -rp "Install missing Flatpak packages? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 1; }
        flatpak install -y --noninteractive "${missing_flatpak[@]}"
        missing_flatpak=()
        for pkg in "${flatpak_packages[@]}"; do
            flatpak_package_installed "$pkg" || missing_flatpak+=("$pkg")
        done
        if ((${#missing_flatpak[@]})); then
            echo "❌  Failed to install Flatpak packages: ${missing_flatpak[*]}"
            exit 1
        fi
    fi
}

install_pkg()  { backup_conflicts "$1"; stow -v "$1"; }
restow_pkg()   { backup_conflicts "$1"; stow -vR "$1"; }
unstow_pkg()   { stow -vD "$1"; }

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

        if ((${#to_do[@]}==0)); then
            echo "Nothing to $cmd — every package has a conflict."
            exit 0
        fi

        echo "Packages with NO conflicts:"
        printf '  - %s\n' "${to_do[@]}"
        read -rp "Proceed to $cmd these packages? [y/N] " reply
        [[ $reply =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

        for p in "${to_do[@]}"; do
            if [[ $cmd == install ]]; then
                install_pkg "$p"
            else
                restow_pkg "$p"
            fi
        done
        echo "✅  $cmd complete. Backups in ${BACKUP_DIR}"
        ;;

    remove)
        ensure_packages_installed
        cd "$DOTFILES_DIR"
        for p in $(packages); do unstow_pkg "$p"; done
        echo "✅  Symlinks removed, repo kept."
        ;;

    uninstall)
        ensure_packages_installed
        cd "$DOTFILES_DIR"
        for p in $(packages); do unstow_pkg "$p"; done
        cd "$HOME" && rm -rf "$DOTFILES_DIR"
        echo "✅  Repo and links deleted."
        ;;

    *)
        echo "Usage: $(basename "$0") { install | update | remove | uninstall }"
        exit 1 ;;
esac
