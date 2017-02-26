m0rganic's rc files.
=============

This repository contains various rc files that I use on most systems.

Installation
-----------
If you already have all the dependencies:
```sh
git clone https://github.com/m0rganic/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git pull && git submodule init && git submodule update && git submodule status
bash install

If you want to download all dependencies then install the dotfiles:
```sh
sh -c "$(curl -fsSL
https://raw.githubusercontent.com/m0rganic/dotfiles/master/scripts/setup-mac.sh)"
# OS X
sh -c "$(curl -fsSL
https://raw.githubusercontent.com/m0rganic/dotfiles/master/scripts/setup-ubuntu.sh)"
# Debian
```
