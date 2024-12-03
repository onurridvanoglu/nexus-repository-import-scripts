#!/bin/bash

# Get command line params
while getopts ":r:k:" opt; do
    case $opt in
        r) REPO_URL="$OPTARG"
        ;;
    esac
done

# Ensure REPO_URL is set
if [ -z "$REPO_URL" ]; then
    echo "Error: Registry URL (-r) is required"
    exit 1
fi

echo "Starting npm package upload to $REPO_URL"
echo "----------------------------------------"
echo "Looking for .tgz files..."

# Find and publish all .tgz files
find . -type f -not -path '*/\.*' -name '*.tgz' -exec sh -c '
    echo "----------------------------------------"
    echo "Publishing: {}"
    echo "-> Extracting package..."
    
    # Extract the package
    tar -xzf "{}"
    
    # Update the publishConfig in package/package.json if it exists
    if [ -f "package/package.json" ]; then
        echo "-> Found package.json"
        echo "-> Package details:"
        echo "   Name: $(jq -r .name package/package.json)"
        echo "   Version: $(jq -r .version package/package.json)"
        echo "-> Updating publish configuration..."
        
        jq ".publishConfig.registry = \"$1\"" package/package.json > package/package.json.tmp
        mv package/package.json.tmp package/package.json
        
        # Repack and publish
        echo "-> Publishing to registry..."
        cd package
        npm pack
        npm publish --registry="$1"
        publish_status=$?
        cd ..
        
        # Cleanup
        echo "-> Cleaning up temporary files..."
        rm -rf package
        
        if [ $publish_status -eq 0 ]; then
            echo "-> Package published successfully"
        else
            echo "-> Failed to publish package"
        fi
    else
        echo "-> No package.json found, attempting direct publish..."
        npm publish {} --registry="$1"
        if [ $? -eq 0 ]; then
            echo "-> Package published successfully"
        else
            echo "-> Failed to publish package"
        fi
    fi
    echo "----------------------------------------"
' sh "$REPO_URL" \;

echo "Upload process complete!"
echo "Check the output above for details of each package"
echo "Note: You may want to verify the packages in Nexus"
