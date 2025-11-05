#!/bin/bash

# ===== Spoofed-MLBB Installation Script =====

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="$PROJECT_DIR/build/output"
ZIP_FILE="$OUTPUT_DIR/spoofed-mlbb.zip"

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Spoofed-MLBB Installation Script${NC}"
echo -e "${YELLOW}========================================${NC}"

# Verify ZIP exists
if [ ! -f "$ZIP_FILE" ]; then
    echo -e "${RED}[ERROR] $ZIP_FILE not found!${NC}"
    echo "Run: bash scripts/build.sh && bash scripts/package.sh"
    exit 1
fi

# Check device connection
echo -e "${GREEN}[1] Checking device connection...${NC}"
if ! adb devices | grep -q "device$"; then
    echo -e "${RED}[ERROR] No ADB device found!${NC}"
    exit 1
fi
echo -e "${GREEN}  ✓ Device connected${NC}"

# Push to device
echo -e "${GREEN}[2] Pushing module to device...${NC}"
adb push "$ZIP_FILE" /sdcard/Download/spoofed-mlbb.zip
echo -e "${GREEN}  ✓ File pushed${NC}"

# Install via Magisk
echo -e "${GREEN}[3] Installing module via Magisk...${NC}"
adb shell su -c "magisk module install /sdcard/Download/spoofed-mlbb.zip"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}  ✓ Module installed successfully${NC}"
else
    echo -e "${RED}  ✗ Installation failed${NC}"
    exit 1
fi

# Reboot
echo -e "${GREEN}[4] Rebooting device...${NC}"
adb shell reboot

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Installation Completed!${NC}"
echo -e "${GREEN}  Device will reboot...${NC}"
echo -e "${GREEN}========================================${NC}"
