#!/bin/bash
currentDir=$(pwd)

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

# Setup wallpaper
pcmanfm --set-wallpaper "$currentDir"/bg.jpg
echo "Wallpaper installed successfully."

# Hide trash icon
config_file="$HOME/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"

# Check if the file exists
if [ -f "$config_file" ]; then
    # Replace the line "show_trash=1" with "show_trash=0"
    sed -i 's/show_trash=1/show_trash=0/' "$config_file"
    echo "Trash icon hidden."
else
    echo "Error: Configuration file not found at $config_file"
fi

# Ask for URL
read -p "Specify URL for kiosk mode: (Press ENTER for default): " userInput

# Use default URL if the user input is empty
deviceId=$("$HOME"/kiosk/getid.sh)
url=${userInput:-"https://www.google.com?q=$deviceId"} # TODO

# Validate the URL format using a simple regex
url_regex='^https?://[^\s/$.?#].[^\s]*$'
if [[ ! $url =~ $url_regex ]]; then
    echo "Invalid URL detected!"
    # exit 1
fi

echo "$url" > "$HOME"/kiosk/url.txt && echo "URL set to $url"
