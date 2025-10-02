# Pre-Configured Authentication for Zotero Connectors

## What's Changed

This fork adds support for **direct API key authentication** to the Zotero Connectors extension, allowing you to bypass the OAuth flow and use a pre-configured API key.

## Why This Is Useful

The standard Zotero Connector requires users to go through an OAuth authorization flow. This modification allows:

- **Pre-configured deployments**: Set up the extension with credentials built-in
- **Simplified authentication**: Skip the OAuth popup/redirect flow
- **Custom setups**: Integrate with self-hosted Zotero web interfaces
- **Testing & development**: Quickly switch between accounts or test environments
- **Automated installations**: Deploy pre-configured extensions in managed environments

## Quick Start

### 1. Configure Your Credentials

Edit `src/common/zotero_config.js` and find the `PRECONFIGURED_AUTH` section:

```javascript
PRECONFIGURED_AUTH: {
    ENABLED: true,                    // Change to true
    API_KEY: 'your-24-char-api-key',  // Add your API key
    USER_ID: '14105076',              // Add your user ID
    USERNAME: 'your-username'         // Add your username
},
```

### 2. Get Your Credentials

- **API Key**: Generate at https://www.zotero.org/settings/keys
- **User ID**: Shown on the API key creation page
- **Username**: Your Zotero username

### 3. Build and Install

```bash
npm install
npm run build
# Load build/browserExt/ as unpacked extension in your browser
```

See [`SETUP_PRECONFIGURED_AUTH.md`](./SETUP_PRECONFIGURED_AUTH.md) for detailed instructions.

## Files Modified

- **`src/common/zotero_config.js`**: Added `PRECONFIGURED_AUTH` configuration section
- **`src/common/api.js`**: Added methods:
  - `setCredentials()`: Set credentials directly
  - `initPreconfiguredAuth()`: Initialize from config
- **`src/common/zotero.js`**: Calls `initPreconfiguredAuth()` on startup

## New Files

- **`SETUP_PRECONFIGURED_AUTH.md`**: Comprehensive setup guide
- **`config-example.js`**: Configuration example
- **`setup-auth.sh`**: Quick setup script (optional)
- **`README_PRECONFIGURED_AUTH.md`**: This file

## How It Works

1. On extension startup, `Zotero.API.initPreconfiguredAuth()` is called
2. If `PRECONFIGURED_AUTH.ENABLED` is true, credentials are read from config
3. Credentials are stored in browser storage using `Zotero.Prefs.set()`
4. All API requests use the pre-configured API key
5. OAuth flow is completely bypassed

## Example Configuration for User "oleksiiko"

Based on the setup in `myzotero.md`:

```javascript
PRECONFIGURED_AUTH: {
    ENABLED: true,
    API_KEY: 'E1sOxxxxxxxxxxxxxxxxxxxxx',  // Your actual key here
    USER_ID: '14105076',
    USERNAME: 'oleksiiko'
},
```

This user has:
- A local Zotero web interface at http://192.168.1.114:9092
- An API key with read/write access to personal library
- User ID: 14105076

Both the local web interface and this modified connector communicate with the official `api.zotero.org` backend.

## API Endpoint Configuration

By default, the extension communicates with `https://api.zotero.org/`. If you're running a custom Zotero dataserver, you can also change:

```javascript
API_URL: 'https://your-custom-api.example.com/',
```

**Note**: Most users do NOT need to change this. The local web interface described in `myzotero.md` still uses the official `api.zotero.org` backend.

## Security Considerations

⚠️ **Important Security Notes:**

1. **Never commit API keys to public repositories**
2. API keys provide full access to your Zotero library
3. Use environment variables or gitignored config files for real credentials
4. Rotate keys regularly at https://www.zotero.org/settings/keys
5. Create separate keys for different purposes (dev, prod, etc.)
6. Consider using read-only keys for development/testing

### Recommended .gitignore Entries

