#!/bin/bash
# shellcheck disable=SC2155

API_ENDPOINT="https://www.toptal.com/developers/postbin/1708507709611-3039496031124"
VERSION_FILE="$HOME/kiosk/script_version"

# Function to get timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Function to get ID using the getid.sh script
get_id() {
    "$HOME"/kiosk/getid.sh
}

# Function to get WLAN signal quality percentage
get_signal_quality() {
    local interface=$(iw dev | awk '$1=="Interface"{print $2}')
    local iwconfig_info=$(iwconfig "$interface")
    local signal_quality=$(echo "$iwconfig_info" | grep "Quality" | sed 's/.*Quality=\([0-9]*\/[0-9]*\).*/\1/')
    local numerator=$(cut -d'/' -f1 <<< "$signal_quality")
    local denominator=$(cut -d'/' -f2 <<< "$signal_quality")
    local signal_quality_percentage=$(echo "scale=2; ($numerator / $denominator) * 100" | bc)
    echo $signal_quality_percentage
}

get_cpu_usage() {
  local cpu_usage=$(top -bn1 | grep "CPU(" | awk '{print $2 + $4}')
  echo "$cpu_usage"
}

get_uptime() {
  uptime_seconds=$(uptime | awk -F'[ ,:]+' '{print $6 * 3600 + $7 * 60 + $8}')
  echo "$uptime_seconds"
}

get_device_model() {
  model_path="/sys/firmware/devicetree/base/model"

  if [ -e "$model_path" ]; then
      model=$(cat "$model_path")
  else
      model="(unknown)"
  fi

  echo "$model"
}

# Function to get script version
get_version() {
    head -n 1 "$VERSION_FILE"
}

# Function to create JSON data
create_json_data() {
    local version=$(get_version)
    local id=$(get_id)
    local timestamp=$(get_timestamp)
    local signal_quality_percentage=$(get_signal_quality)
    local cpu_usage=$(get_cpu_usage)
    local uptime=$(get_uptime)
    local model=$(get_device_model)

    cat <<EOF
{
   "sv": "$version",
   "alive": 1,
   "id": "$id",
   "ts": "$timestamp",
   "cpu": "$cpu_usage",
   "up": "$uptime",
   "mdl": "$model",
   "sig": $signal_quality_percentage
}
EOF
}

# Function to make API call
make_api_call() {
    local json_data=$(create_json_data)
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -d "$json_data" "$API_ENDPOINT")

    if [ "$http_status" -ge 200 ] && [ "$http_status" -lt 300 ]; then
        exit 0  # Return 0 for success
    else
        exit "$http_status"
    fi
}

# create_json_data  # Display JSON data for verification
make_api_call
