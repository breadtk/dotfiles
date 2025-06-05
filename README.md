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

Git Credential Storage
---------------------
The included [`.gitconfig`](git/.gitconfig) configures Git to use
`git-credential-manager` with the `secretservice` credential store.
This requires the **git-credential-manager** package and the `libsecret`
library (often provided by the `secret-tool` command). If these tools are not
available you can switch to another helper, such as `git-credential-libsecret`
or the built in `store` helper.

To change or disable the credential helper:

```bash
# Remove the helper entirely
git config --global --unset credential.helper

# Use the simple file-based store instead
git config --global credential.helper store
```

Also see
--------
For more ideas, check out the unofficial guide to dotfiles on GitHub:
http://dotfiles.github.io/

An earlier version of this file was adapted from [markup's README](https://github.com/github/markup/blob/master/README.md)
