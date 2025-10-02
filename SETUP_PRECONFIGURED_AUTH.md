# Pre-configured Authentication Setup Guide

This guide explains how to configure the Zotero Connector extension to use direct API key authentication instead of the OAuth flow.

## Overview

By default, the Zotero Connector uses OAuth to authorize with your Zotero account. However, if you already have an API key, you can configure the extension to use it directly, bypassing the OAuth flow.

This is useful for:
- Custom deployments with pre-configured credentials
- Testing and development
- Automated setups
- Using with self-hosted Zotero web interfaces

## Prerequisites

You need the following information from your Zotero account:

1. **API Key**: A 24-character key from https://www.zotero.org/settings/keys
2. **User ID**: Your numeric Zotero user ID
3. **Username**: Your Zotero username (optional but recommended)

### Finding Your User ID

To find your User ID:

1. Go to https://www.zotero.org/settings/keys
2. Create a new private key (if you don't have one already)
3. Your User ID is displayed on the key creation page
4. Or, look at the URL of your library: `https://www.zotero.org/[username]/library` - the User ID is visible in the API response

Alternatively, if you have access to your API key, you can get your user ID by visiting:
```
https://api.zotero.org/keys/[YOUR_API_KEY]
```

### Generating an API Key

1. Go to https://www.zotero.org/settings/keys/new
2. Set a description (e.g., "Zotero Connector")
3. Set permissions:
   - **Personal Library**: Read/Write (or Read Only if you only want to save items)
   - **Default Group Permissions**: As needed
4. Click "Save Key"
5. Copy the 24-character key immediately (you won't be able to see it again)

## Configuration

### Method 1: Direct Configuration (Recommended for Development)

Edit `src/common/zotero_config.js` and update the `PRECONFIGURED_AUTH` section:

```javascript
PRECONFIGURED_AUTH: {
    ENABLED: true,                        // Set to true to enable
    API_KEY: 'YOUR_24_CHARACTER_API_KEY', // Your Zotero API key
    USER_ID: '14105076',                  // Your numeric user ID
    USERNAME: 'oleksiiko'                 // Your Zotero username
},
```

### Method 2: Environment Variables (For Build Systems)

If you're building the extension with a build system, you can inject these values at build time using environment variables or a separate config file that's not committed to version control.

Create a file `config.local.js` (add to `.gitignore`):

```javascript
// config.local.js
const LOCAL_CONFIG = {
    API_KEY: 'YOUR_24_CHARACTER_API_KEY',
    USER_ID: '14105076',
    USERNAME: 'oleksiiko'
};
```

Then modify your build process to inject these values.

## Example Configuration

Here's a complete example for user "oleksiiko" (User ID: 14105076):

```javascript
PRECONFIGURED_AUTH: {
    ENABLED: true,
    API_KEY: 'E1sOxxxxxxxxxxxxxxxxxxxxx', // Replace with your actual key
    USER_ID: '14105076',
    USERNAME: 'oleksiiko'
},
```

## Building and Installing

After configuring, build the extension:

### For Chrome/Edge:

```bash
npm install
npm run build
# The built extension will be in build/browserExt/
```

Then load as an unpacked extension:
1. Go to `chrome://extensions/` (Chrome) or `edge://extensions/` (Edge)
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select the `build/browserExt/` directory

### For Firefox:

```bash
npm install
npm run build
# The built extension will be in build/browserExt/
```

Then load as a temporary add-on:
1. Go to `about:debugging#/runtime/this-firefox`
2. Click "Load Temporary Add-on"
3. Select any file in the `build/browserExt/` directory (e.g., `manifest.json`)

### For Safari:

```bash
./build.sh -b s
```

Follow the Safari extension installation process.

## Verification

After installation:

1. Click on the Zotero Connector icon in your browser toolbar
2. Go to "Preferences" (gear icon)
3. Under "Advanced", you should see your username displayed
4. Try saving an item from a webpage (e.g., from a journal article page)

If configured correctly, you should **not** see an OAuth authorization prompt. The extension will use your pre-configured credentials immediately.

## Security Considerations

### Important Security Notes:

1. **Never commit API keys to version control**
   - Add `config.local.js` to `.gitignore`
   - Use environment variables for CI/CD
   - Rotate keys regularly

2. **API Key Permissions**
   - Only grant necessary permissions
   - Consider using read-only keys for development
   - Create separate keys for different purposes

3. **Sharing Configurations**
   - Never share your built extension with embedded credentials
   - Use proper secrets management for team deployments
   - Document the configuration process without exposing keys

4. **Key Rotation**
   - Periodically generate new API keys
   - Revoke old keys after updating configuration
   - Monitor API key usage at https://www.zotero.org/settings/keys

## Disabling Pre-configured Authentication

To revert to OAuth flow:

1. Edit `src/common/zotero_config.js`
2. Set `PRECONFIGURED_AUTH.ENABLED` to `false`
3. Rebuild and reinstall the extension

Or, in the extension:

1. Open browser console
2. Go to the extension's background page
3. Run: `await Zotero.API.clearCredentials()`
4. Reload the extension

## Troubleshooting

### Extension doesn't recognize credentials

1. Check that `ENABLED` is set to `true`
2. Verify your API key is correct (24 characters)
3. Verify your User ID is correct (numeric)
4. Check browser console for errors
5. Rebuild and reinstall the extension

### "API key could not be verified" error

1. Check that your API key is valid at https://www.zotero.org/settings/keys
2. Ensure the key has not expired
3. Verify the key has appropriate permissions (at least library read access)
4. Test the key manually:
   ```bash
   curl -H "Zotero-API-Key: YOUR_API_KEY" \
     "https://api.zotero.org/users/YOUR_USER_ID/collections?limit=1"
   ```

### Saves go to wrong account

1. Double-check your User ID matches your API key
2. Clear old credentials:
   ```javascript
   await Zotero.API.clearCredentials()
   await Zotero.API.initPreconfiguredAuth()
   ```
3. Verify at https://www.zotero.org/YOUR_USERNAME/library

### Cannot save items (403 errors)

1. Check API key permissions at https://www.zotero.org/settings/keys
2. Ensure "Allow library access" and "Allow write access" are enabled
3. Regenerate key with correct permissions if needed

## Using with Local Web Interface

If you're using a local Zotero web interface (like the one at http://192.168.1.114:9092), note that:

1. The connector still communicates with `api.zotero.org` (the official API)
2. Your local web interface also communicates with `api.zotero.org`
3. Both use the same API key for authentication
4. Items saved via the connector will appear in both:
   - Your local web interface
   - The official Zotero website
   - The Zotero desktop application (after sync)

This is because the local web interface is just a frontend - all data is stored in Zotero's cloud.

## API Reference

### Programmatic Authentication

You can also set credentials programmatically from the browser console or extension code:

```javascript
// Set credentials
await Zotero.API.setCredentials(
    'YOUR_24_CHARACTER_API_KEY',
    '14105076',
    'oleksiiko'
);

// Get current credentials
let userInfo = await Zotero.API.getUserInfo();
console.log(userInfo);

// Clear credentials
await Zotero.API.clearCredentials();

// Re-initialize pre-configured auth
await Zotero.API.initPreconfiguredAuth();
```

## Further Customization

### Changing API Endpoint

If you're running a self-hosted Zotero dataserver (not just the web interface), you can also change the API URL:

Edit `src/common/zotero_config.js`:

```javascript
API_URL: 'https://your-custom-zotero-api.example.com/',
```

**Note**: This requires a full Zotero dataserver installation, not just the web library frontend.

### Multiple User Profiles

For switching between multiple Zotero accounts, you could:

1. Create separate browser profiles
2. Install the extension in each profile
3. Configure each with different credentials
4. Or, implement a UI to switch credentials dynamically

## Support

For issues with:
- **Zotero Connector**: https://forums.zotero.org/discussion/98445/
- **Zotero API**: https://www.zotero.org/support/dev/web_api/v3/start
- **API Keys**: https://www.zotero.org/settings/keys

## Changelog

- **v1.0** (2025-10-02): Initial implementation of pre-configured authentication
  - Added `PRECONFIGURED_AUTH` configuration
  - Added `setCredentials()` and `initPreconfiguredAuth()` methods
  - Auto-initialization on extension startup

## License

This extension modification follows the same license as the original Zotero Connectors project (AGPL v3).
