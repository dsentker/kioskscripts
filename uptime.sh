#!/bin/bash

current_time=$(date +%s)
boot_time=$(date -d "$(uptime -s)" +%s)
seconds_elapsed=$((current_time - boot_time))
echo "$seconds_elapsed"