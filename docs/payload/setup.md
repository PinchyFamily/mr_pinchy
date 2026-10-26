# Base OS and Boot

## 1. Flash the SD card

Use [Raspberry Pi Imager](https://www.raspberrypi.com/software/):

- **Device:** Raspberry Pi 5
- **OS:** Other general-purpose OS → Ubuntu → *Ubuntu Server 24.04 LTS (64-bit)*
- **OS customisation:**

| Setting | Value |
|---------|-------|
| Hostname | `payload` |
| Username | `pinchy` |
| Password | team password (ask the maintainers) |
| Wi-Fi | lab network (optional; see [Networking](networking.md)) |
| Wireless LAN country | `SE` |
| Locale | `Europe/Stockholm`, keyboard `se` |
| Services | Enable SSH with password authentication |

Imager writes these as cloud-init files (`user-data`, `network-config`, `meta-data`) to the boot partition, which is mounted at `/boot/firmware`. On first boot cloud-init creates the user, sets the hostname, installs `avahi-daemon` and writes `/etc/netplan/50-cloud-init.yaml`.

!!! warning
    `network-config` and the generated netplan file contain the Wi-Fi key. Don't commit copies of them.

## 2. Boot configuration

The reference [`config.txt`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/boot/config.txt) and [`cmdline.txt`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/boot/cmdline.txt) are in `setup/boot/`. Compared with the Ubuntu defaults, the payload relies on:

| Setting | Purpose |
|---------|---------|
| `dtparam=i2c_arm=on`, `dtparam=spi=on` | I2C and SPI on the GPIO header |
| `enable_uart=1` + `console=serial0,115200` | Serial console on the GPIO UART |
| `dtoverlay=dwc2` | USB OTG controller |
| `usb_max_current_enable=1` | Full USB current without the official 5 A PSU (needed for the camera, GNSS, modem and Wi-Fi adapter) |

To edit on the Pi:

```bash
sudo vim /boot/firmware/config.txt
sudo reboot
```

## 3. EEPROM: boot on power

The Pi should boot as soon as power is applied and stay powered after a halt. Apply [`pi-boot-on-power.conf`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/boot/pi-boot-on-power.conf):

```bash
sudo -E rpi-eeprom-config --edit
# paste the contents of setup/boot/pi-boot-on-power.conf, save, then:
sudo reboot
```

| Key | Value | Meaning |
|-----|-------|---------|
| `BOOT_UART` | `1` | Bootloader logs on UART |
| `BOOT_ORDER` | `0xf461` | SD → NVMe → USB, then retry |
| `POWER_OFF_ON_HALT` | `0` | Keep 3V3/5V on after `shutdown` |
| `WAIT_FOR_POWER_BUTTON` | `0` | Don't wait for the power button |
| `NET_INSTALL_AT_POWER_ON` | `1` | Network install available if no bootable media |

## 4. APT sources and base packages

The stock image only enables the `noble` suite, which caused dependency errors when installing `dkms` and kernel headers. Enable updates and backports:

```bash
sudo cp /etc/apt/sources.list.d/ubuntu.sources /etc/apt/sources.list.d/ubuntu.sources.bak
sudo sed -i '0,/^Suites: noble$/s//Suites: noble noble-updates noble-backports/' \
  /etc/apt/sources.list.d/ubuntu.sources
sudo apt update && sudo apt upgrade
```

Host tools used during bring-up:

```bash
sudo apt install -y tmux vim python3-pip iw nmap
```

!!! warning "Kernel updates and out-of-tree drivers"
    `unattended-upgrades` is on by default and installs new `linux-raspi` kernels. That broke the `8821au` Wi-Fi driver and with it the access point (see [Networking](networking.md#wi-fi-adapter-driver-8821au)). Either make sure the driver is managed by DKMS, or hold the kernel:
    ```bash
    sudo apt-mark hold linux-raspi linux-image-raspi linux-headers-raspi
    ```

## 5. Docker

Install Docker CE from Docker's apt repository ([official instructions](https://docs.docker.com/engine/install/ubuntu/)):

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: arm64
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker pinchy   # log out and back in
```

Next: [Devices and udev](udev.md).
