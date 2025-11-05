APP_ABI := arm64-v8a armeabi-v7a x86 x86_64
APP_PLATFORM := android-21
APP_STL := c++_static
NDK_TOOLCHAIN_VERSION := clang
APP_CPPFLAGS := -std=c++20 -fno-rtti -fno-exceptions
APP_CFLAGS := -std=c99
APP_LDFLAGS := -fuse-ld=lld
APP_OPTIM := release
APP_SHORT_COMMANDS := true
