// Example configuration for pre-configured authentication
// Copy this section to src/common/zotero_config.js, replacing the PRECONFIGURED_AUTH section

// For user: oleksiiko (User ID: 14105076)
// Based on setup described in myzotero.md

PRECONFIGURED_AUTH: {
    ENABLED: true,                                    // Set to true to enable direct API key auth
    API_KEY: 'YOUR_API_KEY_HERE',                    // Replace with your actual 24-character API key
    USER_ID: '14105076',                              // Your Zotero user ID
    USERNAME: 'oleksiiko'                             // Your Zotero username
},

// Quick setup instructions:
// 1. Get your API key from: https://www.zotero.org/settings/keys
// 2. Replace 'YOUR_API_KEY_HERE' above with your actual key
// 3. Verify USER_ID and USERNAME match your account
// 4. Set ENABLED to true
// 5. Build the extension: npm run build
// 6. Load in your browser (see SETUP_PRECONFIGURED_AUTH.md for details)

// Security note: 
// - Never commit API keys to public repositories
// - Add config.local.js to .gitignore if using a separate config file
// - Use environment variables for CI/CD deployments
