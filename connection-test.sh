#!/bin/bash

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -X GET https://www.google.com)

# Check if the HTTP status code is in the 2xx range
if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 300 ]; then
    exit 0  # Return 0 for success
else

    exit "$HTTP_STATUS"
fi