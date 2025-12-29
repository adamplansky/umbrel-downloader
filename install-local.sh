#!/bin/bash
set -e

echo "=== File Downloader - Local Install for Umbrel ==="
echo ""

# Check if running on Umbrel
if [ ! -d "$HOME/umbrel" ]; then
    echo "ERROR: Umbrel not found at ~/umbrel"
    echo "Make sure you're running this on your Umbrel device."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_STORE_DIR="$HOME/umbrel/app-stores/local-apps"
APP_DIR="$APP_STORE_DIR/file-downloader"

echo "[1/4] Building Docker image..."
docker build -t file-downloader:latest "$SCRIPT_DIR"

echo ""
echo "[2/4] Creating local app store..."
mkdir -p "$APP_DIR"

# Create app store manifest if it doesn't exist
if [ ! -f "$APP_STORE_DIR/umbrel-app-store.yml" ]; then
    cat > "$APP_STORE_DIR/umbrel-app-store.yml" << 'EOF'
id: local-apps
name: Local Apps
EOF
    echo "    Created app store manifest"
fi

echo ""
echo "[3/4] Installing app files..."
cp "$SCRIPT_DIR/umbrel-app-local/docker-compose.yml" "$APP_DIR/"
cp "$SCRIPT_DIR/umbrel-app-local/umbrel-app.yml" "$APP_DIR/"
echo "    Copied docker-compose.yml"
echo "    Copied umbrel-app.yml"

echo ""
echo "[4/4] Restarting Umbrel..."
sudo "$HOME/umbrel/scripts/stop"
sudo "$HOME/umbrel/scripts/start"

echo ""
echo "=== Installation Complete! ==="
echo ""
echo "Next steps:"
echo "  1. Open http://umbrel.local in your browser"
echo "  2. Go to App Store"
echo "  3. Find 'Local Apps' section"
echo "  4. Install 'File Downloader'"
echo ""
echo "Downloaded files will be saved to:"
echo "  ~/umbrel/app-data/local-apps-file-downloader/downloads/"
echo ""
