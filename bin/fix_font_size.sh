#!/bin/sh

# A fix for a bug where Gnome font sizes get messed up. This script is added to
# startup applications.
# https://bugs.launchpad.net/ubuntu/+source/unity/+bug/1310316

# Sleep so that this runs after whatever is messing up font sizes.
sleep 5
gsettings set com.ubuntu.user-interface scale-factor "{'eDP1': 12}"
gsettings set com.canonical.Unity.Interface text-scale-factor '1.0'
gsettings set org.gnome.desktop.interface text-scaling-factor '1.5'
