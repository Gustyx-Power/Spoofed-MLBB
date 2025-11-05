#!/bin/bash

# ===== Spoofed-MLBB Packaging Script =====

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE_DIR="$PROJECT_DIR/module"
BUILD_DIR="$PROJECT_DIR/build"
OUTPUT_DIR="$BUILD_DIR/output"
MODULE_OUTPUT="$OUTPUT_DIR/spoofed-mlbb"

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Spoofed-MLBB Packaging Script${NC}"
echo -e "${YELLOW}========================================${NC}"

# Verify libraries exist
echo -e "${GREEN}[1] Verifying compiled libraries...${NC}"
ARCHS=("arm64-v8a" "armeabi-v7a" "x86" "x86_64")
for arch in "${ARCHS[@]}"; do
    if [ ! -f "$MODULE_DIR/libs/$arch/libspoofed_mlbb.so" ]; then
        echo -e "${RED}[ERROR] Missing $arch library. Run build.sh first!${NC}"
        exit 1
    fi
done
echo -e "${GREEN}  ✓ All libraries verified${NC}"

echo -e "${GREEN}[2] Creating module structure...${NC}"
rm -rf "$MODULE_OUTPUT"
mkdir -p "$MODULE_OUTPUT/zygisk"
mkdir -p "$MODULE_OUTPUT/META-INF/com/google/android"

echo -e "${GREEN}[3] Copying module files...${NC}"
# Copy module.prop
cp "$MODULE_DIR/template/module.prop" "$MODULE_OUTPUT/"

# Copy .so files with correct naming
for arch in "${ARCHS[@]}"; do
    SO_NAME="${arch}.so"
    if [ "$arch" = "arm64-v8a" ]; then
        SO_NAME="arm64-v8a.so"
    elif [ "$arch" = "armeabi-v7a" ]; then
        SO_NAME="armeabi-v7a.so"
    fi

    cp "$MODULE_DIR/libs/$arch/libspoofed_mlbb.so" "$MODULE_OUTPUT/zygisk/$SO_NAME"
    echo -e "${GREEN}  ✓ Copied $arch -> $SO_NAME${NC}"
done

echo -e "${GREEN}[4] Creating updater scripts...${NC}"
echo "#MAGISK" > "$MODULE_OUTPUT/META-INF/com/google/android/updater-script"

cat > "$MODULE_OUTPUT/META-INF/com/google/android/update-binary" << 'EOF'
#!/sbin/sh
OUTFD=$2
ZIPFILE=$3

ui_print() {
  echo "ui_print $1" >> /proc/self/fd/$OUTFD
  echo "ui_print" >> /proc/self/fd/$OUTFD
}

ui_print "========================================="
ui_print "  Spoofed-MLBB v1.0"
ui_print "  Mobile Legends 120FPS Unlocker"
ui_print "========================================="
ui_print ""
ui_print "Installing Zygisk Module..."
ui_print "Device Spoofing: Xiaomi 15"
ui_print ""
ui_print "Please reboot to activate"
ui_print ""

true
EOF

chmod 755 "$MODULE_OUTPUT/META-INF/com/google/android/update-binary"

echo -e "${GREEN}[5] Creating ZIP module...${NC}"
cd "$OUTPUT_DIR"
rm -f spoofed-mlbb.zip
zip -r spoofed-mlbb.zip spoofed-mlbb/
ZIP_SIZE=$(stat -f%z spoofed-mlbb.zip 2>/dev/null || stat -c%s spoofed-mlbb.zip)

cd "$PROJECT_DIR"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Packaging Completed!${NC}"
echo -e "${GREEN}  Output: $OUTPUT_DIR/spoofed-mlbb.zip${NC}"
echo -e "${GREEN}  Size: $ZIP_SIZE bytes${NC}"
echo -e "${GREEN}========================================${NC}"
