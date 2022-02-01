# colcon_cd setup
source /usr/share/colcon_cd/function/colcon_cd.sh
export _colcon_cd_root=/home/sad/

# aliases
alias ccd='colcon_cd'
alias gs='git status'
alias gd='git diff'
alias sb='source ~/.bashrc'
alias bt='colcon build --packages-select $(basename `pwd`)'

## FUNCTIONS

# #{ sourceShellDotfile()

getRcFile() {

  case "$SHELL" in
    *bash*)
      RCFILE="$HOME/.bashrc"
      ;;
    *zsh*)
      RCFILE="$HOME/.zshrc"
      ;;
  esac

  echo "$RCFILE"
}

sourceShellDotfile() {

  RCFILE=$( getRcFile )

  source "$RCFILE"
}

# #}
alias sb="sourceShellDotfile"

# #{ appendBag2()

appendBag2() {

  if [ "$#" -ne 1 ]; then
    echo ERROR: please supply one argument: the text that should be appended to the name of the folder with the latest rosbag file and logs
  else

    bag_adress=`readlink ~/bag_files/latest`

    if test -d "$bag_adress"; then

      appended_adress=$bag_adress\_$1
      mv $bag_adress $appended_adress
      ln -sf $appended_adress ~/bag_files/latest

      echo Rosbag name appended: $appended_adress

      # journalctl -u agent_protocol_splitter -b > $appended_adress/tmux/2_ProtocolSplitter.log
      # journalctl -u mavlink-router -b > $appended_adress/tmux/3_MavlinkRouter.log
      # journalctl -u micrortps-agent -b > $appended_adress/tmux/4_MicroRtpsAgent.log
      # journalctl -u control_interface -b > $appended_adress/tmux/5_Control.log
      # journalctl -u navigation -b > $appended_adress/tmux/6_Navigation.log
      # journalctl -u odometry -b > $appended_adress/tmux/7_Odometry.log
      # journalctl -u bumper -b > $appended_adress/tmux/8_Bumper.log

    else
      echo ERROR: symlink ~/bag_files/latest does not point to a file! - $bag_adress
    fi
  fi

}

# #}

# #{ killp()

# allows killing process with all its children
killp() {

  if [ $# -eq 0 ]; then
    echo "The command killp() needs an argument, but none was provided!"
    return
  else
    pes=$1
  fi

  for child in $(ps -o pid,ppid -ax | \
    awk "{ if ( \$2 == $pes ) { print \$1 }}")
    do
      # echo "Killing child process $child because ppid = $pes"
      killp $child
    done

# echo "killing $1"
kill -9 "$1" > /dev/null 2> /dev/null
}

# #}

# #{ colcon()

colcon() {

  CURRENT_PATH=`pwd`

  case $* in

    init*)

      if [ ! -e "build/COLCON_IGNORE" ]; then # we are NOT at the workspace root
        command colcon build # this creates a new workspace
      fi

      ;;

    build*|b*)

      # go up the folder tree until we find the build/COLCON_IGNORE file or until we reach the root
      while [ ! -e "build/COLCON_IGNORE" ]; do
        cd ..
        if [[ `pwd` == "/" ]]; then
          # we reached the root and didn't find the build/COLCON_IGNORE file - that's a fail!
          echo "Cannot compile, probably not in a workspace (if you want to create a new workspace, call \"colcon init\" in its root first)".
          return 1
        fi
      done

      # if the flow got here, we found the build/COLCON_IGNORE file!
      # this is the folder we're looking for - call the actual colcon command here
      command colcon "$@" --symlink-install
      ret=$? # remember the return value of the colcon command
      cd "$CURRENT_PATH" # return to the path where this command was originaly called
      return $ret # return the original return value of the colcon command

      ;;

    clean*)

      if [ -e "build/COLCON_IGNORE" ]; then # we are at the workspace root
        rm -r build install log
        mkdir build
        cd build
        touch COLCON_IGNORE
      else
        while [ ! -e "build/COLCON_IGNORE" ]; do
          cd ..

          if [[ `pwd` == "/" ]]; then
            echo "Cannot clean, not in a workspace!"
            break
          elif [ -e "build/COLCON_IGNORE" ]; then
            rm -r build install log
            mkdir build
            cd build
            touch COLCON_IGNORE
            break
          fi
        done
      fi

      cd "$CURRENT_PATH" # return to the original folder where the command was called

      ;;

    *)
      command colcon $@
      ;;

  esac
}

# #}

# #{ cb()

cb() {

  # catkin?
  PACKAGES=$(catkin list)
  [ ! -z "$PACKAGES" ] && USE_CATKIN=1 || USE_CATKIN=0

  # colcon?
  CURRENT_PATH=`pwd`
  while [ ! -e "build/COLCON_IGNORE" ]; do
    cd ..

    if [[ `pwd` == "/" ]]; then
      break
    fi
  done
  [[ `pwd` == "/" ]] && USE_COLCON=0
  [ -e "build/COLCON_IGNORE" ] && USE_COLCON=1
  cd "$CURRENT_PATH"

  ret=1
  [[ $USE_CATKIN == "1" ]] && [[ $USE_COLCON == "0" ]] && ( catkin build "$@"; ret=$? )
  [[ $USE_CATKIN == "0" ]] && [[ $USE_COLCON == "1" ]] && ( colcon build "$@"; ret=$? )
  [[ $USE_CATKIN == "1" ]] && [[ $USE_COLCON == "1" ]] && ( colcon build "$@"; ret=$? )
  [[ $USE_CATKIN == "0" ]] && [[ $USE_COLCON == "0" ]] && echo "Cannot compile, not in a workspace"

  unset USE_CATKIN
  unset USE_COLCON
  return $ret
}

# #}

