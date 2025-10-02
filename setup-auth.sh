#!/bin/bash
# Quick setup script for pre-configured authentication
# This script will update your zotero_config.js with your credentials

# IMPORTANT: Never commit this file with real credentials to version control!
# Add this file to .gitignore if you fill it in with real credentials

# Your Zotero credentials - FILL THESE IN:
API_KEY=""          # Your 24-character API key from https://www.zotero.org/settings/keys
USER_ID=""          # Your numeric Zotero user ID
USERNAME=""         # Your Zotero username

# Validation
if [ -z "$API_KEY" ] || [ -z "$USER_ID" ]; then
    echo "ERROR: Please set API_KEY and USER_ID in this script before running"
    echo ""
    echo "To get these values:"
    echo "1. Go to https://www.zotero.org/settings/keys"
    echo "2. Create a new private key (if you don't have one)"
    echo "3. Your User ID will be shown on that page"
    echo "4. Copy your API key (24 characters)"
    echo ""
    echo "Then edit this script and set:"
    echo "  API_KEY='your-24-char-key'"
    echo "  USER_ID='your-numeric-id'"
    echo "  USERNAME='your-username'"
    exit 1
fi

CONFIG_FILE="src/common/zotero_config.js"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: Cannot find $CONFIG_FILE"
    echo "Please run this script from the zotero-connectors root directory"
    exit 1
fi

echo "Configuring pre-configured authentication..."
echo "User ID: $USER_ID"
echo "Username: $USERNAME"
echo "API Key: ${API_KEY:0:4}... (first 4 characters shown)"
echo ""

# Backup the original file
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
echo "Created backup: $CONFIG_FILE.backup"

# Use sed to update the configuration
# This is a simple approach - for production, use a proper config management system
sed -i.tmp "s/ENABLED: false,/ENABLED: true,/" "$CONFIG_FILE"
sed -i.tmp "s/API_KEY: '',/API_KEY: '$API_KEY',/" "$CONFIG_FILE"
sed -i.tmp "s/USER_ID: '',/USER_ID: '$USER_ID',/" "$CONFIG_FILE"
sed -i.tmp "s/USERNAME: ''/USERNAME: '$USERNAME'/" "$CONFIG_FILE"
rm -f "$CONFIG_FILE.tmp"

echo "Configuration updated successfully!"
echo ""
echo "Next steps:"
echo "1. Build the extension: npm run build"
echo "2. Load the extension in your browser"
echo "3. Test by saving an item from a webpage"
echo ""
echo "To revert changes: cp $CONFIG_FILE.backup $CONFIG_FILE"
