# Guidelines for Contributors and Automation

This repository contains configuration files (dotfiles) managed with [GNU
Stow](https://www.gnu.org/software/stow/). Each subdirectory represents a Stow
package whose contents mirror the target paths. The `manage.sh` script handles
installing, updating, and removing the packages.

## Repo Layout
- `bash/`, `bin/`, `git/`, `kitty/`, `nvim/`, `ssh/`, and `tmux/` – Stow
  packages; each mirrors the target path layout under `$HOME`.
- `manage.sh` – orchestrates `install`, `update`, `remove`, and `uninstall`
  operations via GNU Stow.
- `tools.json` – declares the system packages that `manage.sh` probes for on
  startup. Each entry is either a bare string (binary name = package name) or an
  object with a `cmd` field (binary to probe) and `pkg`/`apt-get`/`dnf` fields
  for manager-specific package names.
- Any files with `.local` extension are for machine-local configs/files. You
  should ignore those files.

## Style Guidelines
- Use **4 spaces** for indentation in shell scripts and Lua files.
- Keep configuration files under their respective subdirectories so Stow can
  symlink them correctly.
- Do not store secrets or private keys in the repo.

## Checks
- Run `shellcheck` on shell scripts when possible.
- For Neovim Lua configs, verify syntax with `luajit -bl <file>` or `luac -p
  <file>`. Files live under `nvim/.config/nvim/lua/` and the package entry point
  is `nvim/.config/nvim/init.lua`.
- After changes, ensure `./manage.sh install` executes without errors (requires
  GNU Stow).

## Contribution
- Update the README if usage details change.
- Write clear commit messages referencing affected configs or scripts.
- Before committing, run `git status` to confirm a clean working tree.
