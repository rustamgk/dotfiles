#!/bin/bash

# Platform detection and mount setup script
echo "Setting up development environment mounts..."

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="macos"
    HOST_WORKSPACE="/Users/rustamgk/workspace"
    HOST_HELM="/Users/rustamgk/helm"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if grep -qi microsoft /proc/version; then
        PLATFORM="wsl2"
        HOST_WORKSPACE="/mnt/c/Source/workspace"
        HOST_HELM="/mnt/c/Source/helm"
    else
        PLATFORM="linux"
        HOST_WORKSPACE="/home/rustamgk/workspace"
        HOST_HELM="/home/rustamgk/helm"
    fi
else
    PLATFORM="unknown"
    HOST_WORKSPACE="/home/rustamgk/workspace"
    HOST_HELM="/home/rustamgk/helm"
fi

echo "Detected platform: $PLATFORM"
echo "Workspace mount: $HOST_WORKSPACE -> /home/rustamgk/workspace"
echo "Helm mount: $HOST_HELM -> /home/rustamgk/helm"

# Create symbolic links if directories don't exist
if [ ! -d "/home/rustamgk/workspace" ]; then
    echo "Creating workspace directory..."
    mkdir -p /home/rustamgk/workspace
fi

if [ ! -d "/home/rustamgk/helm" ]; then
    echo "Creating helm directory..."
    mkdir -p /home/rustamgk/helm
fi

# Set permissions
chown -R rustamgk:rustamgk /home/rustamgk/workspace /home/rustamgk/helm

echo "Mount setup complete!"
