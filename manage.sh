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
TOOLS_FILE="${DOTFILES_DIR}/tools.conf"

need() { command -v "$1" >/dev/null 2>&1 || { echo "❌  $1 missing"; exit 1; }; }

packages() {
  find "${DOTFILES_DIR}" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
    grep -Ev "${SKIP_RE}" | sort
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

check_required_tools() {
    [[ -f "$TOOLS_FILE" ]] || return
    while IFS= read -r tool; do
        [[ -z "$tool" || "$tool" == \#* ]] && continue
        if ! command -v "$tool" >/dev/null 2>&1; then
            echo "⚠️  $tool missing"
        fi
    done < "$TOOLS_FILE"
}

install_pkg()  { backup_conflicts "$1"; stow -v "$1"; }
restow_pkg()   { backup_conflicts "$1"; stow -vR "$1"; }
unstow_pkg()   { stow -vD "$1"; }

cmd=${1:-help}

case $cmd in
  install|update)
      need stow
      check_required_tools
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
        [[ $cmd == install ]] && install_pkg "$p" || restow_pkg "$p"
      done
      echo "✅  $cmd complete. Backups in ${BACKUP_DIR}"
      ;;

  remove)
      need stow
      cd "$DOTFILES_DIR"
      for p in $(packages); do unstow_pkg "$p"; done
      echo "✅  Symlinks removed, repo kept."
      ;;

  uninstall)
      need stow
      cd "$DOTFILES_DIR"
      for p in $(packages); do unstow_pkg "$p"; done
      cd "$HOME" && rm -rf "$DOTFILES_DIR"
      echo "✅  Repo and links deleted."
      ;;

  *)
      echo "Usage: $(basename "$0") { install | update | remove | uninstall }"
      exit 1 ;;
esac
