# Payload Computer

The payload computer runs mr_pinchy's ROS 2 stack on board. This section explains how to rebuild it from a blank SD card.

| Property | Value |
|----------|-------|
| Board | Raspberry Pi 5 Model B |
| OS | Ubuntu Server 24.04 LTS (arm64), kernel `linux-raspi` |
| Hostname | `payload` (reachable as `payload.local` via Avahi) |
| User | `pinchy` |
| ROS | ROS 2 Humble, inside Docker (not installed on the host) |
| Storage | 256 GB microSD |

!!! note
    These pages were reconstructed from the SD card as it was on 2026-10-26: config files, scripts and shell history. Where a step was done by hand and not scripted, the page says so.

## Setup order

1. [Base OS and boot](setup.md): flash the card, configure boot and EEPROM, install Docker
2. [Devices and udev](udev.md): stable device names for the camera and GNSS
3. [Networking](networking.md): tether, Wi-Fi client, the `pinchy-ap` access point, 4G fallback
4. [ROS container](ros-container.md): the ROS 2 Humble image and workspace
5. [Camera streaming](camera-streaming.md): exploreHD video via mavlink-camera-manager

## Setup files in this repo

Scripts and config files referenced by these pages live in [`setup/`](https://github.com/PinchyFamily/mr_pinchy/tree/main/setup):

```
setup/
├── boot/      # config.txt, cmdline.txt, EEPROM config
├── udev/      # udev rules + install script
├── ap/        # pinchy-ap access point (hostapd, dnsmasq, systemd-networkd)
└── network/   # switch-to-ethernet.sh
```
