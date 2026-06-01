# MECHREVO WUJIE 15XA (无界15X) — Arch Linux Wiki

**Model**: WUJIE15XA / **Board**: WUJIE15-GX5HRXG / **BIOS**: American Megatrends N.1.14MRO19 (2025-01-17)

> This document is a community-maintained compatibility guide for running Arch Linux on the MECHREVO WUJIE 15XA laptop. Both English and Chinese sections are included.
>
> 本文档是社区维护的、在机械革命无界15XA笔记本上运行 Arch Linux 的兼容性指南，包含中英双语内容。

---

## 目录 | Table of Contents

- [Hardware Overview | 硬件概览](#hardware-overview--硬件概览)
- [Hardware Compatibility | 硬件兼容性](#hardware-compatibility--硬件兼容性)
- [Installation | 安装](#installation--安装)
- [Firmware | 固件](#firmware--固件)
- [Hardware Control | 硬件控制](#hardware-control--硬件控制)
- [CPU Governor & Power Management | CPU 调频与电源管理](#cpu-governor--power-management--cpu-调频与电源管理)
- [Function Keys | 功能键](#function-keys--功能键)
- [Troubleshooting | 故障排除](#troubleshooting--故障排除)
- [See Also | 参考](#see-also--参考)

---

## Hardware Overview | 硬件概览

| Component | Detail |
|---|---|
| CPU | AMD Ryzen 7 8845HS (8C/16T, 416–5102 MHz) |
| GPU | AMD Radeon 780M (RDNA3, HawkPoint1) `1002:1900` |
| RAM | 24 GB DDR5 (soldered + SODIMM) |
| Display | 2560×1600 eDP, 120 Hz |
| SSD 1 | Micron 2550 NVMe 1 TB `1344:5416` |
| SSD 2 | WD SN560/SN740/SN770 NVMe 1 TB `15b7:5017` |
| Wi-Fi | MediaTek MT7922 `14c3:7922` (802.11ax) |
| Ethernet | Motorcomm YT6801 `1f0a:6801` Gigabit |
| Bluetooth | MediaTek (integrated with MT7922) |
| Audio | Realtek ALC256 (HDA) via AMD Audio CoProcessor |
| Webcam | 720p HD Webcam (USB, uvcvideo) |
| TPM | TPM 2.0 |
| Battery | 80 Wh Li-ion (OEM) |
| Charging | USB-C PD |

---

## Hardware Compatibility | 硬件兼容性

| Device | ID | Works | Note |
|---|---|---|---|
| Touchpad | PS/2 | ✅ | |
| Keyboard | PS/2 | ✅ | |
| GPU | `1002:1900` | ✅ | amdgpu driver |
| Audio (HDMI) | `1002:1640` | ✅ | snd-hda-intel |
| Audio (Internal) | `1022:15e3` | ✅ | snd-hda-intel, Realtek ALC256 |
| Audio CoProcessor | `1022:15e2` | ✅ | amd-pmf / audio DSP |
| Ethernet | `1f0a:6801` | ✅ | Needs `tuxedo-yt6801-dkms-git` (AUR) |
| Wi-Fi | `14c3:7922` | ✅ | mt7921e (in-kernel) |
| Bluetooth | — | ✅ | btusb (in-kernel) |
| Webcam | — | ✅ | uvcvideo |
| TPM | — | ✅ | tpm_crb |
| NVMe 1 | `1344:5416` | ✅ | Micron 2550 |
| NVMe 2 | `15b7:5017` | ✅ | WD SN560/SN740/SN770 |
| Sensors | — | ✅ | k10temp, amdgpu, nvme, spd5118 |

---

## Installation | 安装

### Disable Secure Boot

Secure Boot is enabled by default. Press `Del` repeatedly during startup to enter UEFI setup and disable it.

### Ethernet Driver

The YT6801 Ethernet controller needs a DKMS driver:

```bash
yay -S tuxedo-yt6801-dkms-git
```

If you need wired networking during installation, build a custom ArchISO that includes this module, or use a USB tethering / Wi-Fi.

### Recommended Kernel Parameters

Add the following to your bootloader config:

```
acpi.ec_no_wakeup=1
```

This prevents the laptop from immediately waking after suspend.

---

## Firmware | 固件

### BIOS / EC

Official BIOS/EC updates are available from [Mechrevo support (Chinese)](https://gwqd.mechrevo.com/service/). The update utility runs on Windows only — you may need a temporary Windows installation to apply updates.

### fwupd

[fwupd](https://wiki.archlinux.org/title/Fwupd) supports updating the UEFI revocation database:

```bash
fwupdmgr refresh
fwupdmgr update
```

### SSD Firmware

- **Micron 2550**: Use `micron-storage-executive-cli` (AUR) or bootable ISO
- **WD SNxxx**: Use `nvme-cli` or Western Digital Dashboard

---

## Hardware Control | 硬件控制

### Platform Drivers

Install the Mechrevo/TUXEDO platform drivers:

```bash
yay -S mechrevo-drivers-dkms
```

This package provides: `tuxedo_keyboard`, `tuxedo_io`, `uniwill_wmi`, `clevo_acpi`.

After reboot, verify:

```bash
lsmod | grep -iE "tuxedo|uniwill"
# should show: tuxedo_keyboard, tuxedo_io, uniwill_wmi, tuxedo_compatibility_check
```

### Battery Charging Profile

The charging mode is available at `/sys/devices/platform/tuxedo_keyboard/charging_profile/`.

```bash
# View available profiles
cat /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profiles_available
# high_capacity  balanced  stationary

# Set a profile
echo balanced | sudo tee /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profile
```

| Profile | Description |
|---|---|
| `high_capacity` | Charge to 100% (default) |
| `balanced` | Charge to ~80% |
| `stationary` | Charge to ~60%, best for long-term AC use |

### Fan Control

Install the Tuxedo fan control daemon:

```bash
yay -S tailord tailor-cli tailor-hwcaps
sudo systemctl enable --now tailord
```

Check fan status:

```bash
sudo tailor_hwcaps
# Number of fans: 1
# Fan temperatures [°C]: [48]
# Fan speeds [%]: [2]
```

### TUXEDO Control Center

For a GUI to manage fan curves, performance profiles, and battery settings:

```bash
yay -S tuxedo-control-center-bin
sudo systemctl enable --now tccd
```

**Note**: On this laptop, only the `default` platform profile is available through tccd. The performance/balanced/quiet profile switching seen in Windows is not yet supported.

### Keyboard Backlight

Fn+F6 cycles through off → low → high. There is no known software interface to control the backlight. The auto-on/off and timeout features on Windows are implemented in software by a service, not handled by hardware.

---

## CPU Governor & Power Management | CPU 调频与电源管理

The AMD Ryzen 7 8845HS uses the `amd-pstate-epp` driver.

### Available Governors & EPP

```bash
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors
# performance powersave

cat /sys/devices/system/cpu/cpu0/cpufreq/energy_performance_available_preferences
# default performance balance_performance balance_power power
```

### Known Issue: tccd Resetting Governor

> When using `amd-pstate`, the TUXEDO Control Center daemon (`tccd`) may repeatedly reset the CPU governor to `performance`, increasing power consumption on battery.

### Recommended Fix: cpu-mode Script

A helper script is included in this repository to manage governor profiles:

```bash
# Install
sudo cp scripts/cpu-mode /usr/local/bin/cpu-mode
sudo chmod +x /usr/local/bin/cpu-mode

# Usage
cpu-mode status          # View current state
cpu-mode auto            # Auto: balanced on AC, powersave on battery (default)
cpu-mode performance     # Gaming/AI: performance + performance EPP
cpu-mode balanced        # AC mode: powersave + balance_performance
cpu-mode powersave       # Battery mode: powersave + power EPP
```

A systemd watchdog service is included to catch tccd reverts:

```bash
# Install watchdog
sudo cp scripts/cpu-governor-watchdog.service /etc/systemd/system/
sudo systemctl enable --now cpu-governor-watchdog.service
```

The watchdog checks every 60 seconds and applies the correct governor/EPP based on the current mode. When in `performance` mode, the watchdog will not override.

---

## Function Keys | 功能键

| Key | Visible | Marked | Effect |
|---|---|---|---|
| Fn+F1 | ✅ | ✅ | XF86Sleep |
| Fn+F2 | ✅ | ✅ | Lock screen |
| Fn+F3 | ✅ | ✅ | XF86Display |
| Fn+F4 | ✅ | ✅ | XF86RFKill |
| Fn+F5 | ✅ | ✅ | XF86TouchpadToggle |
| Fn+F6 | ✅ | ✅ | Keyboard backlight toggle |
| Fn+F7 | ✅ | ✅ | XF86AudioMute |
| Fn+F8 | ✅ | ✅ | XF86AudioLowerVolume |
| Fn+F9 | ✅ | ✅ | XF86AudioRaiseVolume |
| Fn+F10 | ✅ | ✅ | XF86MonBrightnessDown |
| Fn+F11 | ✅ | ✅ | XF86MonBrightnessUp |
| Fn+F12 | ✅ | ✅ | Insert |

---

## Troubleshooting | 故障排除

### Immediate Wake from Suspend

Add `acpi.ec_no_wakeup=1` to kernel parameters. This is already included in the recommended config above.

### No Audio

Ensure `pipewire` and `wireplumber` are installed and running:

```bash
systemctl --user enable --now pipewire wireplumber
```

Check audio cards:

```bash
cat /proc/asound/cards
# 0: HD-Audio Generic (HDMI/DP)
# 1: HD-Audio Generic (Internal, ALC256)
```

### Wi-Fi Not Working

The MT7922 requires `linux-firmware` package. Ensure it is installed:

```bash
pacman -S linux-firmware
```

### Bluetooth Not Working

Ensure `bluez` and `bluez-utils` are installed and the service is running:

```bash
sudo systemctl enable --now bluetooth
bluetoothctl
```

---

## See Also | 参考

- [Mechrevo Official Support (Chinese)](https://gwqd.mechrevo.com/service/)
- [ArchWiki: Mechrevo WUJIE14X (sibling model)](https://wiki.archlinux.org/title/Mechrevo_WUJIE14X)
- [w568w's ACPI reverse-engineering on WUJIE14XA](https://gist.github.com/w568w/b2fc5f9d1f4dff13efe751abec27b396)
- [sund3RRR's fixes and tweaks for mechrevo14X](https://github.com/sund3RRR/mechrevo14X-linux)

---

## 中文版 | Chinese Version

> 以下是上面内容的纯中文版本。硬件兼容性表不再重复。

### 硬件兼容表

| 设备 | ID | 可用 | 说明 |
|---|---|---|---|
| 触控板 | PS/2 | ✅ | |
| 键盘 | PS/2 | ✅ | |
| 显卡 | `1002:1900` | ✅ | amdgpu 驱动 |
| 音频 (HDMI) | `1002:1640` | ✅ | |
| 音频 (内置) | `1022:15e3` | ✅ | Realtek ALC256 |
| 以太网 | `1f0a:6801` | ✅ | 需 `tuxedo-yt6801-dkms-git` |
| Wi-Fi | `14c3:7922` | ✅ | 内核原生支持 |
| 蓝牙 | 集成 | ✅ | btusb 驱动 |
| 摄像头 | USB | ✅ | uvcvideo |
| TPM | — | ✅ | TPM 2.0 |

### 安装要点

1. **关闭 Secure Boot**（开机按 Del 进 BIOS）
2. **以太网驱动**：安装 `tuxedo-yt6801-dkms-git`（AUR）
3. **内核参数**：添加 `acpi.ec_no_wakeup=1`（防睡眠后自动唤醒）

### 平台驱动

```bash
yay -S mechrevo-drivers-dkms linux-zen-headers
# 重启后检查
lsmod | grep -iE "tuxedo|uniwill"
```

### 电池充电模式

```bash
# 查看可选模式
cat /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profiles_available
# high_capacity（满充） balanced（~80%） stationary（~60%）

# 切换模式
echo balanced | sudo tee /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profile
```

### 风扇控制

```bash
yay -S tailord tailor-cli tailor-hwcaps
sudo systemctl enable --now tailord
sudo tailor_hwcaps
```

### CPU 性能模式

内置 `cpu-mode` 脚本一键切换：

```
cpu-mode auto            按电源自动切换（默认）
cpu-mode performance     游戏/AI 全速模式
cpu-mode balanced        插电均衡
cpu-mode powersave       电池省电
```

看门狗服务后台运行，防止 tccd 把 governor 改回 performance 导致费电。

### Fn 功能键

| 按键 | 功能 |
|---|---|
| Fn+F1 | 睡眠 |
| Fn+F2 | 锁屏 |
| Fn+F3 | 切换显示 |
| Fn+F4 | 开关 Wi-Fi |
| Fn+F5 | 开关触控板 |
| Fn+F6 | 键盘背光 |
| Fn+F7 | 静音 |
| Fn+F8 | 音量减 |
| Fn+F9 | 音量加 |
| Fn+F10 | 亮度减 |
| Fn+F11 | 亮度加 |
| Fn+F12 | Insert |

### 常见问题

**睡眠后立即唤醒** → 添加内核参数 `acpi.ec_no_wakeup=1`

**没声音** → 确保 `pipewire` + `wireplumber` 运行中

**Wi-Fi 用不了** → 安装 `linux-firmware`

**蓝牙不工作** → 启动 `bluetooth.service`
