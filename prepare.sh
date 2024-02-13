#!/bin/bash

# Setup wallpaper
echo "Install Wallpaper..."
sudo apt install -q -y xwallpaper
xwallpaper --zoom bg.jpg
echo "Wallpaper installed successfully."
# Setup cronjob
current_path=$(pwd)
command_to_run="$current_path/runner.sh"

# Check if the cronjob entry already exists
if ! crontab -l | grep -q "$command_to_run"; then
    (crontab -l ; echo "* * * * * $command_to_run") | crontab -
    echo "Cronjob added successfully."
else
    # If it already exists, do nothing
    echo "Cronjob already exists. Doing nothing."
fi