```gitignore
# Local configuration with real credentials
config.local.js
setup-auth.sh  # If you've added real credentials
src/common/zotero_config.js.backup
```

## Programmatic API

You can also set credentials programmatically:

```javascript
// Set credentials
await Zotero.API.setCredentials('API_KEY', 'USER_ID', 'USERNAME');

// Get current credentials
let userInfo = await Zotero.API.getUserInfo();

// Clear credentials
await Zotero.API.clearCredentials();

// Re-initialize from config
await Zotero.API.initPreconfiguredAuth();
```

## Disabling Pre-Configured Auth

To revert to standard OAuth flow:

1. Set `PRECONFIGURED_AUTH.ENABLED` to `false` in `zotero_config.js`
2. Rebuild: `npm run build`
3. Reload extension in browser

Or programmatically:

```javascript
await Zotero.API.clearCredentials();
// Then restart the extension or trigger OAuth
```

## Testing Your Configuration

After installation, test by:

1. Opening a journal article page (e.g., PubMed, arXiv)
2. Clicking the Zotero Connector icon
3. Saving the item to your library
4. Checking your library at https://www.zotero.org/your-username/library

If configured correctly, you should NOT see an OAuth authorization prompt.

## Troubleshooting

### Extension doesn't use pre-configured credentials

- Check that `ENABLED: true` in config
- Verify you rebuilt after changing config: `npm run build`
- Check browser console for errors
- Try: `await Zotero.API.initPreconfiguredAuth()` in console

### "API key could not be verified"

- Test your key manually:
  ```bash
  curl -I -H "Zotero-API-Key: YOUR_KEY" \
    "https://api.zotero.org/users/YOUR_ID/collections"
  ```
- Check key hasn't expired at https://www.zotero.org/settings/keys
- Verify key has library access permissions

### Items save to wrong account

- Double-check User ID matches your API key
- Clear old credentials: `await Zotero.API.clearCredentials()`
- Re-initialize: `await Zotero.API.initPreconfiguredAuth()`

## Compatibility

- ✅ Chrome/Chromium
- ✅ Firefox
- ✅ Edge
- ✅ Safari (untested but should work)
- ✅ Manifest V2 and V3

## Upstream Compatibility

These changes are designed to be minimally invasive. The modifications:

- Don't break existing OAuth functionality
- Only activate when explicitly enabled in config
- Use the same storage mechanism as OAuth (browser.storage)
- Follow existing code patterns and conventions

You can merge upstream changes without conflicts in most cases.

## Contributing

If you find issues or have improvements:

1. Check existing issues in the original Zotero Connectors repo
2. For pre-configured auth specific issues, open an issue in this fork
3. Submit pull requests with clear descriptions

## Related Documentation

- [Zotero Web API Documentation](https://www.zotero.org/support/dev/web_api/v3/start)
- [Original Zotero Connectors README](./README.md)
- [Zotero Connectors Build Instructions](./CONTRIBUTING.md)
- [API Key Management](https://www.zotero.org/settings/keys)

## License

This modification follows the same license as Zotero Connectors: **AGPL v3**

See [COPYING](./COPYING) for details.

## Credits

- Original Zotero Connectors by [Zotero](https://www.zotero.org/)
- Pre-configured authentication modification by @konashevich
- Inspired by the need for simplified authentication in custom deployments

## Version History

- **1.0.0** (2025-10-02): Initial implementation
  - Added `PRECONFIGURED_AUTH` configuration
  - Added `setCredentials()` and `initPreconfiguredAuth()` methods
  - Auto-initialization on extension startup
  - Comprehensive documentation

---

**Quick Reference:**

- Config file: `src/common/zotero_config.js`
- API methods: `src/common/api.js`
- Initialization: `src/common/zotero.js`
- Setup guide: [`SETUP_PRECONFIGURED_AUTH.md`](./SETUP_PRECONFIGURED_AUTH.md)
- Example config: [`config-example.js`](./config-example.js)
