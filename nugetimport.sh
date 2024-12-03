#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -r <repository_url> -k <api_key>"
    echo
    echo "Options:"
    echo "  -r    Repository URL (required)"
    echo "  -k    API Key (required)"
    echo
    exit 1
}

# Get command line params
while getopts ":r:k:" opt; do
    case $opt in
        r) REPO_URL="$OPTARG"
        ;;
        k) APIKEY="$OPTARG"
        ;;
        *) echo "Invalid option: -$OPTARG" >&2
           usage
        ;;
    esac
done

# Validate required parameters
if [ -z "$REPO_URL" ] || [ -z "$APIKEY" ]; then
    echo "Error: Missing required parameters"
    usage
fi

# Counter for successful, failed, and skipped uploads
success_count=0
failed_count=0
skipped_count=0

# Function to check if package exists
check_package_exists() {
    local package_file="$1"
    # Extract package ID and version using nuget
    local package_info=$(nuget list "$package_file" -Source "$REPO_URL" 2>/dev/null)
    [ ! -z "$package_info" ]
}

# Function to upload package
upload_package() {
    local package_file="$1"
    echo "Processing: $package_file"
    
    if check_package_exists "$package_file"; then
        echo " -> Skipped (package already exists)"
        ((skipped_count++))
    else
        echo " -> Uploading..."
        if nuget push "$package_file" "$APIKEY" -Source "$REPO_URL" > /dev/null 2>&1; then
            echo " -> Success"
            ((success_count++))
        else
            echo " -> Failed"
            ((failed_count++))
        fi
    fi
}

echo "Starting NuGet package upload to $REPO_URL"
echo "----------------------------------------"

# Find and upload all .nupkg files
while IFS= read -r package; do
    upload_package "$package"
done < <(find . -type f -not -path '*/\.*' -name '*.nupkg')

# Print summary
echo "----------------------------------------"
echo "Upload complete!"
echo "Successfully uploaded: $success_count packages"
echo "Skipped (already exist): $skipped_count packages"
echo "Failed to upload: $failed_count packages"

# Exit with error if any uploads failed
[ "$failed_count" -eq 0 ] || exit 1
