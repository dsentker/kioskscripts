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

# Ask for URL
read -p "URL für Kiosk-Modus (ENTER für Standardeinstellung): " userInput

# Use default URL if the user input is empty
deviceId=$("$HOME"/kiosk/getid.sh)
url=${userInput:-"https://www.google.com?q=$deviceId"} # TODO

# Validate the URL format using a simple regex
url_regex='^https?://[^\s/$.?#].[^\s]*$'
if [[ ! $url =~ $url_regex ]]; then
    echo "Achtung, die URL scheint nicht korrekt!"
    # exit 1
fi

echo "$url" > "$HOME"/kiosk/url.txt && echo "URL gespeichert: $url"
