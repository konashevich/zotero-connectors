# Setup Checklist

Use this checklist to configure and test your modified Zotero Connector.

## Pre-Setup

- [ ] You have your Zotero API key (24 characters, from myzotero.md)
- [ ] You know your User ID: `14105076`
- [ ] You know your username: `oleksiiko`
- [ ] Node.js and npm are installed: `node --version && npm --version`

## Configuration

- [ ] Open `/mnt/merged_ssd/Zotero/zotero-connectors/src/common/zotero_config.js`
- [ ] Find the `PRECONFIGURED_AUTH` section (around line 38)
- [ ] Change `ENABLED: false` to `ENABLED: true`
- [ ] Replace `API_KEY: ''` with `API_KEY: 'YOUR_ACTUAL_API_KEY'` (from myzotero.md)
- [ ] Verify `USER_ID: '14105076'` is correct
- [ ] Verify `USERNAME: 'oleksiiko'` is correct
- [ ] Save the file

## Build

```bash
cd /mnt/merged_ssd/Zotero/zotero-connectors
```

- [ ] Run: `npm install`
- [ ] Wait for installation to complete (may take 1-2 minutes)
- [ ] Run: `npm run build`
- [ ] Wait for build to complete (30-60 seconds)
- [ ] Verify build succeeded (no error messages)
- [ ] Check `build/browserExt/` directory exists

## Installation

### For Chrome/Chromium:

- [ ] Open `chrome://extensions/` in Chrome
- [ ] Enable "Developer mode" (toggle in top-right)
- [ ] Click "Load unpacked" button
- [ ] Navigate to `/mnt/merged_ssd/Zotero/zotero-connectors/build/browserExt/`
- [ ] Click "Select Folder"
- [ ] Verify extension appears in list
- [ ] Verify extension is enabled

### For Firefox:

- [ ] Open `about:debugging#/runtime/this-firefox` in Firefox
- [ ] Click "Load Temporary Add-on"
- [ ] Navigate to `/mnt/merged_ssd/Zotero/zotero-connectors/build/browserExt/`
- [ ] Select `manifest.json` file
- [ ] Click "Open"
- [ ] Verify extension appears in list

### For Edge:

- [ ] Open `edge://extensions/` in Edge
- [ ] Enable "Developer mode" (toggle in left sidebar)
- [ ] Click "Load unpacked" button
- [ ] Navigate to `/mnt/merged_ssd/Zotero/zotero-connectors/build/browserExt/`
- [ ] Click "Select Folder"
- [ ] Verify extension appears in list
- [ ] Verify extension is enabled

## Initial Verification

- [ ] Extension icon appears in browser toolbar (red "Z" icon)
- [ ] Click extension icon, then click gear icon (⚙️) for preferences
- [ ] Check "Advanced" section shows username: `oleksiiko`
- [ ] No OAuth/authorization prompt appears

## Test API Key

Open terminal and run:

```bash
curl -I -H "Zotero-API-Key: YOUR_API_KEY" \
  "https://api.zotero.org/users/14105076/collections?limit=1"
```

- [ ] Command returns `HTTP/2 200` (success)
- [ ] No `403 Forbidden` or `401 Unauthorized` errors

## Test Extension - Basic Save

- [ ] Open https://pubmed.ncbi.nlm.nih.gov/36635864/
- [ ] Click Zotero Connector icon in toolbar
- [ ] Icon should show book/paper icon (indicates item detected)
- [ ] Click the icon to save
- [ ] Select save location (default: "My Library")
- [ ] Click "Done" or confirm
- [ ] Success message appears

## Test Extension - Verify Save

- [ ] Open https://www.zotero.org/oleksiiko/library
- [ ] Log in if needed
- [ ] Look for the saved item (title: "Artificial intelligence...")
- [ ] Verify item appears in your library

## Test Local Web UI

- [ ] Open http://192.168.1.114:9092/oleksiiko/library
  - Or from same machine: http://localhost:9092/oleksiiko/library
- [ ] Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)
- [ ] Look for the saved item
- [ ] Verify item appears (may take a moment to sync)

## Test Desktop Client (Optional)

If you have Zotero desktop client installed:

