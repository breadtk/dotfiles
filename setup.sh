#!/bin/sh
#
# The most up-to-date file can be found here:
# https://github.com/breadtk/rc_configs


if [ "$SHELL" != "/bin/bash" ]; then
	echo "We are in $SHELL. This script assumes BASH. Sorry."
	exit 1
fi

echo "Downloading files from GitHub..."

echo "Downloading bashrc..."
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.bashrc -o "~/.bashrc"

echo "Downloading bash_aliases..."
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.bash_aliases -o "~/.bash_aliases"

echo "Downloading vimrc..."
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/.vimrc -o "~/.vimrc"

echo "Downloading ssh client config.."
curl --connect-timeout 10 -m 10 --ssl -# https://raw.github.com/breadtk/rc_configs/master/ssh_config -o "~/.ssh/config"

echo "Rehashing known_host file."
if [ -e ~/.ssh/known_hosts ]; then
	ssh-keygen -H -f $HOME/.ssh/known_hosts 2> /dev/null
fi

echo "That's it. Reloading BASH and cleaning up."

# Reload bash
source ~/.bashrc

# Clean-up
rm -f $0
exit 0
