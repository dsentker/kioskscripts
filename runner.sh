#!/bin/bash

# Example usage:
# ./runner.sh >> runner.log 2>&1 && echo "" >> runner.log

# Function to check internet connection
check_internet() {
    ping -q -c 1 -W 1 google.com >/dev/null;
}

# Check for internet connection
if check_internet; then
    if ! pgrep -x "chrome" > /dev/null; then
        google-chrome &
    else
      ./ping.sh
    fi
else
    echo "No internet connection. Chrome will not be started."
fi
