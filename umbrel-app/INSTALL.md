# Installing File Downloader on Umbrel (RPi5)

## Prerequisites
- Raspberry Pi 5 with umbrelOS installed and running
- SSH access to your Umbrel (or terminal access)
- GitHub account (for hosting the Docker image)

---

## Step 1: Push Code to GitHub

First, create a GitHub repository and push your code:

```bash
# In your project directory
git init
git add .
git commit -m "Initial commit"

# Create repo on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/umbrel-downloader.git
git branch -M main
git push -u origin main
```

---

## Step 2: Enable GitHub Container Registry

1. Go to your GitHub repository
2. Go to **Settings** > **Actions** > **General**
3. Under "Workflow permissions", select **Read and write permissions**
4. Click **Save**

The GitHub Action will automatically build multi-arch images (ARM64 for RPi5 + AMD64) and push to `ghcr.io/YOUR_USERNAME/umbrel-downloader:latest`

---

## Step 3: Update docker-compose.yml

Edit `umbrel-app/docker-compose.yml` and replace `your-username` with your actual GitHub username:

```yaml
image: ghcr.io/YOUR_USERNAME/umbrel-downloader:latest
```

---

## Step 4: Create Community App Store (Easiest Method)

### 4a. Fork the Community App Store Template

1. Go to https://github.com/getumbrel/umbrel-community-app-store
2. Click **"Use this template"** > **"Create a new repository"**
3. Name it `umbrel-app-store` (or any name you like)

### 4b. Add Your App

```bash
# Clone your app store repo
git clone https://github.com/YOUR_USERNAME/umbrel-app-store.git
cd umbrel-app-store

# Create your app directory
mkdir file-downloader

# Copy your app files
cp /path/to/umbrel-downloader/umbrel-app/docker-compose.yml file-downloader/
cp /path/to/umbrel-downloader/umbrel-app/umbrel-app.yml file-downloader/
```

### 4c. Configure App Store

Edit `umbrel-app-store.yml`:

```yaml
id: your-username-apps
name: Your App Store
```

**Important:** Update your app's ID in `umbrel-app.yml` to include the store prefix:

```yaml
id: your-username-apps-file-downloader
```

And update `docker-compose.yml` service reference:

```yaml
APP_HOST: your-username-apps-file-downloader_web_1
```

### 4d. Push Changes

```bash
git add .
git commit -m "Add file-downloader app"
git push
```

---

## Step 5: Install on Your Umbrel

### 5a. Add Your Community App Store

1. Open your Umbrel web UI (usually `http://umbrel.local`)
2. Go to **App Store**
3. Click the **three dots** menu (top right)
4. Click **"Community App Stores"**
5. Click **"Add"**
6. Enter your app store URL: `https://github.com/YOUR_USERNAME/umbrel-app-store`
7. Click **"Add"**

### 5b. Install the App

1. Your community app store should now appear in the App Store
2. Find **"File Downloader"**
3. Click **"Install"**
4. Wait for installation to complete

---

## Step 6: Use the App

1. After installation, click **"Open"** or find it in your Umbrel dashboard
2. The web UI opens - paste URLs and download files!
3. Downloaded files are stored in the app's data directory

---

## Alternative: Direct Installation via SSH

If you prefer manual installation:

```bash
# SSH into your Umbrel
ssh umbrel@umbrel.local
# Default password: moneyprintergobrrr (or your custom password)

# Navigate to community app stores
cd ~/umbrel/app-stores

# Clone your app store
git clone https://github.com/YOUR_USERNAME/umbrel-app-store.git

# Restart Umbrel to detect new store
sudo systemctl restart umbrel
```

---

## Accessing Downloaded Files

Downloaded files are stored at:
```
~/umbrel/app-data/your-username-apps-file-downloader/downloads/
```

You can access them via SSH/SFTP or mount this directory.

---

## Updating the App

When you push new code to GitHub:

1. GitHub Actions builds a new Docker image
2. On your Umbrel, go to the app
3. Click **"Update"** (if available) or reinstall

---

## Troubleshooting

### Check app logs:
```bash
ssh umbrel@umbrel.local
docker logs your-username-apps-file-downloader_web_1
```

### Restart the app:
```bash
cd ~/umbrel
./scripts/app restart your-username-apps-file-downloader
```

### Check if image was built:
Visit `https://github.com/YOUR_USERNAME/umbrel-downloader/pkgs/container/umbrel-downloader`

---

## File Structure Summary

```
umbrel-downloader/
├── main.go                 # Your app code
├── go.mod
├── Dockerfile              # Multi-arch Docker build
├── .github/
│   └── workflows/
│       └── docker-build.yml  # Auto-build on push
└── umbrel-app/
    ├── docker-compose.yml  # Umbrel service config
    ├── umbrel-app.yml      # App manifest
    └── INSTALL.md          # This guide

umbrel-app-store/           # Separate repo
├── umbrel-app-store.yml    # Store manifest
└── file-downloader/        # Your app (copy from above)
    ├── docker-compose.yml
    └── umbrel-app.yml
```
