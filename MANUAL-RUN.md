# Manually Building Zed .deb Packages

This document explains how to manually build Zed .deb packages without waiting for the automated daily build.

## Method 1: Trigger GitHub Action Manually

You can manually trigger the GitHub Action workflow to build and release a new .deb package:

1. Go to the "Actions" tab in this GitHub repository
2. Select the "Daily Zed Pre-release Packaging" workflow
3. Click on "Run workflow" dropdown in the top right
4. Click the green "Run workflow" button
5. Wait for the workflow to complete
6. Go to the "Releases" section to find your newly created .deb package

## Method 2: Run the Build Script Locally

You can also build the .deb package on your own machine:

### Prerequisites

Ensure you have the following dependencies installed:

```bash
sudo apt-get update
sudo apt-get install -y curl jq dpkg-dev fakeroot tar unzip
```

### Building Steps

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/zed-deb.git
   cd zed-deb
   ```

2. Run the build script:
   ```bash
   ./build-deb.sh
   ```

3. The script will:
   - Fetch the latest Zed pre-release version
   - Download the Linux assets
   - Extract the application files
   - Package them into a .deb file
   - Clean up temporary files

4. When complete, you'll have a `zed-preview_x.y.z_amd64.deb` file in the current directory

### Installing the Built Package

Install the package with:

```bash
sudo apt install ./zed-preview_x.y.z_amd64.deb
```

## Troubleshooting

### API Rate Limiting

If you get errors about GitHub API rate limiting, you might need to use a personal access token:

```bash
export GITHUB_TOKEN=your_personal_access_token
./build-deb.sh
```

### File Extraction Issues

If there are issues extracting the Zed files, check:
- The expected file structure may have changed in newer Zed releases
- Make sure you have sufficient disk space
- Check file permissions in your working directory