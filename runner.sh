#!/bin/bash
# Example usage:
# ./runner.sh >> runner.log 2>&1 && echo "" >> runner.log

export DISPLAY=:0
url="https://www.google.com/?q=It%20works"
debug=1

check_internet() {
  ping -q -c 1 -W 1 google.com >/dev/null
}

log() {
  date >> ~/c.log
  echo "$1" >>~/c.log
  echo "" >>~/c.log
}

run_chrome() {
  if [ "$debug" -eq 2 ]; then
    # Commands to run when debug is 0
    log "Run chrome (not really)"
  elif [ "$debug" -eq 1 ]; then
    chromium --app="$url"
  else
    flags=(
      --kiosk
      --touch-events=enabled
      --disable-pinch
      --noerrdialogs
      --disable-session-crashed-bubble
      --simulate-outdated-no-au='Tue, 31 Dec 2099 23:59:59 GMT'
      --disable-component-update
      --overscroll-history-navigation=0
      --disable-features=TranslateUI
      --autoplay-policy=no-user-gesture-required
    )

    chromium "${flags[@]}" --app="$url"
  fi
  exit
}

# Check for internet connection
if check_internet; then
  if ! pgrep -x "chromium" >/dev/null; then
    log "About to running chrome..."
    run_chrome
  else
    log "Ping..."
    "$HOME"/kiosk/ping.sh
  fi
else
  log "No internet connection. Chrome will not be started."
fi
