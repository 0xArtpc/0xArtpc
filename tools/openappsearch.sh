#!/bin/bash

# Tool focused to save an open source application directories and files then it searches for those same files inside your target application
# It saves time to lookup for files that are common for that specific application
# Also verifies the content inside the downloaded files and look for sensitive information

# Function to display usage information
usage() {
    echo "Usage: $0 [-f] <target-website> <opensource-repo-url>"
    echo "Example: $0 http://localhost https://github.com/digininja/DVWA"
    echo "Use -f to disable verbose output and filter sensitive files"
    exit 1
}

# Parse flags
verbose=true
while getopts "f" opt; do
    case $opt in
        f)
            verbose=false
            ;;
        *)
            usage
            ;;
    esac
done

# Check if the required number of arguments are provided
shift $((OPTIND - 1))
if [ "$#" -ne 2 ]; then
    usage
fi

# Assign input arguments to variables
target_website=$1
repo_url=$2

# Extract the hostname from the target website
hostname=$(echo "$target_website" | awk -F[/:] '{print $4}')

# Get the repository name from the URL (last part of the URL)
repo_name=$(basename "$repo_url" .git)

# Clone the open-source repository
git clone --no-verbose "$repo_url" "$repo_name" || { echo "Failed to clone repo"; exit 1; }

# Function to test and download files with optional verbose and filtering based on file content
test_and_download_files() {
    # Loop through all files in the cloned repository
    find "$1" -type f | while read -r file; do
        # Construct the target URL for the file
        file_url="${target_website}/${file}"

        # Check if verbose mode is enabled
        if [ "$verbose" = true ]; then
            echo "Checking file: $file_url"
        fi

        # Check if the file exists on the target website
        http_response=$(curl -s -o /dev/null -w "%{http_code}" "$file_url")

        if [ "$http_response" -eq 200 ]; then
            # If file exists, download it
            if [ "$verbose" = true ]; then
                echo "File found: $file_url"
                echo "Downloading file: $file_url"
            fi
            wget -nv "$file_url" -P "$hostname/" 2>/dev/null || echo "Failed to download: $file_url"
        fi
    done
}

# Function to check downloaded files for sensitive keywords and save findings
check_for_sensitive_keywords() {
    # Create the sensitive content file
    output_file="sensitive_content.txt"
    echo "Sensitive findings:" > "$output_file"
    
    # Loop through all downloaded files
    find "$hostname/" -type f | while read -r file; do
        # Search for sensitive keywords followed by '=' with optional spaces around it
        grep -nE "(password\s?=|username\s?=|pass\s?=|user\s?=|key\s?=|id_rsa\s?=|public_key\s?=|secret\s?=|passwd\s?=|admin\s?=|administrator\s?=)" "$file" | while read -r line; do
            # Extract the keyword and value after '='
            keyword_value=$(echo "$line" | sed -E 's/.*(password|username|pass|user|key|id_rsa|public_key|secret|passwd|admin|administrator)\s?=\s*(.*)/\1=\2/')
            echo "Sensitive content found in: $file" | tee -a "$output_file"
            echo "$keyword_value" | tee -a "$output_file"
        done
    done
}

# Create a directory to store the downloaded files
mkdir -p "$hostname"

# Test and download files from the cloned repository
test_and_download_files "$repo_name"

# Check the downloaded files for sensitive keywords
check_for_sensitive_keywords

# Clean up by removing the cloned repository
rm -rf "$repo_name"

echo "Download and verification process complete."
echo "Sensitive findings saved to sensitive_content.txt."

