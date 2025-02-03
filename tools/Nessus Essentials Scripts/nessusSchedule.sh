#!/bin/bash

sudo systemctl start nessusd

# Exit script on error
set -e

# Default values
SCAN_NUMBER=""
TARGET_IP=""
NESSUS_URL=""
USERNAME=""
PASSWORD=""
SCAN_NAME=""

# Help menu
function show_help() {
    echo "Usage: $0 -s <scan_number> -t <target-ip> -h <host-of-nessus> -u <username-of-nessus> -p <password-of-nessus> [-n <scan-name>]"
    echo
    echo "Options:"
    echo "  -s  Scan number (required)"
    echo "  -t  Target IP address (required)"
    echo "  -h  Nessus host URL (required)"
    echo "  -u  Nessus username (required)"
    echo "  -p  Nessus password (required)"
    echo "  -n  Custom scan name (optional)"
    echo -e "\n Available scan templates:\n
  2. discovery [bbd4f805-3966-d464-b2d1-0079eb89d69708c3a05ec2812bcf]
  3. basic [731a8e52-3ea6-a291-ec0a-d2ff0619c19d7bd788d6be818b65]
  5. webapp [c3cbcd46-329f-a9ed-1077-554f8c2af33d0d44f09d736969bf]
  6. malware [d16c51fa-597f-67a8-9add-74d5ab066b49a918400c42a035f7]
  14. advanced [ad629e16-03b6-8c1d-cef6-ef8c9dd3c658d24bd260ef5f9e66]
  15. advanced_dynamic [939a2145-95e3-0c3f-f1cc-761db860e4eed37b6eee77f9e101]
  17. ai_llm_assessment [a303f033-d3b7-e53c-603d-a7bbf7b3c65ec6d8ecaa53911a55]"
    exit 0
}

# Parse flags
while getopts "s:t:h:u:p:n:?" opt; do
    case $opt in
        s) SCAN_NUMBER="$OPTARG" ;;
        t) TARGET_IP="$OPTARG" ;;
        h) NESSUS_URL="$OPTARG" ;;
        u) USERNAME="$OPTARG" ;;
        p) PASSWORD="$OPTARG" ;;
        n) SCAN_NAME="$OPTARG" ;;
        ?) show_help ;;
        *) 
            echo "Invalid option."
            show_help
            ;;
    esac
done

if ! [[ "$SCAN_NUMBER" =~ ^(2|3|5|6|14|15|17)$ ]]; then
    show_help
    exit 1
fi


# Validate required inputs
if [[ -z "$SCAN_NUMBER" || -z "$TARGET_IP" || -z "$NESSUS_URL" || -z "$USERNAME" || -z "$PASSWORD" ]]; then
    echo "Error: Missing required arguments."
    show_help
fi

# Step 1: Receive Token
echo "Receiving session token..."
SESSION_TOKEN=$(curl -k -X POST "$NESSUS_URL/session" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$USERNAME\",\"password\":\"$PASSWORD\"}" \
    -s | jq -r '.token')

if [[ -z $SESSION_TOKEN ]]; then
    echo "Failed to retrieve session token. Exiting."
    exit 1
fi
echo "Session token received: $SESSION_TOKEN"

