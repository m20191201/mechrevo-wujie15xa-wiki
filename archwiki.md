# Mechrevo WUJIE15XA

## Hardware

| Device | PCI/USB ID | Working |
|---|---|---|
| Touchpad | PS/2 | Yes |
| Keyboard | PS/2 | Yes |
| GPU | `1002:1900` | Yes |
| Audio (HDMI) | `1002:1640` | Yes |
| Audio (Internal) | `1022:15e3` | Yes |
| Ethernet | `1f0a:6801` | Yes |
| Wi-Fi | `14c3:7922` | Yes |
| Bluetooth | Integrated | Yes |
| Webcam | USB | Yes |
| TPM | — | Yes |

The *Mechrevo WUJIE 15XA* is a 14-inch laptop powered by an AMD Ryzen 7 8845HS processor with Radeon 780M graphics. It features a 2560×1600 120 Hz display and shares a similar motherboard platform with the WUJIE14XA.

## Installation

### Disable Secure Boot

Secure Boot is enabled by default. Press `Del` repeatedly during startup to enter UEFI setup and disable it.

### Ethernet Controller

The RJ-45 Ethernet controller requires installation of [tuxedo-yt6801-dkms-git](https://aur.archlinux.org/packages/tuxedo-yt6801-dkms-git/) (AUR).

```bash
yay -S tuxedo-yt6801-dkms-git
```

### Kernel Parameters

Add `acpi.ec_no_wakeup=1` to prevent immediate wake from suspend.

## Firmware

### BIOS / EC

Official support site ([Chinese only](https://gwqd.mechrevo.com/service/)) provides BIOS/EC firmware upgrades. The update utility runs only on Windows.

### fwupd

fwupd supports updating the UEFI revocation database.

### SSD

The firmware of both NVMe drives (Micron 2550 and WD SNxxx) can be upgraded. See [Solid state drive](https://wiki.archlinux.org/title/Solid_state_drive) for details.

## Hardware Control

### Platform Drivers

The necessary platform drivers can be acquired by installing [mechrevo-drivers-dkms](https://aur.archlinux.org/packages/mechrevo-drivers-dkms/) (AUR):

```bash
yay -S mechrevo-drivers-dkms
```

This package provides: `tuxedo_keyboard`, `tuxedo_io`, `uniwill_wmi`, `clevo_acpi`.

### Battery Charging Mode

The battery control interface is at `/sys/devices/platform/tuxedo_keyboard/charging_profile/`:

```bash
$ cat /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profiles_available
high_capacity balanced stationary

# echo mode | sudo tee /sys/devices/platform/tuxedo_keyboard/charging_profile/charging_profile
```

### Fan

Install [tailord](https://aur.archlinux.org/packages/tailord/) (AUR) for fan control:

```bash
yay -S tailord tailor-cli tailor-hwcaps
sudo systemctl enable --now tailord
```

Check status:

```bash
sudo tailor_hwcaps
```

### Platform Profile

Only the `default` profile is currently available through tccd. Performance/balanced/quiet mode switching seen in Windows has not yet been reverse-engineered for this model. [TUXEDO Control Center](https://aur.archlinux.org/packages/tuxedo-control-center-bin/) may provide partial control.

### Keyboard Backlight

The keyboard backlight has three brightness levels (off/low/high), cycled via Fn+F6. No known software interface exists to control the backlight directly — the auto-on/off feature on Windows is implemented entirely in software by a service.

### CPU Governor

The amd-pstate-epp driver provides `powersave` and `performance` governors. When using [tuxedo-control-center-bin](https://aur.archlinux.org/packages/tuxedo-control-center-bin/) (AUR), the tccd daemon may repeatedly reset the governor to `performance`. See [#CPU Governor Watchdog](#cpu-governor-watchdog) for a workaround.

## CPU Governor Watchdog

To prevent tccd from overriding your governor preference, install the included service from the [community wiki repository](https://github.com/m20191201/mechrevo-wujie15xa-wiki):

```bash
sudo cp scripts/cpu-governor-watchdog.service /etc/systemd/system/
sudo systemctl enable --now cpu-governor-watchdog.service
```

Use the `cpu-mode` helper to switch profiles:

```bash
cpu-mode auto            # Automatic (default)
cpu-mode performance     # Gaming/AI
cpu-mode balanced        # AC balanced
cpu-mode powersave       # Battery saving
```

## Function Keys

| Key | Visible | Marked | Effect |
|---|---|---|---|
| Fn+F1 | Yes | Yes | XF86Sleep |
| Fn+F2 | Yes | Yes | Lock screen |
| Fn+F3 | Yes | Yes | XF86Display |
| Fn+F4 | Yes | Yes | XF86RFKill |
| Fn+F5 | Yes | Yes | XF86TouchpadToggle |
| Fn+F6 | Yes | Yes | Keyboard backlight toggle |
| Fn+F7 | Yes | Yes | XF86AudioMute |
| Fn+F8 | Yes | Yes | XF86AudioLowerVolume |
| Fn+F9 | Yes | Yes | XF86AudioRaiseVolume |
| Fn+F10 | Yes | Yes | XF86MonBrightnessDown |
| Fn+F11 | Yes | Yes | XF86MonBrightnessUp |
| Fn+F12 | Yes | Yes | Insert |

## Troubleshooting

### Wake up immediately from sleeping

Add the kernel parameter `acpi.ec_no_wakeup=1`.

### No audio

Ensure `pipewire` and `wireplumber` are running:

```bash
systemctl --user enable --now pipewire wireplumber
```

### Wi-Fi not detected

Ensure `linux-firmware` is installed.

### Bluetooth not working

```bash
sudo systemctl enable --now bluetooth
```

## See also

- [Mechrevo WUJIE15XA wiki (GitHub)](https://github.com/m20191201/mechrevo-wujie15xa-wiki)
- [ArchWiki: Mechrevo WUJIE14X](https://wiki.archlinux.org/title/Mechrevo_WUJIE14X)
- [w568w's ACPI reverse-engineering on WUJIE14XA](https://gist.github.com/w568w/b2fc5f9d1f4dff13efe751abec27b396)
- [sund3RRR's fixes and tweaks](https://github.com/sund3RRR/mechrevo14X-linux)
