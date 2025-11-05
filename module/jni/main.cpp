#include <android/log.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "zygisk.hpp"

#define LOG_TAG "Spoofed-MLBB"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)

using zygisk::Api;

class SpoofedMLBBMinimal : public zygisk::ModuleBase {
public:
    void onLoad(Api* api, JNIEnv* env) override {
        LOGI("Spoofed-MLBB Minimal - Model Only");
    }

    void preAppSpecialize(zygisk::AppSpecializeArgs* args) override {
    }

    void postAppSpecialize(const zygisk::AppSpecializeArgs* args) override {
    }
};

REGISTER_ZYGISK_MODULE(SpoofedMLBBMinimal)
