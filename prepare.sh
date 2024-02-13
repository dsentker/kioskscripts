#!/bin/bash
currentDir=$(pwd)

# Setup wallpaper
echo "Install Wallpaper..."
sudo apt install -q -y xwallpaper
xwallpaper --zoom bg.jpg
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
echo "\"bash $setup\"" > ~/.xbindkeysrc
echo "  Alt+Mod2 + k" >> ~/.xbindkeysrc
xbindkeys --poll-rc
killall xbindkeys
xbindkeys
echo "Done."