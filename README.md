Osman's dotfiles files.
===================

This repository contains various dotfiles that I find useful.

Installation
------------
Every dotfile is divided into its own [GNU
stow](https://www.gnu.org/software/stow/) compatible directory. You will want to
ensure you have your own local `dotfiles` directory where these files can be
stored. I'd recommend `~/dotfiles` as a suitable location.

```bash
# Get latest version locally
git clone https://github.com/breadtk/dotfiles.git "~/dotfiles/"
cd ~/dotfiles

# Run installer to install all of the dotfiles
./manage.sh install

# (optional) Stow only a single application
stow kitty
```

Also see
--------
For more ideas, check out the unofficial guide to dotfiles on GitHub:
http://dotfiles.github.io/

An earlier version of this file was adapted from [markup's README](https://github.com/github/markup/blob/master/README.md)
