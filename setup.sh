#!/bin/bash

wlan_conf_file="dummy.conf"

# Function to configure WLAN
configure_wlan() {
  ssid=$(whiptail --inputbox "SSID / Name des Netzwerks:" 12 60 3>&1 1>&2 2>&3)
  password=$(whiptail --passwordbox "Passwort:" 12 60 3>&1 1>&2 2>&3)
  # echo "SSID=$ssid" >~/wlan.txt
  # echo "Password=$password" >>~/wlan.txt
  update_conf_file $ssid $password
}

update_conf_file() {
    local ssid="$1"
    local password="$2"

    if [ -f "$wlan_conf_file" ]; then
        # Replace ssid value
        sed -i "s/\(ssid=\"\)[^\"]*\"/\1$ssid\"/" "$wlan_conf_file"
        # Replace password value
        sed -i "s/\(psk=\"\)[^\"]*\"/\1$password\"/" "$wlan_conf_file"
        whiptail --msgbox "Konfiguration gespeichert, bitte starten Sie das Gerät jetzt neu." 8 40
    else
        whiptail --msgbox "WLAN-Konfigurations-Datei konnte nicht gefunden werden" 8 40
    fi
}

# Function to restart Raspberry Pi
restart() {
  whiptail --msgbox "Restarting Raspberry Pi..." 8 40
  sudo shutdown -r now
}

# Function to perform connection test
connection_test() {
  if ./connection-test.sh; then
    if ./ping.sh; then
        whiptail --msgbox "Kommunikation mit dem Server in Ordnung!" 8 60
      else
        whiptail --msgbox "Konnte keine Verbindung zum Server herstellen." 8 60
      fi
  else
    whiptail --msgbox "Keine Verbindung zum Internet. Bitte prüfen Sie die Verbindung." 8 40
  fi
}

show_info() {
  uuid=$(./getid.sh)
  ip=$(curl -s ifconfig.me/ip)
  internal_ip=$(hostname -I -i)
  uptime=$(uptime | awk '{print $3;}')
  ssid=$(grep -oP '(?<=ssid=")[^"]*' "$wlan_conf_file")

  whiptail --msgbox "Uuid:   $uuid\nSSID:   $ssid\nIP:     $ip\nHost:   $internal_ip\nUptime: ${uptime%?} h" 12 60
}

# Main menu loop
while true; do
  choice=$(whiptail --nocancel --clear --title "Setup" --menu "Main" 12 80 5 \
    1 "WLAN-Konfiguration  " \
    2 "Verbindungs-Test  " \
    3 "Zeige Informationen" \
    r "Gerät neustarten  " \
    x "Setup beenden" 3>&1 1>&2 2>&3)

  case $choice in
  1)
    configure_wlan
    ;;
  2)
    connection_test
    ;;
  3)
    show_info
    ;;
  r)
    restart
    ;;
  *)
    # Handle invalid choice
    exit
    ;;
  esac
done
