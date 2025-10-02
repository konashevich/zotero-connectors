# My Zotero Web Library Setup

## Overview

This is a local deployment of the Zotero web library frontend that connects to the official Zotero Cloud API at `api.zotero.org`. It does **not** run a self-hosted backend - it only runs the web interface locally while using your existing Zotero account data from the cloud.

## Server Information

- **Host Machine**: 192.168.1.114
- **Operating System**: Linux 6.1.99
- **Docker**: Used for containerized deployment
- **Port**: 9092 (container port 80 mapped to host port 9092)

## Access URLs

- **From same machine**: http://localhost:9092/ or http://127.0.0.1:9092/
- **From network**: http://192.168.1.114:9092/
- **Auto-redirects to**: http://[host]:9092/oleksiiko/library

## Zotero Account Details

- **Username**: oleksiiko
- **User ID**: 14105076
- **Email**: a.konashevich@gmail.com
- **API Key**: [REDACTED_API_KEY] (read/write access to personal library)

## Architecture

### Components

1. **Docker Image**: `zotero-web-latest`
   - Built from custom Dockerfile with multi-stage build
   - Stage 1: Node.js 14 (build the React/Redux SPA)
   - Stage 2: Nginx 1.27 Alpine (serve static files)

2. **Runtime Configuration**: `runtime-entrypoint.sh`
   - Executes before Nginx starts
   - Injects user credentials into the static HTML
   - Embeds API key into configuration JSON
   - Patches any remaining localhost references
   - Adds debug overlay for troubleshooting

3. **Web Server**: Nginx
   - Serves Single Page Application (SPA)
   - Health check endpoint: `/healthz`
   - Fallback routing for client-side navigation

### Configuration Flow

```
Container Start
    ↓
runtime-entrypoint.sh executes
    ↓
1. Rewrite config JSON in index.html
   - Set userSlug: "oleksiiko"
   - Set userId: "14105076"
   - Embed apiKey: "[REDACTED_API_KEY]"
    ↓
2. Inject localStorage backup script
   - Sets localStorage.apiKey as fallback
    ↓
3. Run diagnostics
   - Hot-patch any localhost:8080 → api.zotero.org
    ↓
4. Inject bootstrap config patch
   - Updates JSON from localStorage if empty
    ↓
5. Inject debug overlay
   - Shows userId, userSlug, apiKey info
    ↓
Nginx starts on port 80 (inside container)
    ↓
Exposed on host port 9092
```

## How It Works

### 1. Build-Time Configuration

The Dockerfile applies patches to `src/js/constants/defaults.js`:

```javascript
// Forced to production values at build time
apiConfig: {
    apiAuthorityPart: 'api.zotero.org',  // Changed from localhost:8080
}
websiteUrl: 'https://www.zotero.org/',   // Changed from localhost
streamingApiUrl: '',                      // Disabled (was localhost:1969)
```

### 2. Runtime Configuration

The `runtime-entrypoint.sh` script modifies the static `index.html` file before Nginx starts:

**Original config JSON in index.html:**
```html
<script id="zotero-web-library-config" type="application/json">
    {
        "userSlug": "admin",
        "userId": "1",
        "apiKey": ""
    }
</script>
```

**After runtime rewrite:**
```html
<script id="zotero-web-library-config" type="application/json">
    {
        "userSlug": "oleksiiko",
        "userId": "14105076",
        "apiKey": "[REDACTED_API_KEY]"
    }
</script>
```

### 3. Application Initialization

When the browser loads the page:

1. **Redux reads config**: The `CONFIGURE` action reads the embedded JSON
2. **API client initialized**: Uses `apiKey` for authentication
3. **API requests sent**: All requests go to `https://api.zotero.org/users/14105076/...`
4. **Zotero-API-Key header**: Automatically added to every request
5. **Data loaded**: Collections, items, settings fetched from cloud

### 4. Debug Overlay

A green box appears in the bottom-right corner showing:

```
userId: 14105076
userSlug: oleksiiko
apiKeyLen: 24
apiKey head: E1sO
```

This confirms the configuration was injected correctly.

## Running the Container

### Current Container

```bash
docker ps | grep zotero-web-live
```

Output:
```
ae495b3af665   zotero-web-latest   "/runtime-entrypoint…"   Up (healthy)   0.0.0.0:9092->80/tcp   zotero-web-live
```

### Start Command

```bash
docker run -d --name zotero-web-live \
  -e API_KEY=[REDACTED_API_KEY] \
  -e USER_SLUG=oleksiiko \
  -e USER_ID=14105076 \
  -p 9092:80 \
  zotero-web-latest
```

### Stop/Remove Container

```bash
docker rm -f zotero-web-live
```

### Rebuild Image

```bash
cd /mnt/merged_ssd/Zotero/zotero-selfhost
docker build -t zotero-web-latest -f src/server/web-library/Dockerfile ./src/server/web-library
```

Build time: ~100-130 seconds

## File Locations

### Key Files

- **Dockerfile**: `src/server/web-library/Dockerfile`
- **Runtime script**: `src/server/web-library/runtime-entrypoint.sh`
- **Nginx config**: `src/server/web-library/nginx-spa.conf`
- **Source code**: `src/server/web-library/` (Zotero web-library React app)

### Build Artifacts

Inside container at `/usr/share/nginx/html/`:
- `index.html` - Entry point with injected config
- `static/` - Bundled JavaScript, CSS, assets
- All files served by Nginx

## Troubleshooting

### Check Container Status

```bash
docker ps | grep zotero-web-live
docker logs zotero-web-live
```

### Test From Command Line

```bash
# Test from same machine
curl -I http://localhost:9092/

# Test health endpoint
curl http://localhost:9092/healthz

# Check embedded API key
curl -s http://localhost:9092/ | grep '"apiKey"'
```

