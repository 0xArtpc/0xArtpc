#!/bin/bash

# Requirements, the linux machine must have the "curl" and "jq" tools
# Installation of both tools
# apt install curl
# apt install jq


# Help menu
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  echo 'Usage: teams-chat-post.sh "<webhook_url>" "<url>" "<cookie>"'
  exit 0
fi

WEBHOOK_URL=$1
if [[ -z "${WEBHOOK_URL}" ]]; then
  echo "No webhook_url specified."
  exit 1
fi
shift

URL=$1
if [[ -z "${URL}" ]]; then
  echo "No URL specified."
  exit 1
fi
shift

COOKIE=$1
if [[ -z "${COOKIE}" ]]; then
  echo "No COOKIE specified."
  exit 1
fi
shift

# Using a cookie value to make requests in the API of nexpose
UPDATED_COOKIE="nexposeCCSessionID=${COOKIE}"

# Fetch and parse vulnerabilities from the given URL
MESSAGE=$(curl "${URL}" -k -b "${UPDATED_COOKIE}" -s | jq -r '.vulnerabilities | to_entries | map("\(.key): \(.value)") | join(", ")')
if [[ -z "${MESSAGE}" ]]; then
  echo "Failed to fetch or parse vulnerabilities from the URL."
  exit 1
fi

# Fetch scan name for the title
SCAN_NAME=$(curl "${URL}" -b "${UPDATED_COOKIE}" -k -s | grep scanName | awk -F'"' '{print $4}')

# Update the message and title
UPDATED_MESSAGE=$(echo -e "Vulnerabilities:\n\n${MESSAGE}")
UPDATED_TITLE="Scan Name: ${SCAN_NAME}"

# Construct JSON using jq to ensure proper formatting
JSON=$(jq -n --arg title "${UPDATED_TITLE}" --arg text "${UPDATED_MESSAGE}" '{title: $title, text: $text}')

# Post to Microsoft Teams
curl -H "Content-Type: application/json" -d "${JSON}" "${WEBHOOK_URL}"
if [[ $? -ne 0 ]]; then
  echo "Failed to send message to Microsoft Teams."
  exit 1
fi
