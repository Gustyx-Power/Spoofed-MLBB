#!/bin/bash

set -e

PROJECT_DIR="$HOME/Documents/Project/XMS/Spoofed-MLBB"
MODULE_DIR="$PROJECT_DIR/module"
JNI_DIR="$MODULE_DIR/jni"

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Spoofed-MLBB Build System${NC}"
echo -e "${YELLOW}========================================${NC}"

if [ -z "$ANDROID_NDK_ROOT" ]; then
    if [ -d "$HOME/Android/Sdk/ndk/29.0.14206865" ]; then
        export ANDROID_NDK_ROOT="$HOME/Android/Sdk/ndk/29.0.14206865"
    elif [ -d "$HOME/Android/Sdk/ndk/26.1.10909125" ]; then
        export ANDROID_NDK_ROOT="$HOME/Android/Sdk/ndk/26.1.10909125"
    else
        echo -e "${RED}[ERROR] NDK not found${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}[1] NDK: $ANDROID_NDK_ROOT${NC}"

echo -e "${GREEN}[2] Cleaning...${NC}"
rm -rf $MODULE_DIR/libs $MODULE_DIR/obj $PROJECT_DIR/build
mkdir -p $MODULE_DIR/obj $MODULE_DIR/libs
echo -e "${GREEN}    ✓ Cleaned${NC}"

echo -e "${GREEN}[3] Verifying zygisk.hpp...${NC}"
if [ ! -f "$JNI_DIR/zygisk.hpp" ] || [ ! -s "$JNI_DIR/zygisk.hpp" ]; then
    cd "$JNI_DIR"
    rm -f zygisk.hpp
    wget -q https://raw.githubusercontent.com/topjohnwu/Magisk/master/native/src/zygisk/zygisk.hpp
    cd "$PROJECT_DIR"
fi
echo -e "${GREEN}    ✓ zygisk.hpp ready${NC}"

echo -e "${GREEN}[4] Verifying Android.mk...${NC}"
if [ ! -s "$JNI_DIR/Android.mk" ]; then
    cat > "$JNI_DIR/Android.mk" << 'EOFMK'
LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE := spoofed_mlbb
LOCAL_SRC_FILES := main.cpp
LOCAL_C_INCLUDES := $(LOCAL_PATH) $(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include
LOCAL_CFLAGS := -Wall -Wextra -std=c++20 -fno-rtti -fno-exceptions -fPIC
LOCAL_CPPFLAGS := -std=c++20 -fno-rtti -fno-exceptions -fPIC
LOCAL_LDFLAGS := -fuse-ld=lld
LOCAL_LDLIBS := -llog -landroid -ldl
include $(BUILD_SHARED_LIBRARY)
EOFMK
fi
echo -e "${GREEN}    ✓ Android.mk ready${NC}"

echo -e "${GREEN}[5] Verifying main.cpp...${NC}"
if [ ! -s "$JNI_DIR/main.cpp" ]; then
    echo -e "${RED}[ERROR] main.cpp is empty${NC}"
    exit 1
fi
echo -e "${GREEN}    ✓ main.cpp ready${NC}"

echo -e "${GREEN}[6] Building native libraries...${NC}"
cd "$MODULE_DIR"

$ANDROID_NDK_ROOT/ndk-build \
    NDK_PROJECT_PATH=. \
    APP_BUILD_SCRIPT=jni/Android.mk \
    NDK_APPLICATION_MK=jni/Application.mk \
    NDK_OUT=obj \
    NDK_LIBS_OUT=libs \
    APP_ABI="arm64-v8a armeabi-v7a x86 x86_64" \
    APP_PLATFORM=android-21 \
    -j$(nproc) clean 2>&1 | grep -E "Clean|Error" || true

if ! $ANDROID_NDK_ROOT/ndk-build \
    NDK_PROJECT_PATH=. \
    APP_BUILD_SCRIPT=jni/Android.mk \
    NDK_APPLICATION_MK=jni/Application.mk \
    NDK_OUT=obj \
    NDK_LIBS_OUT=libs \
    APP_ABI="arm64-v8a armeabi-v7a x86 x86_64" \
    APP_PLATFORM=android-21 \
    -j$(nproc); then
    echo -e "${RED}[ERROR] Build failed${NC}"
    exit 1
fi

cd "$PROJECT_DIR"
echo -e "${GREEN}    ✓ Build completed${NC}"

echo -e "${GREEN}[7] Verifying output...${NC}"
for arch in arm64-v8a armeabi-v7a x86 x86_64; do
    if [ -f "$MODULE_DIR/libs/$arch/libspoofed_mlbb.so" ]; then
        SIZE=$(stat -c%s "$MODULE_DIR/libs/$arch/libspoofed_mlbb.so" 2>/dev/null || stat -f%z "$MODULE_DIR/libs/$arch/libspoofed_mlbb.so")
        echo -e "${GREEN}    ✓ $arch: $SIZE bytes${NC}"
    else
        echo -e "${RED}    ✗ $arch: NOT FOUND${NC}"
        exit 1
    fi
done

echo -e "${GREEN}[8] Packaging module...${NC}"

PACKAGE_DIR="$PROJECT_DIR/build/output/temp_package"
rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR/zygisk"
mkdir -p "$PACKAGE_DIR/META-INF/com/google/android"

# Copy module.prop
cp $MODULE_DIR/template/module.prop "$PACKAGE_DIR/"
echo -e "${GREEN}    ✓ module.prop included${NC}"

# Copy system.prop
if [ -f "$MODULE_DIR/system.prop" ]; then
    cp "$MODULE_DIR/system.prop" "$PACKAGE_DIR/"
    echo -e "${GREEN}    ✓ system.prop included${NC}"
else
    echo -e "${RED}    ✗ system.prop missing!${NC}"
    exit 1
fi

# Copy .so files
for arch in arm64-v8a armeabi-v7a x86 x86_64; do
    cp $MODULE_DIR/libs/$arch/libspoofed_mlbb.so "$PACKAGE_DIR/zygisk/${arch}.so"
done
echo -e "${GREEN}    ✓ Native libraries included${NC}"

# Create updater scripts
echo "#MAGISK" > "$PACKAGE_DIR/META-INF/com/google/android/updater-script"

# Copy or create update-binary
if [ -f "$MODULE_DIR/update-binary" ]; then
    cp "$MODULE_DIR/update-binary" "$PACKAGE_DIR/META-INF/com/google/android/update-binary"
    chmod 755 "$PACKAGE_DIR/META-INF/com/google/android/update-binary"
    echo -e "${GREEN}    ✓ Custom update-binary included${NC}"
else
    echo -e "${YELLOW}    ⚠ Custom update-binary not found, using default${NC}"
    cat > "$PACKAGE_DIR/META-INF/com/google/android/update-binary" << 'EOFUPDATE'
#!/sbin/sh
OUTFD=$2
ui_print() { echo "ui_print $1" >> /proc/self/fd/$OUTFD; echo "ui_print" >> /proc/self/fd/$OUTFD; }
ui_print "Spoofed-MLBB Module"
ui_print ""
ui_print "Installation Complete!"
ui_print "Reboot to activate"
true
EOFUPDATE
    chmod 755 "$PACKAGE_DIR/META-INF/com/google/android/update-binary"
fi

# Create ZIP
cd "$PACKAGE_DIR"
rm -f ../spoofed-mlbb.zip
zip -r ../spoofed-mlbb.zip . > /dev/null 2>&1
cd "$PROJECT_DIR"

ZIP_SIZE=$(stat -c%s "$PROJECT_DIR/build/output/spoofed-mlbb.zip" 2>/dev/null || stat -f%z "$PROJECT_DIR/build/output/spoofed-mlbb.zip")
rm -rf "$PACKAGE_DIR"

echo -e "${GREEN}    ✓ Module packaged${NC}"

echo -e "${GREEN}[9] Verifying ZIP structure...${NC}"
unzip -l "$PROJECT_DIR/build/output/spoofed-mlbb.zip" | head -20

echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}  Build Complete!${NC}"
echo -e "${YELLOW}========================================${NC}"
echo -e "${GREEN}Output: $PROJECT_DIR/build/output/spoofed-mlbb.zip${NC}"
echo -e "${GREEN}Size: $ZIP_SIZE bytes${NC}"
echo ""

