# Zed Editor Debian Package Generator

This repository automatically packages the latest Zed editor pre-releases into Debian (.deb) packages for easier installation on Debian-based Linux distributions.

## How It Works

A GitHub Actions workflow runs daily to:

1. Fetch the latest Zed pre-release from the [official Zed repository](https://github.com/zed-industries/zed)
2. Download the Linux assets (typically .tar.gz or .zip archives)
3. Extract the application files
4. Package them into a proper Debian package format
5. Create a new release in this repository with the .deb file as an asset

## Installation

### Option 1: Download and Install

1. Go to the [Releases page](../../releases) of this repository
2. Download the latest `zed-preview_x.y.z_amd64.deb` file
3. Install with:
   ```
   sudo dpkg -i zed-preview_x.y.z_amd64.deb
   sudo apt-get install -f
   ```

### Option 2: Install Directly

```bash
# Replace the URL with the actual release asset URL
sudo apt install ./zed-preview_x.y.z_amd64.deb
```

## Usage

After installation, you can launch Zed from your application menu or run:

```bash
zed-preview
```

## Automation

This repository uses GitHub Actions to automatically check for new Zed pre-releases every day. If a new pre-release is found, it automatically packages it and publishes a new release.

## Disclaimer

This is an unofficial packaging of Zed Editor. The actual application is developed by [Zed Industries](https://github.com/zed-industries).

## License

This packaging project is licensed under the MIT License - see the LICENSE file for details. The packaged Zed Editor itself retains its original licensing.