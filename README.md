# Spoofed-MLBB

**Device Model Spoofer Zygisk Module for Mobile Legends**

---

## 📱 Overview

Spoofed-MLBB is a Zygisk module designed to spoof the device model of an Android system. This module intercepts and modifies system properties related to the device's identity, such as `ro.product.model`, `ro.product.name`, and `ro.product.brand`.

By altering these properties to match those of a high-end device—specifically the Xiaomi 15 in this case—it tricks the Android operating system and applications into recognizing the device as a different, more powerful model. The primary goal is to unlock features or performance modes in certain applications (like Mobile Legends: Bang Bang) that are typically reserved for flagship devices. This is achieved by making the system believe it is running on a Xiaomi 15, equipped with a top-tier processor.

---

## 🎯 Target Device

**Spoofed As:** Xiaomi 15

| Property | Value |
|----------|-------|
| Model Code | 24129PN74C |
| Device Name | dada |
| Brand | Xiaomi |
| Processor | Snapdragon 8 Elite |


---

## 📋 Requirements

- **Root Access** (Magisk atau KernelSU)
- **Zygisk Module Support** (Magisk 26.0+ atau KernelSU latest)
- **Android 12+** (tested on Android 16 POCO F5)

---

## 🔧 Installation

### Via Magisk Manager

1. Download `spoofed-mlbb.zip`
2. Open Magisk Manager
3. Tap **Modules** → **Install from storage**
4. Select the ZIP file
5. **Reboot** device

### Via KernelSU

1. Open KernelSU app
2. Go to **Modules**
3. **Install from file** → Select `spoofed-mlbb.zip`
4. **Reboot**


---

## 📚 References

- [Magisk Documentation](https://topjohnwu.github.io/Magisk/)
- [Zygisk Sample](https://github.com/topjohnwu/zygisk-module-sample)
- [Xiaomi 15 Specifications](https://www.gsmarena.com/xiaomi_15-13472.php)

---

## 🤝 Credits

**Developed by**: Gustyx-Power

**Based on**:
- Magisk by topjohnwu
- Zygisk Framework
- Android NDK

**Special thanks to**:
- Magisk Community


---

## 📄 License

This project is provided as-is for educational/development purposes.

---

## ⚖️ Legal Notice

**WARNING**: This module is for development/testing purposes only. Unauthorized modification of device properties may:

- Violate app Terms of Service
- Trigger anti-cheat systems
- Result in account bans
- Breach device warranty

**Use at your own risk!** The author is not responsible for any consequences.

---

## 🐛 Reporting Issues

Found a Problem?

1. Check troubleshooting section
2. Verify your setup matches requirements
3. Check Magisk/KernelSU logs
4. Report with:
    - Device model
    - ROM name and version
    - Magisk/KernelSU version
    - Logcat output

---

## 🔄 Changelog

### v1.0
- ✅ Zygisk module rewrite
- ✅ KernelSU support
- ✅ Xiaomi 15 spoof
- ✅ Minimal, fast implementation
- ✅ Better logging



