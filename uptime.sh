#!/bin/bash
# Get the current time in seconds since the epoch
current_time=$(date +%s)

# Get the boot time in seconds since the epoch
boot_time=$(date -d "$(uptime -s)" +%s)

# Calculate the seconds elapsed
seconds_elapsed=$((current_time - boot_time))

echo "$seconds_elapsed"