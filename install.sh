#!/bin/bash
# 
# Install script

MY_PATH=$(dirname "$0")
MY_PATH=$(cd "$MY_PATH" && pwd)

echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "This script is meant only for use on the real fog drone."
echo "            It might break your setup                   "
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"


default=n
while true; do
  [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mReally want to install? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
  response=$(echo $resp | sed -r 's/(.*)$/\1=/')

  if [[ $response =~ ^(y|Y)=$ ]]
  then

    echo "source $MY_PATH/scripts/shell_additions.sh" >> ~/.bashrc
    
    sudo apt install -y vim net-tools moreutils python3-colcon-common-extensions
    
    ln -sf "$MY_PATH/config/tmux.conf" ~/.tmux.conf
    ln -sf "$MY_PATH/tmux/tmux.sh" ~/tmux.sh
    break

  elif [[ $response =~ ^(n|N)=$ ]]
  then
    break
  else
    echo " What? \"$resp\" is not a correct answer. Try y+Enter."
  fi
done

# Ask about ssh keys
while true; do
  [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mDo you want to update ssh keys? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
  response=$(echo $resp | sed -r 's/(.*)$/\1=/')

  if [[ $response =~ ^(y|Y)=$ ]]
  then

    cp "$MY_PATH"/dotssh/* "$HOME"/.ssh
    break
  elif [[ $response =~ ^(n|N)=$ ]]
  then
    break
  else
    echo " What? \"$resp\" is not a correct answer. Try y+Enter."
  fi
done

# Ask about udev rules
while true; do
  [[ -t 0 ]] && { read -t 10 -n 2 -p $'\e[1;32mDo you want to update udev rules? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
  response=$(echo $resp | sed -r 's/(.*)$/\1=/')

  if [[ $response =~ ^(y|Y)=$ ]]
  then

    sudo cp "$MY_PATH"/udev/* /etc/udev/rules.d/.
    break
  elif [[ $response =~ ^(n|N)=$ ]]
  then
    break
  else
    echo " What? \"$resp\" is not a correct answer. Try y+Enter."
  fi
done
