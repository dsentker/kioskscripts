#!/bin/bash
currentDir=$(pwd)

# Setup wallpaper
pcmanfm --set-wallpaper "$currentDir"/bg.jpg
echo "Wallpaper installed successfully."

# Setup cronjob
runner="$currentDir/runner.sh"

# Check if the cronjob entry already exists
if ! crontab -l | grep -q "$runner"; then
    (crontab -l ; echo "* * * * * $runner") | crontab -
    echo "Cronjob added successfully."
else
    # If it already exists, do nothing
    echo "Cronjob already exists. Doing nothing."
fi

echo "Install Keyboard shortcut..."
sudo apt install -q -y xbindkeys
setup="$currentDir/setup.sh"
echo "\"lxterminal --command='/bin/bash --init-file $setup'\"" > ~/.xbindkeysrc
echo "  Alt + k" >> ~/.xbindkeysrc
xbindkeys --poll-rc
killall xbindkeys
xbindkeys
echo "Done."