### Verify API Key Works

```bash
curl -I -H "Zotero-API-Key: [REDACTED_API_KEY]" \
  "https://api.zotero.org/users/14105076/collections?limit=1"
```

Should return `HTTP/2 200` if key is valid.

### Common Issues

**"This site can't be reached"**
- Check container is running: `docker ps | grep zotero-web-live`
- Use correct URL: `http://192.168.1.114:9092/` from network, `http://localhost:9092/` from same machine
- Check port not blocked by firewall

**403 Forbidden errors in browser console**
- API key invalid or expired
- API key doesn't belong to user ID 14105076
- API key lacks required permissions
- Solution: Generate new key at https://www.zotero.org/settings/keys/new

**Red "Z" spinner never stops**
- Check browser console for errors
- Verify debug overlay shows correct values
- Test API key with curl command above
- Hard refresh browser (Ctrl+Shift+R)

**Config not updating**
- Rebuild container: `docker rm -f zotero-web-live && docker run ...`
- Hard refresh browser to clear cache
- Check `curl -s http://localhost:9092/ | grep apiKey` shows correct key

## API Key Management

### Current Key

- **Key**: [REDACTED_API_KEY]
- **Status**: Valid (tested 2025-10-02)
- **Permissions**: Read/Write access to personal library
- **User**: 14105076 (oleksiiko)

### Generate New Key

1. Go to: https://www.zotero.org/settings/keys/new
2. Log in with: a.konashevich@gmail.com
3. Set permissions:
   - Personal Library: Read/Write (or Read Only)
   - Default Group Permissions: as needed
4. Copy the 24-character key
5. Restart container with new key:

```bash
docker rm -f zotero-web-live
docker run -d --name zotero-web-live \
  -e API_KEY=[NEW_KEY_HERE] \
  -e USER_SLUG=oleksiiko \
  -e USER_ID=14105076 \
  -p 9092:80 \
  zotero-web-latest
```

### Key Security

- Never commit API keys to git
- Keys are injected at runtime via environment variables
- Keys are NOT baked into the Docker image
- Each container start can use a different key

## Network Access

### Same Machine
```
http://localhost:9092/
http://127.0.0.1:9092/
```

### From Other Devices on Network
```
http://192.168.1.114:9092/
```

### Port Forwarding (if needed)

To access from internet, configure router to forward external port to `192.168.1.114:9092`.

**Security warning**: This exposes your Zotero library to the internet. The API key provides authentication, but consider using a reverse proxy with HTTPS and additional authentication.

## Limitations

1. **No self-hosted backend**: Data stored on Zotero servers, not locally
2. **Requires internet**: Must reach api.zotero.org
3. **Single user**: Config hardcoded for oleksiiko (user 14105076)
4. **No file sync**: Attachments downloaded from Zotero cloud storage
5. **API rate limits**: Subject to Zotero's API usage limits

## Benefits

1. **Customizable UI**: Can modify web library source code
2. **Local deployment**: Control hosting and access
3. **Official API**: Uses stable Zotero cloud infrastructure
4. **No backend maintenance**: No database or dataserver to manage
5. **Real-time sync**: Changes sync with desktop/mobile apps

## Maintenance

### Regular Tasks

- **Monitor container**: `docker ps` to ensure healthy status
- **Check logs**: `docker logs zotero-web-live` for errors
- **Rotate API keys**: Generate new keys periodically for security
- **Update image**: Rebuild when Zotero releases updates

### Update Process

```bash
# Pull latest Zotero web-library source
cd /mnt/merged_ssd/Zotero/zotero-selfhost/src/server/web-library
git pull  # if tracking upstream

# Rebuild image
docker build -t zotero-web-latest -f Dockerfile .

# Restart container
docker rm -f zotero-web-live
docker run -d --name zotero-web-live \
  -e API_KEY=[REDACTED_API_KEY] \
  -e USER_SLUG=oleksiiko \
  -e USER_ID=14105076 \
  -p 9092:80 \
  zotero-web-latest
```

## Technical Notes

### Redux Configuration

The app uses Redux for state management. The critical configuration happens in the `CONFIGURE` action:

1. Page loads
2. React mounts
3. `CONFIGURE` action dispatches
4. Reducer reads `window.document.getElementById('zotero-web-library-config').textContent`
5. Parses JSON to get `userSlug`, `userId`, `apiKey`
6. Stores in Redux state
7. API client initialized with these values

This is why the API key **must** be in the JSON before the page loads - localStorage injection happens too late.

### Port Mapping

- **Container internal**: Nginx listens on port 80
- **Host external**: Docker maps 9092 → 80
- **Why 9092**: Port 80 often used by other services, 9092 avoids conflicts

### Health Checks

Docker health check runs every 30 seconds:
```bash
curl -f http://localhost:80/healthz || exit 1
```

Status shown in `docker ps` as "healthy" or "unhealthy".

### BusyBox Compatibility

Alpine Linux uses BusyBox, not GNU utilities. The `runtime-entrypoint.sh` script uses:
- `awk` (not GNU sed with advanced features)
- Portable POSIX shell syntax
- No bash-specific features

This ensures compatibility across minimal container images.

## Summary

This setup provides a **local web interface** to your **cloud-hosted Zotero library**. It's running on `192.168.1.114:9092`, configured for user `oleksiiko` (ID: 14105076), and authenticates with API key `[REDACTED_API_KEY]` to access data at `api.zotero.org`.

All configuration is applied at runtime, so you can easily change the API key or user by restarting the container with different environment variables. The debug overlay confirms the configuration is working correctly.

---

**Last Updated**: October 2, 2025  
**Container**: zotero-web-live (ae495b3af665)  
**Image**: zotero-web-latest  
**Status**: Running and healthy
