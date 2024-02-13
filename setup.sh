#!/bin/bash

wlan_conf_file="$HOME/kiosk/dummy.conf" # TODO update with real one
killall chromium

cron_check() {
  # Check if the cron service is running
  if ps -ef | grep '[c]ron' >/dev/null 2>&1; then
    return 0 # cron is active
  else
    return 1
  fi
}

cron_start() {
  sudo /etc/init.d/cron start
}

cron_stop() {
  sudo /etc/init.d/cron stop
}

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

restart() {
  sudo shutdown -r now
}

connection_test() {
  if "$HOME"/kiosk/connection-test.sh; then
    if "$HOME"/kiosk/ping.sh; then
        whiptail --msgbox "Kommunikation mit dem Server in Ordnung!" 8 60
      else
        whiptail --msgbox "Konnte keine Verbindung zum Server herstellen." 8 60
      fi
  else
    whiptail --msgbox "Keine Verbindung zum Internet. Bitte prüfen Sie die Verbindung." 8 40
  fi
}

show_info() {
  uuid=$("$HOME"/kiosk/getid.sh)
  ip=$(curl -s ifconfig.me/ip)
  internal_ip=$(hostname -I -i)
  uptime=$(uptime | awk '{print $3;}')
  ssid=$(grep -oP '(?<=ssid=")[^"]*' "$wlan_conf_file")
  cron_status=$([ $(cron_check) -eq 0 ] && echo "Running" || echo "Disabled")
  whiptail --msgbox "Uuid:   $uuid\nSSID:   $ssid\nIP:     $ip\nHost:   $internal_ip\nCron:   $cron_status\nUptime: ${uptime%?} h" 13 60
}

cron_stop
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
    cron_start
    exit
    ;;
  esac
done
