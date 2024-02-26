#!/bin/bash
# shellcheck disable=SC2155

API_ENDPOINT="https://nucast.de/ping"
# API_ENDPOINT="http://localhost/ping"
VERSION_FILE="$HOME/kiosk/.version"

# Function to get timestamp in ISO 8601 format
get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Function to get ID using the getid.sh script
get_id() {
    "$HOME"/kiosk/getid.sh
}

get_hostname() {
  local hostname=$(hostname -I | grep -o "^\S*")
  echo "$hostname"
}

# Function to get WLAN signal quality percentage
get_signal_quality() {
    local interface=$(iw dev | awk '$1=="Interface"{print $2}')
    local iwconfig_info=$(iwconfig "$interface")
    local signal_quality=$(echo "$iwconfig_info" | grep "Quality" | sed 's/.*Quality=\([0-9]*\/[0-9]*\).*/\1/')
    local numerator=$(cut -d'/' -f1 <<< "$signal_quality")
    local denominator=$(cut -d'/' -f2 <<< "$signal_quality")
    local signal_quality_percentage=$(echo "scale=2; ($numerator / $denominator) * 100" | bc)
    echo "$signal_quality_percentage"
}

get_cpu_usage() {
  local cpu_usage=$(top -bn1 | grep "CPU(" | awk '{print $2 + $4}')
  echo "$cpu_usage"
}

get_uptime() {
  ./uptime.sh
}

get_utc_offset() {
  date +%z
}

get_resolution() {
  xdpyinfo | awk '/dimensions/{print $2}'
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
    local hostname=$(get_hostname)
    local resolution=$(get_resolution)
    local utc_offset=$(get_utc_offset)

    cat <<EOF
{
   "sv": "$version",
   "alive": 1,
   "id": "$id",
   "ts": "$timestamp",
   "utco": "$utc_offset",
   "cpu": "$cpu_usage",
   "up": "$uptime",
   "mdl": "$model",
   "host": "$hostname",
   "res": "$resolution",
   "sig": $signal_quality_percentage
}
EOF
}

# Function to make API call
make_api_call() {
    local json_data=$(create_json_data)
    local response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json_data" "$API_ENDPOINT")

    # Check if the response is a valid JSON
    if jq -e . >/dev/null 2>&1 <<<"$response"; then
        local msg=$(echo "$response" | jq -r '.action')

        # Check the value of the 'msg' key in the JSON response
        case "$msg" in
            "ack")
                echo "Ping successful"
                ;;
            "test")
                echo "Received 'test' command"
                ;;
            "restart")
                shutdown -r now
                ;;
            "update")
                ./install --q
                ;;
            *)
                # Handle other cases or errors
                echo "Unexpected server response. Exiting with error."
                echo "$response"
                exit 1
                ;;
        esac
    else
        # Handle the case where the response is not a valid JSON
        echo "Invalid JSON response. Exiting with error."
        echo "$response"
        exit 1
    fi
}


# create_json_data  # Display JSON data for verification
make_api_call
