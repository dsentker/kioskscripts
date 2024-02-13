#!/bin/bash

API_ENDPOINT="https://www.toptal.com/developers/postbin/1707834707237-1143189007416"

# Generate timestamp in ISO 8601 format
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ID=$(./getid.sh)
# Define JSON data with timestamp
JSON_DATA='{
  "alive": 1,
  "id": "'"$ID"'",
  "ts": "'"$TIMESTAMP"'"
}'

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$API_ENDPOINT")

# Check if the HTTP status code is in the 2xx range
if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
    exit 0  # Return 0 for success
else
    exit 1  # Return 1 for failure
fi