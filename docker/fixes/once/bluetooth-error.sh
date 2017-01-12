#!/bin/bash
#
# We can witness this bug when starting Xubuntu:
#    https://bugs.launchpad.net/ubuntu/+source/blueman/+bug/1542723

chmod 4754 /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chown root:messagebus /usr/lib/dbus-1.0/dbus-daemon-launch-helper
