.PHONY: build clean docker docker-push push pushtoumbrel run test

# Binary name
BINARY=downloader
MODULE=umbrel-downloader

# Docker image
REGISTRY?=ghcr.io
IMAGE_NAME?=$(REGISTRY)/$(shell basename $(CURDIR))
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")

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

# Install to local Umbrel instance
pushtoumbrel:
	./install-local.sh

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
	@echo "  pushtoumbrel   - Install to local Umbrel"
	@echo "  fmt            - Format code"
	@echo "  vet            - Vet code"
	@echo "  test           - Run tests"
	@echo "  check          - Run fmt, vet, test, build"
