#!/bin/sh
# The most up-to-date file can be found here:
# https://github.com/breadtk/rc_configs

if [ "$SHELL" != "/bin/bash" ]; then
  echo "It looks like you're using $SHELL. This script assumes BASH. Sorry."
  exit 1
fi

echo -e "Setting up rc files for user \"$USER\".\n^C to cancel"
sleep 5

echo "Downloading rc files from GitHub..."
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.bashrc -o "~/.bashrc"
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.bash_aliases -o "~/.bash_aliases"
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.bash_profile -o "~/.bash_profile"
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.profile -o "~/.profile"
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.vimrc -o "~/.vimrc"
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.screenrc -o "~/.screenrc"
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/ssh_config -o "~/.ssh/config"

if [ -e ~/.ssh/known_hosts ]; then
  echo "Rehashing known_host file."
  ssh-keygen -H -f $HOME/.ssh/known_hosts 2> /dev/null
fi

echo "Reloading BASH and cleaning up."
source ~/.bashrc

# Clean-up
rm -f $0
exit 0
