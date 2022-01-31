#!/bin/bash
# 
# Install script

MY_PATH=$(dirname "$0")
MY_PATH=$(cd "$MY_PATH" && pwd)


default=n
while true; do

  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "This script is meant only for use on the real fog drone."
  echo "            It might break your setup                   "
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mReally want to install? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
  response=$(echo $resp | sed -r 's/(.*)$/\1=/')

  if [[ $response =~ ^(y|Y)=$ ]]
  then

    echo "source $MY_PATH/scripts/shell_additions.sh" >> ~/.bashrc
    
    sudo apt install -y vim net-tools moreutils python3-colcon-common-extensions
    
    # ln -sf "$MY_PATH/config/tmux.conf" ~/.tmux.conf
    # ln -sf "$MY_PATH/tmux/tmux.sh" ~/tmux.sh

  elif [[ $response =~ ^(n|N)=$ ]]
  then
    break
  else
    echo " What? \"$resp\" is not a correct answer. Try y+Enter."
  fi
done
