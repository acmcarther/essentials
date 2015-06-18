# Set up hotplug udev rule
user=$USER
sudo echo "ACTION==\"change\", SUBSYSTEM==\"drm\", ENV{HOTPLUG}==\"1\", RUN+=\"/home/$user/essentials/scripts/system/udev-monitor-hotplug/hotplug.sh\"" > /etc/udev/rules.d/99-monitor-hotplug.rules
sudo udevadm trigger
