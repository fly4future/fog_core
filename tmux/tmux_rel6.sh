#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied, needs to add argument to ssh - either alias or full root@<ip>"
    exit
fi

# change this to your liking
PROJECT_NAME=ros2

if [[ "$1" =~ [a-z]*@.* ]]; then
  SESSION_NAME=mav

else 
  SESSION_NAME=$1
fi


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

# DO NOT PUT SPACES IN THE NAMES
input=(
  'hyper' 'TERM=xterm-256color; ssh '$1''
  'logs' 'TERM=xterm-256color; ssh '$1' fog logs fog_navigation -f'
  'app' 'TERM=xterm-256color; ssh -t '$1' fog ssh app'
  'mesh' 'TERM=xterm-256color; ssh -t '$1' fog ssh mesh'
  'tools' 'TERM=xterm-256color; ssh -t '$1' "fog ssh mesh '\''docker run --network=host --env=DRONE_DEVICE_ID='$1' --name=f4f-tools --volume=/data:/data -it ghcr.io/tiiuae/tii-f4f-tools bash'\'' "'
  'actions1' 'TERM=xterm-256color; ssh -t '$1' "fog ssh mesh '\''docker exec -it f4f-tools bash'\'' "'
  'actions2' 'TERM=xterm-256color; ssh -t '$1' "fog ssh mesh '\''docker exec -it f4f-tools bash'\'' "'
  'rviz' 'TERM=xterm-256color; ssh -t '$1' "fog ssh app '\''docker run --network=host --volume=/data:/data -it ghcr.io/tiiuae/tii-rviz2'\'' "'
)

init_window="app"

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
