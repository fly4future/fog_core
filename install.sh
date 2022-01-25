#!/bin/bash
# 
# Install script

MY_PATH=`dirname "$0"`
MY_PATH=`(cd "$MY_PATH" && pwd)`

echo "source $MY_PATH/scripts/shell_additions.sh" >> ~/.bashrc

sudo apt install -y vim net-tools moreutils python3-colcon-common-extensions

ln -sf $MY_PATH/config/tmux.conf ~/.tmux.conf
ln -sf $MY_PATH/tmux/tmux.sh ~/tmux.sh

