plugins {
    id("com.android.application") version "8.1.0"
}

android {
    namespace = "com.gustyx.spoofedmlbb"
    compileSdk = 34
    ndkVersion = "29.0.14206865"

    defaultConfig {
        applicationId = "com.gustyx.spoofedmlbb"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

tasks.register("buildModule") {
    description = "Build Spoofed-MLBB Zygisk Module"
    dependsOn("clean")
    doLast {
        println("Building Spoofed-MLBB module...")
        exec {
            workingDir = file("module")
            commandLine("bash", "build.sh")
        }
    }
}

tasks.register("installModule") {
    description = "Install module to connected device"
    dependsOn("buildModule")
    doLast {
        println("Installing Spoofed-MLBB module...")
        exec {
            workingDir = file("scripts")
            commandLine("bash", "install.sh")
        }
    }
}
