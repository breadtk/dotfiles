#!/bin/bash

# Ubuntu

# Initial setup
echo "THIS IS UNTESTED. USE CAREFULLY"
mkdir -p ~/tmp

# Install essential commands
for i in wget git zsh tmux neovim silversearcher-ag fasd ruby python
do 
  brew install $i
done

# Install tpm
git clone https://github.com/tmux-plugins/tpm --depth=1 ~/.tmux/plugins/tpm

# Install tmuxinator
gem install tmuxinator

# Setup dot files
mkdir -p ~/.config
mkdir -p ~/.config/{nvim,git}
git https://github.com/m0rganic/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git pull && git submodule init && git submodule update && git submodule status
bash install

# Cleanup
rm -rf ~/tmp
cd ~

