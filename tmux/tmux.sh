#!/bin/bash
### BEGIN INIT INFO
# Provides: tmux
# Required-Start:    $local_fs $network dbus
# Required-Stop:     $local_fs $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start the uav
### END INIT INFO
if [ "$(id -u)" == "0" ]; then
  exec sudo -u mrs "$0" "$@"
fi

source $HOME/.bashrc

# change this to your liking
PROJECT_NAME=ros2_integration

# do not change this
MAIN_DIR=~/"bag_files"

# following commands will be executed first in each window
pre_input="mkdir -p $MAIN_DIR/$PROJECT_NAME"

SESSION_NAME=mav

# prefere the user-compiled tmux
if [ -f /usr/local/bin/tmux ]; then
  export TMUX_BIN=/usr/local/bin/tmux
else
  export TMUX_BIN=/usr/bin/tmux
fi

# find the session
FOUND=$( $TMUX_BIN ls | grep $SESSION_NAME )

if [ $? == "0" ]; then

  echo "The session already exists"
  exit
fi

# get the iterator
ITERATOR_FILE="$MAIN_DIR/$PROJECT_NAME"/iterator.txt
if [ -e "$ITERATOR_FILE" ]
then
  ITERATOR=`cat "$ITERATOR_FILE"`
  ITERATOR=$(($ITERATOR+1))
else
  echo "iterator.txt does not exist, creating it"
  touch "$ITERATOR_FILE"
  ITERATOR="1"
fi
echo "$ITERATOR" > "$ITERATOR_FILE"

# create file for logging terminals' output
LOG_DIR="$MAIN_DIR/$PROJECT_NAME/"
SUFFIX=$(date +"%Y_%m_%d__%H_%M_%S")
SUBLOG_DIR="$LOG_DIR/"$ITERATOR"_"$SUFFIX""
TMUX_DIR="$SUBLOG_DIR/tmux"
mkdir -p "$SUBLOG_DIR"
mkdir -p "$TMUX_DIR"

# define commands
# 'name' 'command'
# DO NOT PUT SPACES IN THE NAMES
input=(
  'Rosbag' 'ros2 launch fog_core rosbag.py path:='"$SUBLOG_DIR"''

  'ProtocolSplitter' 'journalctl -u agent_protocol_splitter -b -f -o cat
'
  'MavlinkRouter' 'journalctl -u mavlink-router -b -f -o cat
'
  'MicroRtpsAgent' 'journalctl -u micrortps_agent -b -f -o cat
'
  'Control' 'journalctl -u control_interface -b -f -o cat
'
  'Navigation' 'journalctl -u navigation -b -f -o cat
'
  'Odometry' 'journalctl -u odometry2 -b -f -o cat
'
  'Bumper' 'journalctl -u bumper  -b -f -o cat
'
  'Arming' 'ros2 service call /$DRONE_DEVICE_ID/control_interface/arming std_srvs/srv/SetBool "data: true"'
  'Takeoff' 'ros2 service call /$DRONE_DEVICE_ID/control_interface/takeoff std_srvs/srv/Trigger {}'
  'Local_waypoint' 'ros2 service call /$DRONE_DEVICE_ID/navigation/local_waypoint fog_msgs/srv/Vec4 "goal: [0, 0, 2, 0]"'
  'Land' 'ros2 service call /$DRONE_DEVICE_ID/control_interface/land std_srvs/srv/Trigger {}'
  'Hover' 'ros2 service call /$DRONE_DEVICE_ID/navigation/hover std_srvs/srv/Trigger {}'
)

init_window="Status"

###########################
### DO NOT MODIFY BELOW ###
###########################

# Absolute path to this script. /home/user/bin/foo.sh
SCRIPT=$(readlink -f $0)
# Absolute path this script is in. /home/user/bin
SCRIPTPATH=`dirname $SCRIPT`

if [ -z ${TMUX} ];
then
  TMUX= $TMUX_BIN new-session -s "$SESSION_NAME" -d
  echo "Starting new session."
else
  echo "Already in tmux, leave it first."
  exit
fi

# link the "latest" folder to the recently created one
rm "$LOG_DIR/latest"
rm "$MAIN_DIR/latest"
ln -sf "$SUBLOG_DIR" "$LOG_DIR/latest"
ln -sf "$SUBLOG_DIR" "$MAIN_DIR/latest"

# create arrays of names and commands
for ((i=0; i < ${#input[*]}; i++));
do
  ((i%2==0)) && names[$i/2]="${input[$i]}"
  ((i%2==1)) && cmds[$i/2]="${input[$i]}"
done

# run tmux windows
for ((i=0; i < ${#names[*]}; i++));
do
  $TMUX_BIN new-window -t $SESSION_NAME:$(($i+1)) -n "${names[$i]}"
done

sleep 3

# start loggers
for ((i=0; i < ${#names[*]}; i++));
do
  $TMUX_BIN pipe-pane -t $SESSION_NAME:$(($i+1)) -o "ts | cat >> $TMUX_DIR/$(($i+1))_${names[$i]}.log"
done

# send commands
for ((i=0; i < ${#cmds[*]}; i++));
do
  $TMUX_BIN send-keys -t $SESSION_NAME:$(($i+1)) "cd $SCRIPTPATH;${pre_input};${cmds[$i]}"
done

# identify the index of the init window
init_index=0
for ((i=0; i < ((${#names[*]})); i++));
do
  if [ ${names[$i]} == "$init_window" ]; then
    init_index=$(expr $i + 1)
  fi
done

$TMUX_BIN select-window -t $SESSION_NAME:$init_index

$TMUX_BIN -2 attach-session -t $SESSION_NAME

clear
