#!/bin/bash
kioskHome="$HOME/kiosk"

function create_cronjob() {
  runner="$kioskHome/runner.sh"

  # Check if the cronjob entry already exists
  if ! crontab -l | grep -q "$runner"; then
      (crontab -l ; echo "* * * * * $runner") | crontab -
      echo "Cronjob added successfully."
  else
      # If it already exists, do nothing
      echo "Cronjob already exists. Doing nothing."
  fi
}

function create_keyboard_shortcuts {
  # Keyboard shortcut
  SETUP_SCRIPT="$kioskHome/setup.sh"
  CONFIG_FILE="$HOME/.config/wayfire.ini"
  SEARCH_STRING="binding_kiosksetup"

  # Check if the binding_kiosksetup or command_kiosksetup entry already exists
  if ! grep -q "$SEARCH_STRING" "$CONFIG_FILE"; then
      # Use awk to add the lines after the [command] section
      awk -v RS= -v ORS="\n\n" -v setup_script="$SETUP_SCRIPT" '
          /\[command\]/ {
              print $0 "\nbinding_kiosksetup=<alt> KEY_K\ncommand_kiosksetup=lxterminal -e " setup_script
              next
          }
          { print }
      ' "$CONFIG_FILE" > tmpfile && mv tmpfile "$CONFIG_FILE"
      echo "Entries added successfully."
  else
      echo "Entries already exist."
  fi
  echo "Keyboard shortcuts created."
}

function create_wallpaper {
  pcmanfm --set-wallpaper "$kioskHome"/bg.jpg
  pcmanfm --wallpaper-mode=fit
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

  pcmanfm --reconfigure
}

function change_splash {
    newImage="$HOME"/kiosk/splash.png
    rm -f /usr/share/plymouth/themes/pix/splash.png
    cp "$newImage" /usr/share/plymouth/themes/pix/
    echp "Splash image changed."
}

function create_url {
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
}

create_cronjob;
create_keyboard_shortcuts;
create_wallpaper;
change_splash;
create_url;
