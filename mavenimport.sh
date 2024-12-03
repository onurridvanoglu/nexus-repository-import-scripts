#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -r <repository_url> -u <username> -p <password>"
    echo
    echo "Options:"
    echo "  -r    Repository URL (required)"
    echo "  -u    Username (required)"
    echo "  -p    Password (required)"
    echo
    exit 1
}

# Get command line params
while getopts ":r:u:p:" opt; do
    case $opt in
        r) REPO_URL="$OPTARG"
        ;;
        u) USERNAME="$OPTARG"
        ;;
        p) PASSWORD="$OPTARG"
        ;;
        *) echo "Invalid option: -$OPTARG" >&2
           usage
        ;;
    esac
done

# Validate required parameters
if [ -z "$REPO_URL" ] || [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Error: Missing required parameters"
    usage
fi

# Remove trailing slash from repo URL if present
REPO_URL="${REPO_URL%/}"

# Counter for successful, failed, and skipped uploads
success_count=0
failed_count=0
skipped_count=0

# Function to check if file exists in repository
check_file_exists() {
    local relative_path="$1"
    local http_code=$(curl -u "$USERNAME:$PASSWORD" \
                          --silent \
                          --head \
                          --write-out "%{http_code}" \
                          --output /dev/null \
                          "${REPO_URL}/${relative_path}")
    
    [ "$http_code" -eq 200 ]
}

# Function to upload a file
upload_file() {
    local file="$1"
    local relative_path="${file#./}"
    
    echo "Processing: $relative_path"
    
    # Check if file already exists
    if check_file_exists "$relative_path"; then
        echo " -> Skipped (already exists)"
        ((skipped_count++))
        return 0
    fi
    
    echo " -> Uploading..."
    if curl -u "$USERNAME:$PASSWORD" \
         -X PUT \
         --fail \
         --silent \
         --show-error \
         --write-out "%{http_code}" \
         --output /dev/null \
         -T "$file" \
         "${REPO_URL}/${relative_path}"; then
        echo " -> Success"
        ((success_count++))
        return 0
    else
        echo " -> Failed"
        ((failed_count++))
        return 1
    fi
}

echo "Starting Maven artifact upload to $REPO_URL"
echo "----------------------------------------"

# Find and upload files
while IFS= read -r file; do
    upload_file "$file"
done < <(find . -type f \
    -not -path './mavenimport.sh*' \
    -not -path '*/\.*' \
    -not -path '*/\^archetype-catalog\.xml*' \
    -not -path '*/\^maven-metadata-local*\.xml' \
    -not -path '*/\^maven-metadata-deployment*\.xml')

# Print summary
echo "----------------------------------------"
echo "Upload complete!"
echo "Successfully uploaded: $success_count files"
echo "Skipped (already exist): $skipped_count files"
echo "Failed to upload: $failed_count files"

# Exit with error if any uploads failed
[ "$failed_count" -eq 0 ] || exit 1