- [ ] Open Zotero desktop application
- [ ] Click green sync arrow button
- [ ] Wait for sync to complete
- [ ] Look for saved item in library
- [ ] Verify item appears

## Advanced Testing

### Test Multiple Items

- [ ] Open https://arxiv.org/search/?query=neural+networks&searchtype=all
- [ ] Click Zotero Connector icon
- [ ] Should show folder icon (multiple items)
- [ ] Click to open item selector
- [ ] Select 2-3 items
- [ ] Click "OK" to save
- [ ] Verify items appear in library

### Test PDF Saving

- [ ] Open a PDF article (e.g., from arXiv or PubMed)
- [ ] Click Zotero Connector icon
- [ ] Should detect PDF and offer to save
- [ ] Save the PDF
- [ ] Verify both metadata and PDF appear in library

### Test Browser Console

- [ ] Press F12 to open browser DevTools
- [ ] Go to "Console" tab
- [ ] Type: `await browser.runtime.sendMessage({method: 'Zotero.API.getUserInfo'})`
- [ ] Press Enter
- [ ] Should return: `{auth-userID: "14105076", auth-username: "oleksiiko", ...}`

## Troubleshooting

### If OAuth prompt still appears:

- [ ] Verify `ENABLED: true` in config
- [ ] Verify API key is correctly set (24 characters)
- [ ] Rebuild: `npm run build`
- [ ] Reload extension in browser:
  - Chrome/Edge: Click "↻" (reload) button on extension
  - Firefox: Click "Reload" button
- [ ] Try again

### If API key is invalid:

- [ ] Check key at https://www.zotero.org/settings/keys
- [ ] Verify key has not expired
- [ ] Verify key has "library access" permission
- [ ] Test key with curl command (see above)
- [ ] Generate new key if needed

### If items don't appear:

- [ ] Wait 30 seconds, then refresh browser
- [ ] Check browser console for errors (F12)
- [ ] Check Zotero.org website for items
- [ ] Check desktop client after sync
- [ ] Verify you're looking at correct account

### If build fails:

- [ ] Delete `node_modules`: `rm -rf node_modules`
- [ ] Delete `package-lock.json`: `rm package-lock.json`
- [ ] Reinstall: `npm install`
- [ ] Try build again: `npm run build`
- [ ] Check for error messages

## Cleanup (Optional)

- [ ] Remove API key from shell history if you ran test commands
- [ ] Add `src/common/zotero_config.js` to git exclude:
  ```bash
  echo "src/common/zotero_config.js" >> .git/info/exclude
  ```
- [ ] Create backup of configured file:
  ```bash
  cp src/common/zotero_config.js src/common/zotero_config.local.js
  ```

## Security Checklist

- [ ] API key is not visible in any committed files
- [ ] Configuration file with real key is not in version control
- [ ] You understand the API key provides full access to your library
- [ ] You know how to rotate the key at https://www.zotero.org/settings/keys
- [ ] You have documented the key location securely (e.g., in myzotero.md)

## Documentation Review

- [ ] Read IMPLEMENTATION_SUMMARY.md (overview of changes)
- [ ] Read YOUR_SETUP.md (your specific configuration)
- [ ] Bookmark SETUP_PRECONFIGURED_AUTH.md (detailed reference)
- [ ] Review ARCHITECTURE_DIAGRAM.txt (visual overview)

## All Done! 🎉

Your Zotero Connector is now configured to:
✅ Use your pre-configured API key
✅ Communicate directly with api.zotero.org
✅ Work with your local web UI
✅ Sync with desktop client and official web UI
✅ Save items without OAuth prompts

---

**Quick Commands Reference:**

```bash
# Rebuild extension
cd /mnt/merged_ssd/Zotero/zotero-connectors
npm run build

# Test API key
curl -I -H "Zotero-API-Key: YOUR_KEY" \
  "https://api.zotero.org/users/14105076/items?limit=1"

# View local web UI
open http://192.168.1.114:9092/oleksiiko/library

# View official web UI
open https://www.zotero.org/oleksiiko/library
```

**Support:**
- See SETUP_PRECONFIGURED_AUTH.md for troubleshooting
- See YOUR_SETUP.md for your specific configuration
- Zotero Forums: https://forums.zotero.org/
