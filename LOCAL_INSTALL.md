# Local Installation on Umbrel (No GitHub Required)

This guide installs the File Downloader directly on your RPi5 Umbrel without pushing anything to GitHub.

---

## Method 1: Build Directly on RPi5 (Simplest)

### Step 1: Copy Project to Umbrel

From your computer:
```bash
# Copy entire project to Umbrel
scp -r /home/adam/workspace/personal/umbrel-downloader umbrel@umbrel.local:~/
```

### Step 2: SSH into Umbrel

```bash
ssh umbrel@umbrel.local
# Password: moneyprintergobrrr (or your custom password)
```

### Step 3: Build Docker Image

```bash
cd ~/umbrel-downloader
docker build -t file-downloader:latest .
```

### Step 4: Create App in Umbrel

```bash
# Create app directory in Umbrel's app store
mkdir -p ~/umbrel/app-stores/local-apps/file-downloader

# Copy app config
cp ~/umbrel-downloader/umbrel-app-local/docker-compose.yml ~/umbrel/app-stores/local-apps/file-downloader/
cp ~/umbrel-downloader/umbrel-app-local/umbrel-app.yml ~/umbrel/app-stores/local-apps/file-downloader/
```

### Step 5: Create App Store Manifest

```bash
cat > ~/umbrel/app-stores/local-apps/umbrel-app-store.yml << 'EOF'
id: local-apps
name: Local Apps
EOF
```

### Step 6: Restart Umbrel

```bash
sudo ~/umbrel/scripts/stop
sudo ~/umbrel/scripts/start
```

### Step 7: Install from Umbrel UI

1. Open `http://umbrel.local`
2. Go to **App Store**
3. Find **"Local Apps"** section
4. Install **"File Downloader"**

---

## Method 2: One-Line Install Script

### Step 1: Copy Project to Umbrel

```bash
scp -r /home/adam/workspace/personal/umbrel-downloader umbrel@umbrel.local:~/
```

### Step 2: Run Install Script

```bash
ssh umbrel@umbrel.local
cd ~/umbrel-downloader
chmod +x install-local.sh
./install-local.sh
```

---

## Accessing Downloaded Files

Files are saved to:
```
~/umbrel/app-data/local-apps-file-downloader/downloads/
```

Access via SFTP or SSH:
```bash
ssh umbrel@umbrel.local
ls ~/umbrel/app-data/local-apps-file-downloader/downloads/
```

---

## Updating After Code Changes

```bash
# On your computer - copy updated files
scp -r /home/adam/workspace/personal/umbrel-downloader umbrel@umbrel.local:~/

# On Umbrel - rebuild and restart
ssh umbrel@umbrel.local
cd ~/umbrel-downloader
docker build -t file-downloader:latest .
docker restart local-apps-file-downloader_web_1
```

---

## Uninstalling

From Umbrel UI: Go to App > Uninstall

Or manually:
```bash
ssh umbrel@umbrel.local
rm -rf ~/umbrel/app-stores/local-apps/file-downloader
rm -rf ~/umbrel/app-data/local-apps-file-downloader
sudo ~/umbrel/scripts/stop && sudo ~/umbrel/scripts/start
```

---

## Troubleshooting

### View logs:
```bash
docker logs local-apps-file-downloader_web_1 -f
```

### Restart app:
```bash
docker restart local-apps-file-downloader_web_1
```

### Check if running:
```bash
docker ps | grep file-downloader
```
