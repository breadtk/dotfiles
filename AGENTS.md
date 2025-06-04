# Guidelines for Contributors and Automation

This repository contains configuration files (dotfiles) managed with [GNU Stow](https://www.gnu.org/software/stow/). Each subdirectory represents a Stow package whose contents mirror the target paths. The `manage.sh` script handles installing, updating, and removing the packages.

## Repo Layout
- `bash/`, `git/`, `kitty/`, `nvim/`, `ssh/`, and `tmux/` – directories corresponding to each application's dotfiles.
- `manage.sh` – helper script to install or uninstall all packages at once.

## Style Guidelines
- Use **4 spaces** for indentation in shell scripts and Lua files.
- Keep configuration files under their respective subdirectories so Stow can symlink them correctly.
- Do not store secrets or private keys in the repo.

## Checks
- Run `shellcheck` on shell scripts when possible.
- For Neovim Lua configs (`nvim/.config/nvim/lua`), verify syntax with `luajit -bl <file>` or `luac -p <file>`.
- After changes, ensure `./manage.sh install` executes without errors (requires GNU Stow).

## Contribution
- Update the README if usage details change.
- Write clear commit messages referencing affected configs or scripts.
- Before committing, run `git status` to confirm a clean working tree.
