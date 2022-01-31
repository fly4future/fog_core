#!/bin/bash

path="/home/$USER/bag_files/latest"

# By default, we record everything.
# Except for this list of EXCLUDED topics:
exclude=(

# IN GENERAL, DON'T RECORD CAMERAS
#
# Every topic containing "octomap"
'(.*)octomap_server(.*)'
# Every topic containing "image_raw"
'(.*)image_raw(.*)'
# Every topic containing "theora"
'(.*)theora(.*)'
# Every topic containing "h264"
# '(.*)h264(.*)'

)

command="ros2 bag record -a -o $path/bag -x \""
if [ "${#exclude[*]}" -gt 0 ]; then

  # list all the string and separate the with |
  for ((i=0; i < ${#exclude[*]}; i++));
  do
    command="$command${exclude[$i]}"
    if [ "$i" -lt "$((  ${#exclude[*]} - 1))" ]; then
      command="$command|"
    fi
  done

fi

command="$command\""

echo "$command"
# eval "$command"
