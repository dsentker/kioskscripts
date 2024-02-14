#!/bin/bash
# Example usage:
# ./runner.sh >> runner.log 2>&1 && echo "" >> runner.log

export DISPLAY=:0

# 0 = no debug
# 1 = run chrome not in kiosk mode
# 2 = do run run chrome, log message instead
debug=0

# Check if 'chromium' binary exists, otherwise use 'chromium-browser'
raspbian_chromium() {
    if command -v chromium > /dev/null 2>&1; then
        chromium "$@"
    else
        chromium-browser "$@"
    fi
}

check_internet() {
  ping -q -c 1 -W 1 google.com >/dev/null
}

log() {
  { date; echo "$1"; echo ""; } >> ~/c.log
}

run_chrome() {
  url=$(cat "$HOME"/kiosk/url.txt)
  if [ "$debug" -eq 2 ]; then
    # Commands to run when debug is 0
    log "Run chrome (not really)"
  elif [ "$debug" -eq 1 ]; then
    raspbian_chromium --app="$url"
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

    raspbian_chromium "${flags[@]}" --app="$url"
  fi
  exit
}

# Check for internet connection
if check_internet; then
  if ! pgrep -f "chrome|chromium|chromium-browser" >/dev/null; then
    log "Start Chrome..."
    run_chrome
  else
    log "Ping..."
    "$HOME"/kiosk/ping.sh
  fi
else
  log "No internet connection. Chrome will not be started."
fi
