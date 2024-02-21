#!/bin/bash

API_ENDPOINT="https://www.toptal.com/developers/postbin/1708505741841-4866379543673"

# Generate timestamp in ISO 8601 format
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ID=$("$HOME"/kiosk/getid.sh)

# Get wlan signal
interface=$(iw dev | awk '$1=="Interface"{print $2}')
iwconfig_info=$(iwconfig "$interface")
# Use grep and awk to extract the signal quality
# signal_quality=$(echo "$iwconfig_info" | grep "Quality" | awk '{print $4}')
signal_quality=$(echo "$iwconfig_info" | grep "Quality" | sed 's/.*Quality=\([0-9]*\/[0-9]*\).*/\1/')
numerator=$(cut -d'/' -f1 <<< "$signal_quality")
denominator=$(cut -d'/' -f2 <<< "$signal_quality")

# Calculating the percentage
signal_quality_percentage=$(echo "scale=2; ($numerator / $denominator) * 100" | bc)
signal_quality_percentage=$(printf "%.0f" "$signal_quality_percentage")


# Version
version_file="$HOME/kiosk/script_version"
version=$(head -n 1 "$version_file")

# Define JSON data with timestamp
JSON_DATA='{
   "sv": "'"$version"'",
  "alive": 1,
  "id": "'"$ID"'",
  "ts": "'"$TIMESTAMP"'",
  "signal": "'"$signal_quality_percentage"'"
}'

echo $JSON_DATA

#curl -s -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$API_ENDPOINT"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$API_ENDPOINT")

# Check if the HTTP status code is in the 2xx range
if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
    exit 0  # Return 0 for success
else
    exit "$HTTP_STATUS"
fi