LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := spoofed_mlbb

LOCAL_SRC_FILES := main.cpp

LOCAL_C_INCLUDES := \
	$(LOCAL_PATH) \
	$(ANDROID_NDK_ROOT)/sources/cxx-stl/llvm-libc++/include

LOCAL_CFLAGS := \
	-Wall \
	-Wextra \
	-Wno-unused-parameter \
	-std=c++20 \
	-fno-rtti \
	-fno-exceptions \
	-fPIC

LOCAL_CPPFLAGS := \
	-std=c++20 \
	-fno-rtti \
	-fno-exceptions \
	-fPIC

LOCAL_LDFLAGS := -fuse-ld=lld

LOCAL_LDLIBS := -llog -landroid -ldl

ifeq ($(TARGET_ARCH),arm)
	LOCAL_ARM_MODE := arm
	LOCAL_ARM_NEON := true
endif

include $(BUILD_SHARED_LIBRARY)
