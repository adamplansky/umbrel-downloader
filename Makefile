.PHONY: build clean docker docker-push push pushtoumbrel deploy run test fmt vet check

# Binary name
BINARY=downloader
MODULE=umbrel-downloader

# Docker image
REGISTRY?=ghcr.io
IMAGE_NAME?=$(REGISTRY)/$(shell basename $(CURDIR))
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

# Umbrel SSH
UMBREL_HOST?=umbrel@192.168.2.104
UMBREL_APP_DIR=/home/umbrel/umbrel/app-stores/local-apps/file-downloader

# Build flags
LDFLAGS=-ldflags="-s -w -X main.Version=$(VERSION)"

# Default target
all: build

# Build binary
build:
	go build $(LDFLAGS) -o $(BINARY) .

# Build for Linux (useful for Docker/Umbrel)
build-linux:
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o $(BINARY) .

# Build for ARM64 (Raspberry Pi)
build-arm64:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build $(LDFLAGS) -o $(BINARY) .

# Run locally
run: build
	./$(BINARY) -web :8080

# Clean build artifacts
clean:
	rm -f $(BINARY) $(MODULE)
	go clean

# Build Docker image
docker:
	docker build -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest .

# Build multi-arch Docker image
docker-multiarch:
	docker buildx build --platform linux/amd64,linux/arm64 -t $(IMAGE_NAME):$(VERSION) -t $(IMAGE_NAME):latest .

# Push Docker image to registry
docker-push: docker
	docker push $(IMAGE_NAME):$(VERSION)
	docker push $(IMAGE_NAME):latest

# Git push
push:
	git push origin main

# Push with tags
push-tags:
	git push origin main --tags

# Install to local Umbrel instance (run on Umbrel)
pushtoumbrel:
	./install-local.sh

# Deploy to Umbrel via SSH - single command does everything
deploy:
	@echo "=== Deploying to Umbrel ($(UMBREL_HOST)) ==="
	@echo ""
	@echo "[1/4] Copying source files..."
	ssh $(UMBREL_HOST) "mkdir -p ~/umbrel-downloader"
	scp Dockerfile main.go go.mod $(UMBREL_HOST):~/umbrel-downloader/
	@echo ""
	@echo "[2/4] Building Docker image..."
	ssh $(UMBREL_HOST) "cd ~/umbrel-downloader && docker build -t file-downloader:latest ."
	@echo ""
	@echo "[3/4] Installing app..."
	ssh $(UMBREL_HOST) "mkdir -p $(UMBREL_APP_DIR)"
	ssh $(UMBREL_HOST) "test -f /home/umbrel/umbrel/app-stores/local-apps/umbrel-app-store.yml || echo -e 'id: local-apps\nname: Local Apps' > /home/umbrel/umbrel/app-stores/local-apps/umbrel-app-store.yml"
	scp umbrel-app-local/docker-compose.yml umbrel-app-local/umbrel-app.yml $(UMBREL_HOST):$(UMBREL_APP_DIR)/
	@echo ""
	@echo "[4/4] Restarting app..."
	ssh $(UMBREL_HOST) "cd ~/umbrel && sudo scripts/app restart local-apps-file-downloader 2>/dev/null || sudo scripts/app install local-apps-file-downloader 2>/dev/null || echo 'First time? Install from App Store -> Local Apps'"
	@echo ""
	@echo "=== Done! ==="
	@echo "Downloads go to: /home/umbrel/umbrel/home/Downloads/movies/"

# Format code
fmt:
	go fmt ./...

# Vet code
vet:
	go vet ./...

# Run tests
test:
	go test -v ./...

# Full check before commit
check: fmt vet test build

# Show help
help:
	@echo "Available targets:"
	@echo "  build          - Build binary"
	@echo "  build-linux    - Build for Linux amd64"
	@echo "  build-arm64    - Build for Linux arm64 (Raspberry Pi)"
	@echo "  run            - Build and run with web UI on :8080"
	@echo "  clean          - Remove build artifacts"
	@echo "  docker         - Build Docker image"
	@echo "  docker-multiarch - Build multi-arch Docker image"
	@echo "  docker-push    - Build and push Docker image"
	@echo "  push           - Git push to main"
	@echo "  push-tags      - Git push with tags"
	@echo "  deploy         - Build, install & restart on Umbrel ($(UMBREL_HOST))"
	@echo "  fmt            - Format code"
	@echo "  vet            - Vet code"
	@echo "  test           - Run tests"
	@echo "  check          - Run fmt, vet, test, build"
