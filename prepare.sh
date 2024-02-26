#!/bin/bash
kioskHome="$HOME/kiosk"

function install_dependencies {
  sudo apt update
  sudo apt upgrade
  sudo apt install -y fonts-noto-color-emoji
}

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
  pcmanfm --wallpaper-mode=crop # cover
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
    sudo rm -f /usr/share/plymouth/themes/pix/splash.png
    sudo cp "$newImage" /usr/share/plymouth/themes/pix/
    sudo plymouth-set-default-theme --rebuild-initrd pix
    echo "Splash image changed."
}

function create_url {
  # Ask for URL
  read -p "Specify URL for kiosk mode: (Press ENTER for default): " userInput

  # Use default URL if the user input is empty
  deviceId=$("$HOME"/kiosk/getid.sh)
  url=${userInput:-"https://nucast.de/cast/$deviceId"}

  # Validate the URL format using a simple regex
  url_regex='^https?://[^\s/$.?#].[^\s]*$'
  if [[ ! $url =~ $url_regex ]]; then
      echo "Invalid URL detected!"
      # exit 1
  fi

  echo "$url" > "$HOME"/kiosk/url.txt && echo "URL set to $url"
}

# Function to display the main menu
function show_menu() {
  selection=$(whiptail --title "Initial setup" --menu "" 17 80 9 \
    "1" "Run complete setup" \
    "2" "  Install Dependencies" \
    "3" "  Create Cronjob" \
    "4" "  Create Keyboard Shortcuts" \
    "5" "  Set Background, Hide Desktop Icons" \
    "6" "  Change Splash Image / Boot Screen" \
    "7" "  Change URL" \
    "9" "Exit" \
    3>&1 1>&2 2>&3)

  case $selection in
    1) run_all ;;
    2) install_dependencies ;;
    3) create_cronjob ;;
    4) create_keyboard_shortcuts ;;
    5) create_wallpaper ;;
    6) change_splash ;;
    7) create_url ;;
    9) exit 0 ;;
    *) echo "Invalid option" ;;
  esac
}

# Function to run all functions
function run_all() {
  create_url
  install_dependencies
  create_cronjob
  create_keyboard_shortcuts
  create_wallpaper
  change_splash
}

if [[ "$1" == "--q" ]]; then
  run_all
else
  # Display the main menu
  show_menu
fi