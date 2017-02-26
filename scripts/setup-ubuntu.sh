#!/bin/bash

# Ubuntu

# Initial setup
echo "THIS IS UNTESTED. USE CAREFULLY"
mkdir -p ~/tmp

# Add commons 
sudo apt-get install software-properties-common

# Add third-party repositories
sudo add-apt-repository ppa:git-core/ppa -y
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo add-apt-repository ppa:aacebedo/fasd -y
sudo apt-get update -y
sudo apt-get upgrade -y

# Install essential commands
for i in wget git zsh tmux neovim silversearcher-ag fasd ruby python
do 
  sudo apt-get install -y $i
done

# Install tpm
git clone https://github.com/tmux-plugins/tpm --depth=1 ~/.tmux/plugins/tpm

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

