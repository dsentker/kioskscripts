#!/bin/bash
MID=$(cat /etc/machine-id | cut -c1-16)
BID=$(blkid | grep -oP 'UUID="\K[^"]+' | sha256sum | awk '{print $1}' | cut -c1-16)
echo "dm-$MID"-"$BID"