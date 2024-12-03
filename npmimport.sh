#!/bin/bash

# Function to display usage information
usage() {
    echo "Usage: $0 -r <registry_url>"
    echo
    echo "Options:"
    echo "  -r    Registry URL (required)"
    echo
    exit 1
}

# Get command line params
while getopts ":r:" opt; do
    case $opt in
        r) REPO_URL="$OPTARG"
        ;;
        *) echo "Invalid option: -$OPTARG" >&2
           usage
        ;;
    esac
done

# Ensure REPO_URL is set
if [ -z "$REPO_URL" ]; then
    echo "Error: Registry URL (-r) is required"
    usage
fi

# Counter for successful, failed, and skipped uploads
success_count=0
failed_count=0
skipped_count=0

# Function to check if package exists
check_package_exists() {
    local package_name="$1"
    local version="$2"
    local http_code=$(curl --silent --head --write-out "%{http_code}" --output /dev/null "${REPO_URL}/${package_name}/${version}")
    [ "$http_code" -eq 200 ]
}

# Function to process and publish package
publish_package() {
    local package_file="$1"
    echo "Processing: $package_file"
    
    # Extract the package temporarily
    temp_dir=$(mktemp -d)
    tar -xzf "$package_file" -C "$temp_dir"
    
    if [ -f "$temp_dir/package/package.json" ]; then
        # Get package name and version
        pkg_name=$(jq -r .name "$temp_dir/package/package.json")
        pkg_version=$(jq -r .version "$temp_dir/package/package.json")
        
        # Check if package version already exists
        if check_package_exists "$pkg_name" "$pkg_version"; then
            echo " -> Skipped (version $pkg_version already exists)"
            ((skipped_count++))
        else
            echo " -> Publishing version $pkg_version..."
            
            # Update the publishConfig
            jq ".publishConfig.registry = \"$REPO_URL\"" "$temp_dir/package/package.json" > "$temp_dir/package/package.json.tmp"
            mv "$temp_dir/package/package.json.tmp" "$temp_dir/package/package.json"
            
            # Publish the package
            (cd "$temp_dir/package" && npm pack && npm publish --registry="$REPO_URL") > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo " -> Success"
                ((success_count++))
            else
                echo " -> Failed"
                ((failed_count++))
            fi
        fi
    else
        echo " -> Failed (invalid package format)"
        ((failed_count++))
    fi
    
    # Cleanup
    rm -rf "$temp_dir"
}

echo "Starting npm package upload to $REPO_URL"
echo "----------------------------------------"

# Find and publish all .tgz files
find . -type f -not -path '*/\.*' -name '*.tgz' -exec sh -c '
    publish_package "$1"
' sh {} \;

# Print summary
echo "----------------------------------------"
echo "Upload complete!"
echo "Successfully uploaded: $success_count packages"
echo "Skipped (already exist): $skipped_count packages"
echo "Failed to upload: $failed_count packages"

# Exit with error if any uploads failed
[ "$failed_count" -eq 0 ] || exit 1
