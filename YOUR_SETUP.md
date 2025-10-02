# Your Zotero Connector Configuration

## Quick Setup for User: oleksiiko

Based on your setup described in `myzotero.md`, here's your exact configuration:

### Step 1: Edit Configuration

Open `src/common/zotero_config.js` and update the `PRECONFIGURED_AUTH` section:

```javascript
PRECONFIGURED_AUTH: {
    ENABLED: true,
    API_KEY: 'YOUR_ACTUAL_API_KEY',  // Replace with your 24-character key
    USER_ID: '14105076',              // Your user ID (already filled in)
    USERNAME: 'oleksiiko'             // Your username (already filled in)
},
```

**Important**: Replace `'YOUR_ACTUAL_API_KEY'` with your actual API key from `myzotero.md` (the one marked as [REDACTED_API_KEY]).

### Step 2: Build the Extension

```bash
cd /mnt/merged_ssd/Zotero/zotero-connectors
npm install
npm run build
```

Build time: approximately 30-60 seconds (first build may take longer).

### Step 3: Install in Browser

#### For Chrome:
1. Open `chrome://extensions/`
2. Enable "Developer mode" (top right toggle)
3. Click "Load unpacked"
4. Select `/mnt/merged_ssd/Zotero/zotero-connectors/build/browserExt/`

#### For Firefox:
1. Open `about:debugging#/runtime/this-firefox`
2. Click "Load Temporary Add-on"
3. Navigate to `/mnt/merged_ssd/Zotero/zotero-connectors/build/browserExt/`
4. Select `manifest.json`

#### For Edge:
1. Open `edge://extensions/`
2. Enable "Developer mode"
3. Click "Load unpacked"
4. Select `/mnt/merged_ssd/Zotero/zotero-connectors/build/browserExt/`

### Step 4: Test

1. Navigate to a journal article (e.g., https://pubmed.ncbi.nlm.nih.gov/36635864/)
2. Click the Zotero Connector icon in your browser toolbar
3. The item should save directly without an OAuth prompt
4. Check your library at: https://www.zotero.org/oleksiiko/library

## Your Setup Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Browser with Modified Zotero Connector                 │
│  - Pre-configured with your API key                     │
│  - User ID: 14105076                                     │
│  - Username: oleksiiko                                   │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ HTTPS Requests with
                   │ Zotero-API-Key header
                   ↓
┌─────────────────────────────────────────────────────────┐
│  Official Zotero API                                     │
│  https://api.zotero.org/                                │
│  - Receives all save/sync requests                      │
│  - Stores your library data                             │
└──────────────────┬──────────────────────────────────────┘
                   │
                   │ Same data accessible via:
                   │
    ┌──────────────┼──────────────┐
    ↓              ↓               ↓
┌─────────┐  ┌──────────┐  ┌──────────────────┐
│ Desktop │  │ Web UI   │  │ Local Web UI     │
│ Client  │  │ Official │  │ 192.168.1.114    │
│         │  │ zotero.  │  │ :9092            │
│         │  │ org      │  │                  │
└─────────┘  └──────────┘  └──────────────────┘
```

**Key Points:**
- Both your modified connector AND your local web UI (port 9092) communicate with `api.zotero.org`
- Your local web UI is just a frontend, not a separate API server
- All data is stored in Zotero cloud
- Items saved via connector appear everywhere (desktop, web, local UI) after sync

## Verification Checklist

- [ ] `ENABLED: true` in `zotero_config.js`
- [ ] API key is 24 characters long
- [ ] User ID is `14105076`
- [ ] Username is `oleksiiko`
- [ ] Extension built successfully (`npm run build`)
- [ ] Extension loaded in browser
- [ ] Can save items without OAuth prompt
- [ ] Items appear in library at https://www.zotero.org/oleksiiko/library
- [ ] Items appear in local web UI at http://192.168.1.114:9092/oleksiiko/library

## Troubleshooting Your Setup

### Can't access local web UI
- Check Docker container is running: `docker ps | grep zotero-web-live`
- From same machine: http://localhost:9092/
- From network: http://192.168.1.114:9092/

### Connector saves to wrong account
- Verify User ID in config matches API key owner
- Check: `curl -H "Zotero-API-Key: YOUR_KEY" https://api.zotero.org/keys/current`
- Should return user ID 14105076

### 403 Forbidden errors
- Check API key permissions at https://www.zotero.org/settings/keys
- Ensure "Allow library access" is enabled
- Ensure "Allow write access" is enabled (for saving items)

### Items don't appear in local web UI
- Hard refresh browser (Ctrl+Shift+R)
- Check debug overlay in bottom-right of web UI
- Verify API key matches between connector and web UI container

### Build errors
```bash
cd /mnt/merged_ssd/Zotero/zotero-connectors
rm -rf node_modules package-lock.json
npm install
npm run build
```

## Files You Modified

Only 3 files were changed:

1. **`src/common/zotero_config.js`**
   - Added `PRECONFIGURED_AUTH` configuration block

2. **`src/common/api.js`**
   - Added `setCredentials()` method
   - Added `initPreconfiguredAuth()` method

3. **`src/common/zotero.js`**
   - Added call to `initPreconfiguredAuth()` in `initGlobal()`

## Keeping Configuration Secure

Your API key provides full access to your Zotero library. Keep it secure:

```bash
# Never commit the configured file
cd /mnt/merged_ssd/Zotero/zotero-connectors
echo "src/common/zotero_config.js" >> .git/info/exclude

# Or use a separate untracked config file
cp src/common/zotero_config.js src/common/zotero_config.local.js
# Edit zotero_config.local.js with your credentials
# Import it in your build process
```

## Updating from Upstream

If you want to pull updates from the official Zotero Connectors repo:

```bash
# Add upstream remote (if not already added)
git remote add upstream https://github.com/zotero/zotero-connectors.git

# Fetch upstream changes
git fetch upstream

# Merge (may need to resolve conflicts in the 3 modified files)
git merge upstream/master

# Rebuild
npm run build
```

The modifications are minimal and should merge cleanly in most cases.

## Your Specific Configuration Summary

| Setting | Value |
|---------|-------|
| **API URL** | `https://api.zotero.org/` (default, no change needed) |
| **API Key** | *See myzotero.md* (24 characters, starts with E1sO) |
| **User ID** | `14105076` |
| **Username** | `oleksiiko` |
| **Email** | `a.konashevich@gmail.com` |
| **Local Web UI** | `http://192.168.1.114:9092/` |
| **Official Web UI** | `https://www.zotero.org/oleksiiko/library` |

## Next Steps

1. **Configure**: Edit `src/common/zotero_config.js` with your API key
2. **Build**: Run `npm run build`
3. **Install**: Load as unpacked extension in browser
4. **Test**: Save an item from a webpage
5. **Verify**: Check https://www.zotero.org/oleksiiko/library and http://192.168.1.114:9092/

## Support

- For questions about these modifications, see `README_PRECONFIGURED_AUTH.md`
- For detailed setup instructions, see `SETUP_PRECONFIGURED_AUTH.md`
- For Zotero API questions, see https://www.zotero.org/support/dev/web_api/v3/start
- For Zotero Connectors questions, see https://forums.zotero.org/

---

**Important**: Keep your API key secure and never commit it to public repositories!
