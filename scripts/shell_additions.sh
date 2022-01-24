alias gs='git status'
alias gd='git diff'
alias sb='source ~/.bashrc'
alias bt='colcon build --package-select $(basename `pwd`)'

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

      echo $bag_adress
      appended_adress=$bag_adress\_$1
      echo $appended_adress 
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

