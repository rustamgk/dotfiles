# GitHub Actions Setup for Docker Hub

This document explains how to set up the GitHub Actions workflow to automatically build and push Docker images to Docker Hub.

## Required Secrets

To enable automatic building and pushing to Docker Hub, you need to configure the following secrets in your GitHub repository:

### 1. DOCKERHUB_USERNAME
- **Description**: Your Docker Hub username
- **Value**: `rustamgk` (or your actual Docker Hub username)

### 2. DOCKERHUB_TOKEN
- **Description**: Docker Hub Personal Access Token
- **How to get it**:
  1. Log in to [Docker Hub](https://hub.docker.com/)
  2. Go to Account Settings → Security
  3. Click "New Access Token"
  4. Give it a name (e.g., "GitHub Actions")
  5. Copy the generated token

## Setting Up Secrets

1. Go to your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add both secrets:
   - Name: `DOCKERHUB_USERNAME`, Value: `rustamgk`
   - Name: `DOCKERHUB_TOKEN`, Value: (your generated token)

## Docker Hub Repositories

Make sure the following repositories exist on Docker Hub (they will be created automatically on first push):

- `rustamgk/devenv` (for personal environment)
- `rustamgk/devenv-sarna` (for Sarna work environment)
- `rustamgk/devenv-sdui` (for SDUI work environment)

## Triggering Builds

The workflow will automatically trigger when:

1. **Code is pushed** to `main` or `master` branch
2. **Files are changed** in:
   - `Dockerfile*`
   - `configs/**`
   - `scripts/**`
   - `.github/workflows/docker-build.yml`
3. **Manual trigger** via GitHub Actions tab → "Build and Push Docker Images" → "Run workflow"

## Supported Platforms

The workflow builds images for:
- `linux/amd64` (Intel/AMD x64)
- `linux/arm64` (Apple Silicon/ARM64)

This ensures compatibility across different architectures.

## Build Cache

The workflow uses GitHub Actions cache to speed up builds by caching Docker layers between runs.

## Viewing Results

1. Go to the **Actions** tab in your repository
2. Click on the latest "Build and Push Docker Images" workflow run
3. Check the build status and logs
4. Verify images are pushed to Docker Hub

## Local Testing

To test the Docker Hub integration locally:

```bash
# Pull the latest image
docker pull rustamgk/devenv:latest

# Run using the pulled image
./devenv.sh pull
./devenv.sh run
```
