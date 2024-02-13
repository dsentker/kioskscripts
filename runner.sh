#!/bin/bash
# Example usage:
# ./runner.sh >> runner.log 2>&1 && echo "" >> runner.log

url="https://www.google.com/?q=It%20works"

check_internet() {
    ping -q -c 1 -W 1 google.com >/dev/null;
}

run_chrome() {
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

  chromium-browser "${flags[@]}" --app="$url"
  exit;
}

# Check for internet connection
if check_internet; then
    if ! pgrep -x "chrome" > /dev/null; then
        run_chrome
    else
      ./ping.sh
    fi
else
    echo "No internet connection. Chrome will not be started."
fi
