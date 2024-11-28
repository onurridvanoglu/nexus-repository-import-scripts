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

# Find and publish all .tgz files
find . -type f -not -path '*/\.*' -name '*.tgz' -exec sh -c '
	echo "Publishing: {}"
	
	# Extract the package
	tar -xzf "{}"
	
	# Update the publishConfig in package/package.json if it exists
	if [ -f "package/package.json" ]; then
		jq ".publishConfig.registry = \"$1\"" package/package.json > package/package.json.tmp
		mv package/package.json.tmp package/package.json
		
		# Repack and publish
		cd package
		npm pack
		npm publish --registry="$1"
		cd ..
		
		# Cleanup
		rm -rf package
	else
		npm publish {} --registry="$1"
	fi
' sh "$REPO_URL" \;
