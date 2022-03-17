import launch

# from launch_ros.actions import Node
# from launch_ros.actions import ExecuteProcess
# from launch.actions import SetEnvironmentVariable
# from launch_ros.descriptions import ComposableNode
import os

HOME = os.getenv('HOME')

PATH = HOME +"/bag_files/latest"

# By default, we record everything.
# Except for this list of EXCLUDED topics:
exclude=(

## IN GENERAL, DON'T RECORD CAMERAS
##
## Every topic containing "octomap"
"(.*)octomap_server(.*)"
## Every topic containing "image_raw"
#'(.*)image_raw(.*)'
## Every topic containing "theora"
#'(.*)theora(.*)'
## Every topic containing "h264"
## '(.*)h264(.*)'

)
print(exclude)

def generate_launch_description():

    return launch.LaunchDescription([launch.actions.ExecuteProcess(cmd=['ros2', 'bag', 'record', '-a', '-o', PATH, '-x', '"exclude"'], output='screen')])
