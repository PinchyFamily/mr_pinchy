# Devices and udev

USB devices get kernel names (`/dev/video0`, `/dev/ttyACM0`) that depend on enumeration order and can change between boots. udev rules give the payload's sensors stable names that the ROS container and scripts can rely on.

| Device | USB ID | Stable name | Rule |
|--------|--------|-------------|------|
| exploreHD USB camera (DeepWater Exploration) | `0c45:6366` | `/dev/explorehd_cam` | [`99-explorehd-camera.rules`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/udev/99-explorehd-camera.rules) |
| u-blox GNSS receiver | `1546:01ab` | `/dev/gnss` | [`99-gnss.rules`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/udev/99-gnss.rules) |

Both rules add `TAG+="uaccess"`. The GNSS rule also sets `GROUP="dialout"`, `MODE="0660"`.

## Install

From a checkout of this repo on the Pi:

```bash
cd mr_pinchy/setup/udev

# GNSS (script copies the rule, reloads udev and shows the symlink)
./install-gnss-udev.sh

# Camera
sudo cp 99-explorehd-camera.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=video4linux
```

## Verify

```bash
ls -l /dev/gnss /dev/explorehd_cam
```

```
lrwxrwxrwx 1 root root 7 ... /dev/gnss -> ttyACM0
lrwxrwxrwx 1 root root 6 ... /dev/explorehd_cam -> video0
```

The ROS container bind-mounts the host `/dev`, so both names are visible inside it too (see [ROS container](ros-container.md)).

## Troubleshooting

**Symlink missing.** Check the device is enumerated and see what udev knows about it:

```bash
lsusb | grep -E '0c45:6366|1546:01ab'
udevadm info --name=/dev/video0
udevadm test $(udevadm info -q path -n /dev/video0) 2>&1 | grep explorehd
```

**Two cameras with the same USB ID.** Add the serial number to the match, e.g. `ATTRS{serial}=="SN00009"` for the current camera, and give each camera its own `SYMLINK`.

## GNSS tools on the host

For quick checks outside ROS:

```bash
sudo apt install -y gpsd gpsd-tools
gpsmon /dev/gnss
```

!!! note
    `pygpsclient` was also installed on the host with `pip install --break-system-packages`. Prefer `pipx install pygpsclient` to keep it out of the system Python.
