import launch
import sys
import os
import shutil
import subprocess

from launch.actions import OpaqueFunction
from launch_ros.actions import Node
from launch_ros.actions import ComposableNodeContainer
from launch.substitutions import LaunchConfiguration

DRONE_DEVICE_ID = os.getenv('DRONE_DEVICE_ID')
rviz_path = '/tmp/rviz.rviz'

def prepare_rviz(context, *args, **kwargs):
    rviz_type = LaunchConfiguration("type").perform(context)

    template_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__))) + '/rviz/'

    shutil.copy(template_path + rviz_type + '.rviz', rviz_path)
    subprocess.call(["sed -i -e 's/cze[0-9]\+/" + DRONE_DEVICE_ID + "/g' "+ rviz_path], shell=True)

    return []

def launch_rviz(context, *args, **kwargs):
    cmd = ["rviz2", "-d", rviz_path]
    return [launch.actions.ExecuteProcess(cmd=cmd, output='screen')]

def generate_launch_description():
    ld = launch.LaunchDescription()

    ld.add_action(launch.actions.DeclareLaunchArgument("type", default_value="simulation"))

    ld.add_action(OpaqueFunction(function=prepare_rviz))
    ld.add_action(OpaqueFunction(function=launch_rviz))
    return ld