X_API_TOKEN=$(curl https://127.0.0.1:8834/nessus6.js -k -s | grep -Eo '"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"' | sed 's/"//g')
echo -e "X-API-TOKEN: $X_API_TOKEN\n"
# Step 2: Fetch Scan Templates
echo "Fetching available scan templates..."
TEMPLATES=$(curl -s -k -X GET \
    -H "Content-Type: application/json" \
    -H "X-Api-Token: $X_API_TOKEN" \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    "$NESSUS_URL/editor/scan/templates" | jq -c '.templates')

# List available scan templates for the user
if [[ -z "$TEMPLATES" ]]; then
    echo "Failed to retrieve scan templates. Exiting."
    exit 1
fi

echo "Available scan templates:"
echo "$TEMPLATES" | jq -r 'to_entries[] | "\(.key + 1). \(.value.name) [\(.value.uuid)]"' | grep -E 'discovery|basic|webapp|malware|advanced|advanced_dynamic|ai_llm_assessment'


# Retrieve Selected Scan Type
SELECTED_TEMPLATE=$(echo "$TEMPLATES" | jq -c ".[$SCAN_NUMBER - 1]")

if [[ -z "$SELECTED_TEMPLATE" ]]; then
    echo "Invalid scan number. Please choose a valid scan type."
    exit 1
fi

SCAN_NAME=$(echo "$SELECTED_TEMPLATE" | jq -r '.name')
SCAN_UUID=$(echo "$SELECTED_TEMPLATE" | jq -r '.uuid')

echo "Selected scan type: $SCAN_NAME (UUID: $SCAN_UUID)"
echo "Target IP: $TARGET_IP"

# Set default scan name if not provided
if [[ -z "$SCAN_NAME" ]]; then
    SCAN_NAME="Nessus_Scan_${SCAN_NUMBER}_$(date +%Y%m%d)"
fi


# Generate API Keys

echo "Generating API keys..."
RESPONSE=$(curl -k -X PUT "$NESSUS_URL/session/keys" \
    -H "Content-Type: application/json" \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    -H "X-Api-Token: $X_API_TOKEN" \
    -s)
SECRET_KEY=$(echo "$RESPONSE" | jq -r '.secretKey')
ACCESS_KEY=$(echo "$RESPONSE" | jq -r '.accessKey')

echo -e "$ACCESS_KEY\n$SECRET_KEY"

if [[ -z $SECRET_KEY ]]; then
    echo "Failed to retrieve secretKey. Exiting."
    exit 1
fi


# Step 3: Create the Scan
echo "Creating scan..."
RESPONSE=$(curl -s -k -X POST "$NESSUS_URL/scans" \
    -H "Content-Type: application/json" \
    -H "X-Api-Token: $X_API_TOKEN" \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    -d '{
        "uuid": "'"$SCAN_UUID"'",
        "settings": {
            "name": "'"$SCAN_NAME"'",
            "description": "Created using the '"$SCAN_NAME"' template",
            "text_targets": "'"$TARGET_IP"'",
            "folder_id": 3,
            "scanner_id": 1,
            "launch_now": false
        }
    }' )



SCAN_ID=$(echo "$RESPONSE" | jq -r '.scan.id')

if [[ -z "$SCAN_ID" || "$SCAN_ID" == "null" ]]; then
    echo "Failed to create scan. Response: $RESPONSE"
    exit 1
fi
echo "Scan created successfully! Scan ID: $SCAN_ID"

# Step 4: Launch the Scan
echo "Launching scan (ID: $SCAN_ID)..."
curl -k -X POST "$NESSUS_URL/scans/$SCAN_ID/launch" \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" \
    -H "X-Api-Token: $X_API_TOKEN" -s


# Step 6: Wait for Scan Completion
echo -e "\nWaiting for the scan to complete..."
while :; do
    STATUS=$(curl -k -X GET "$NESSUS_URL/scans/$SCAN_ID" \
        -H "X-Cookie: token=$SESSION_TOKEN" \
        -H "X-Api-Token: $X_API_TOKEN" \
        -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" \
        -s | jq -r '.info.status')
    echo "Current scan status: $STATUS"
    if [[ "$STATUS" == "completed" ]]; then
        break
    elif [[ "$STATUS" == "aborted" || "$STATUS" == "canceled" ]]; then
        echo "Scan was aborted or canceled. Exiting."
        exit 1
    fi
    sleep 5
done


# Gather Template ID 
TEMPLATE_ID=$(curl -k -X GET "$NESSUS_URL/reports/custom/templates" \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" \
    -H "X-Api-Token: $X_API_TOKEN" -s | \
    jq -r '.[] | select(.name == "Complete List of Vulnerabilities by Host") | .id ')



# Step 7: Retrieve Export Token
echo "Retrieving export token..."
EXPORT_TOKEN=$(curl -k -X POST "$NESSUS_URL/scans/$SCAN_ID/export" \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    -H "Content-Type: application/json" \
    -H "X-Api-Token: $X_API_TOKEN" \
    -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" \
    -d "{\"format\":\"pdf\",\"template_id\":$TEMPLATE_ID,\"csvColumns\":{},\"formattingOptions\":{},\"extraFilters\":{\"host_ids\":[],\"plugin_ids\":[]},\"plugin_detail_locale\":\"en\"}" \
    -s | jq -r '.file | tonumber')

if [[ -z $EXPORT_TOKEN || ! "$EXPORT_TOKEN" =~ ^[0-9]+$ ]]; then
    echo "Failed to retrieve export token. Exiting."
    exit 1
fi

sleep 30

# Step 8: Export the Report
CURRENT_DATE=$(date +"%m%d%y")
FULL_REPORT_FILE="${SCAN_NAME}_${CURRENT_DATE}.pdf"
echo "Exporting the report..."
curl -k -X GET "$NESSUS_URL/scans/$SCAN_ID/export/$EXPORT_TOKEN/download" -s \
    -H "X-Cookie: token=$SESSION_TOKEN" \
    -H "X-Api-Token: $X_API_TOKEN" \
    -H "X-ApiKeys: accessKey=$ACCESS_KEY; secretKey=$SECRET_KEY" \
    -o "$FULL_REPORT_FILE"

echo "Report saved as $FULL_REPORT_FILE."
