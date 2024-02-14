#!/bin/bash

if [ $XDG_MENU_PREFIX != 'gnome-' ]; then
  killall -q chromium
  killall -q chromium-browser
  killall -q chrome
fi

cron_check() {
  # Check if the cron service is running
  if ps -ef | grep '[c]ron' >/dev/null 2>&1; then
    return 0 # cron is active
  else
    return 1
  fi
}

cron_start() {
  sudo /etc/init.d/cron start > /dev/null 2>&1
}

cron_stop() {
  sudo /etc/init.d/cron stop > /dev/null 2>&1
}

configure_wlan() {
  ssid=$(whiptail --inputbox "SSID / Name des Netzwerks:" 12 60 3>&1 1>&2 2>&3)
  password=$(whiptail --passwordbox "Passwort:" 12 60 3>&1 1>&2 2>&3)
  echo "Bitte ein wenig Geduld..."
  if nmcli d wifi connect "$ssid" password "$password"; then
    whiptail --msgbox "WLAN-Verbindung erfolgreich!" 8 40
  else
    whiptail --msgbox "Fehler beim Verbinden mit dem WLAN. Bitte überprüfen Sie die SSID und das Passwort und versuchen Sie es erneut." 10 60
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
  #ssid=$(grep -oP '(?<=ssid=")[^"]*' "$wlan_conf_file")
  cron_status=$([ $(cron_check) -eq 0 ] && echo "Running" || echo "Disabled")
  whiptail --msgbox "\n
Uuid:    $uuid\n
IP:      $ip
Host:    $internal_ip\n
Cron:    $cron_status\n
Uptime:  ${uptime%?} h" 13 60
}

cron_stop
# Main menu loop
showMenu=true
while $showMenu; do
  choice=$(whiptail --nocancel --clear --title "Setup" --menu "Main" 17 80 8 \
    1 "WLAN-Konfiguration (schnell) " \
    2 "WLAN-Konfiguration (erweitert) " \
    3 "Verbindungs-Test  " \
    4 "Zeige Informationen" \
    5 "Experten-Einstellungen" \
    6 "Werkseinstellungen" \
    r "Gerät neustarten  " \
    x "Setup beenden" 3>&1 1>&2 2>&3)

  case $choice in
  1)
    configure_wlan
    ;;
  2)
    showMenu=false
    nmcli radio wifi on
    nmtui connect
    ;;
  3)
    connection_test
    ;;
  4)
    show_info
    ;;
  5)
    showMenu=false
    sudo raspi-config
    ;;
  6)
    showMenu=false
    cd ~ && wget -O - https://raw.githubusercontent.com/dsentker/kioskscripts/main/install.sh | bash
    exit
    ;;
  r)
    restart
    ;;
  *)
    # Handle invalid choice
    cron_start
    showMenu=false
    exit
    ;;
  esac
done
