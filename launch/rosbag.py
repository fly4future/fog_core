import launch
import os

from datetime import datetime
from launch.substitutions import LaunchConfiguration
from launch.actions import OpaqueFunction

HOME = os.getenv('HOME')
date = datetime.now().strftime('x_%Y_%m_%d__%H_%M_%S')
PATH = HOME +"/bag_files/" + date

# List of EXCLUDED topics:
exclude = ['(.*)octomap_server(.*)']

# Examples:
# exclude = []
# exclude = ['(.*)octomap_server(.*)', '(.*)image_raw(.*)']

## Every topic containing "octomap"
#'(.*)octomap_server(.*)'
## Every topic containing "image_raw"
#'(.*)image_raw(.*)'
## Every topic containing "theora"
#'(.*)theora(.*)'
## Every topic containing "h264"
## '(.*)h264(.*)'


def launch_setup(context, *args, **kwargs):
    path = LaunchConfiguration("path").perform(context) + "/bag"
    exclude_list = '|'.join(exclude)
    print("excluding:", exclude_list)
    return [launch.actions.ExecuteProcess(cmd=['ros2', 'bag', 'record', '-a', '-o', path, '-x', exclude_list], output='screen')]

def generate_launch_description():
    ld = launch.LaunchDescription()
    ld.add_action(launch.actions.DeclareLaunchArgument("path", default_value=PATH))
    ld.add_action(OpaqueFunction(function=launch_setup))
    return ld
