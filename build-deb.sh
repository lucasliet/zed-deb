#!/bin/bash
set -e

# Zed Editor Debian Package Builder
# This script builds a .deb package for the latest Zed editor pre-release

# Check for required dependencies
check_dependencies() {
  echo "Checking dependencies..."
  for cmd in curl jq dpkg-deb fakeroot tar unzip; do
    if ! command -v $cmd &> /dev/null; then
      echo "Error: $cmd is required but not installed."
      echo "Please install with: sudo apt-get install -y curl jq dpkg-dev fakeroot"
      exit 1
    fi
  done
}

# Get the latest pre-release version
get_latest_prerelease() {
  echo "Fetching latest Zed pre-release..."
  LATEST_PRERELEASE=$(curl -s https://api.github.com/repos/zed-industries/zed/releases | jq '.[] | select(.prerelease==true) | .tag_name' | head -n 1 | tr -d '"')
  if [ -z "$LATEST_PRERELEASE" ]; then
    echo "Error: Could not determine latest pre-release version"
    exit 1
  fi
  echo "Found latest pre-release: $LATEST_PRERELEASE"
}

# Download Linux assets
download_assets() {
  mkdir -p temp_download
  cd temp_download
  
  # Get download URLs for Linux assets
  RELEASE_URL="https://api.github.com/repos/zed-industries/zed/releases/tags/$LATEST_PRERELEASE"
  DOWNLOAD_URLS=$(curl -s $RELEASE_URL | jq '.assets[] | select(.name | contains("zed-linux-")) | .browser_download_url' | tr -d '"')
  
  if [ -z "$DOWNLOAD_URLS" ]; then
    echo "Error: No Linux assets found for version $LATEST_PRERELEASE"
    exit 1
  fi
  
  # Download all Linux assets
  for URL in $DOWNLOAD_URLS; do
    echo "Downloading $URL"
    curl -L -O $URL
  done
  
  cd ..
}

# Extract the downloaded files
extract_files() {
  echo "Extracting files..."
  rm -rf temp_extract app_extract
  mkdir -p temp_extract
  mkdir -p app_extract
  
  # Array to store created package filenames
  CREATED_PACKAGES=()
  
  cd temp_download
  for FILE in zed-linux-*; do
    if [[ ! -f "$FILE" ]]; then
      echo "No matching files found to extract"
      exit 1
    fi
    
    echo "Processing file: $FILE"
    
    # Clean extraction directories for this file
    rm -rf ../temp_extract ../app_extract
    mkdir -p ../temp_extract
    mkdir -p ../app_extract
    
    if [[ $FILE == *.tar.gz ]]; then
      echo "Extracting tar.gz file..."
      tar -xzf "$FILE" -C ../temp_extract
    elif [[ $FILE == *.zip ]]; then
      echo "Extracting zip file..."
      unzip "$FILE" -d ../temp_extract
    fi
    
    # Get directory name from the original file (removing extension)
    DIRNAME="${FILE%.tar.gz}"
    DIRNAME="${DIRNAME%.zip}"
    
    cd ../temp_extract
    echo "Looking for extracted content in temp_extract directory..."
    ls -la
    
    # Try to find the extracted directory
    FOUND_DIR=""
    if [ -d "$DIRNAME" ]; then
      FOUND_DIR="$DIRNAME"
    else
      # If exact name not found, look for any directory
      FOUND_DIR=$(find . -maxdepth 1 -type d | grep -v "^\.$" | head -1)
      FOUND_DIR="${FOUND_DIR#./}"
    fi
    
    if [ -n "$FOUND_DIR" ] && [ -d "$FOUND_DIR" ]; then
      echo "Found extracted directory: $FOUND_DIR"
      echo "Moving extracted files to app_extract directory"
      cp -r "$FOUND_DIR"/* ../app_extract/
      
      # Verify app_extract has content
      cd ..
      echo "Verifying app_extract directory contents:"
      ls -la app_extract
      if [ ! "$(ls -A app_extract)" ]; then
        echo "Error: app_extract directory is empty. Extraction failed."
        exit 1
      fi
      
      # Create package for this architecture
      create_deb_package "$FILE"
      
      # Return to downloads directory for next file
      cd temp_download
    else
      echo "Error: Could not find extracted directory. Check if extraction worked properly."
      ls -la
      exit 1
    fi
  done
  cd ..
}

# Check and modify desktop file to ensure it has StartupWMClass
check_desktop_file() {
  echo "Checking desktop file for StartupWMClass property..."
  
  # Find the desktop file (could be in multiple locations)
  DESKTOP_FILES=$(find zed-deb-pkg -name "*.desktop")
  
  if [ -z "$DESKTOP_FILES" ]; then
    echo "Warning: No .desktop file found in package"
    return
  fi
  
  for DESKTOP_FILE in $DESKTOP_FILES; do
    echo "Found desktop file: $DESKTOP_FILE"
    
    # Check if StartupWMClass is already present
    if grep -q "StartupWMClass=" "$DESKTOP_FILE"; then
      echo "StartupWMClass already exists in $DESKTOP_FILE"
    else
      echo "Adding StartupWMClass=dev.zed.Zed-Preview to $DESKTOP_FILE"
      
      # Find the [Desktop Entry] section and add the property after it
      sed -i '/\[Desktop Entry\]/a StartupWMClass=dev.zed.Zed-Preview' "$DESKTOP_FILE"
      
      # Verify the addition
      if grep -q "StartupWMClass=dev.zed.Zed-Preview" "$DESKTOP_FILE"; then
        echo "Successfully added StartupWMClass property"
      else
        echo "Warning: Failed to add StartupWMClass property"
      fi
    fi
  done
}

# Create DEB package
create_deb_package() {
  local FILE=$1
  echo "Creating DEB package..."
  VERSION=${LATEST_PRERELEASE#v}
  
  # Determine architecture from the file name
  ARCH="amd64"  # Default architecture
  if [[ "$FILE" == *"aarch64"* ]]; then
    ARCH="arm64"
  elif [[ "$FILE" == *"x86_64"* ]]; then
    ARCH="amd64"
  fi
  echo "Detected architecture: $ARCH"
  
  # Create package structure
  rm -rf zed-deb-pkg
  mkdir -p zed-deb-pkg/DEBIAN
  mkdir -p zed-deb-pkg/usr
  
  # Create control file
  cat > zed-deb-pkg/DEBIAN/control << EOF
Package: zed-preview
Version: ${VERSION}
Section: editors
Priority: optional
Architecture: ${ARCH}
Maintainer: Zed Industries <support@zed.dev>
Description: Zed Editor Preview
 A high-performance, multiplayer code editor from the creators of Atom and Tree-sitter.
EOF
  
  # Copy all application files directly to the package maintaining structure
  echo "Copying all application files to package"
  cp -r app_extract/* zed-deb-pkg/usr/ || { echo "Error copying files from app_extract to package"; exit 1; }
  
  # Check and modify the desktop file
  check_desktop_file
  
  # Build the package
  DEB_FILENAME="zed-preview_${VERSION}_${ARCH}.deb"
  dpkg-deb --build --root-owner-group zed-deb-pkg $DEB_FILENAME
  
  # Add to created packages array
  CREATED_PACKAGES+=("$DEB_FILENAME")
  
  echo "Created package: $DEB_FILENAME"
}

# Cleanup temporary files
cleanup() {
  echo "Cleaning up..."
  rm -rf temp_download
  rm -rf temp_extract
  rm -rf zed-deb-pkg
  rm -rf app_extract
}

# Main execution
check_dependencies
get_latest_prerelease
download_assets
extract_files
cleanup

echo "Done! Built the following packages:"
for pkg in "${CREATED_PACKAGES[@]}"; do
  echo "- $pkg"
done
echo "You can install a package with: sudo apt install ./PACKAGE_NAME.deb"