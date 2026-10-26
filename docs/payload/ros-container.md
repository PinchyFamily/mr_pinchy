# ROS Container

ROS 2 Humble runs in Docker on the payload, not on the Ubuntu 24.04 host. The container uses the host network (for DDS discovery) and the host `/dev` tree (for serial and camera devices).

!!! warning "Not reproducible yet"
    Two different images exist on the payload:

    - **`pinchy-humble-container-ros`**, built from the `pinchy-humble-container` Dockerfile below. Its Dockerfile and compose changes are uncommitted, and the repo has **no remote**.
    - **`nacho:latest`**, the image actually in use. It was created by running the container, installing packages by hand, then `docker commit`. None of those steps are in a Dockerfile.

    The [manual steps](#manual-steps-baked-into-nacholatest) are listed below so they can be folded into the Dockerfile.

## pinchy-humble-container

Layout on the Pi (`~/pinchy-humble-container`):

```
pinchy-humble-container/
├── Dockerfile
├── compose.yaml
└── workspaces/          # mounted at /ros_ws
    ├── WELCOME.md
    └── src/
        ├── explorehd_bringup/       # old camera package; now camera.launch.py in mr_pinchy_bringup
        ├── mr_pinchy_bringup/       # PinchyFamily/mr_pinchy_bringup
        ├── nucleus_driver/          # NortekSupport/nucleus_driver
        ├── ublox_dgnss/             # PinchyFamily/ublox_dgnss
        └── waterlinked_sonar_3d15/  # PinchyFamily/waterlinked_sonar_3d15
```

### Dockerfile

```dockerfile
FROM ros:humble-ros-base

RUN apt-get update && apt-get install -y --no-install-recommends \
    v4l-utils \
    ros-humble-usb-cam \
    ros-humble-image-transport-plugins \
    && rm -rf /var/lib/apt/lists/*

ENV ROS_DOMAIN_ID=0

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]
```

### compose.yaml

```yaml
services:
  ros:
    build: .
    container_name: ros_mr_pinchy_humble
    network_mode: host        # DDS discovery across eth0 without multicast config
    privileged: true
    restart: unless-stopped   # comes back after reboot
    group_add:
      - dialout               # serial (GNSS, modem)
      - video                 # camera
    volumes:
      - ./workspaces:/ros_ws
      - /dev:/dev:rbind       # all devices incl. udev symlinks
    stdin_open: true
    tty: true
```

### Build and run

```bash
cd ~/pinchy-humble-container
docker compose up -d --build
docker compose exec ros bash
```

Inside the container:

```bash
cd /ros_ws
colcon build --symlink-install
source install/setup.bash
```

Check device access:

```bash
ls -l /dev/gnss /dev/explorehd_cam /dev/serial/by-id/
v4l2-ctl --device=/dev/explorehd_cam --all
```

## Manual steps baked into `nacho:latest`

Recovered from the container's shell history. Each of these needs a line in the Dockerfile.

```bash
# apt (inside the container, as root)
apt install -y curl git vim nano tmux pkg-config python3-pip \
  python3-colcon-common-extensions software-properties-common \
  libusb-1.0-0-dev libcurl4-openssl-dev \
  ros-humble-rtcm-msgs ros-humble-tf2-ros ros-humble-tf2-ros-py

# pip
pip3 install nucleus-driver wlsonar pygnssutils ipython

# sources, in /home/pinchy/colcon_ws/src
git clone https://github.com/PinchyFamily/mr_pinchy_bringup.git
git clone https://github.com/PinchyFamily/waterlinked_sonar_3d15.git
git clone https://github.com/aussierobots/ublox_dgnss.git        # note: upstream, not the PinchyFamily fork
git clone https://github.com/NortekSupport/nucleus_driver.git

cd /home/pinchy/colcon_ws && colcon build
```

How it was run:

```bash
docker run -it --network host --ipc host nacho:latest
```

!!! question "Open items"
    - Pick one workspace path. The docs say `~/mr_pinchy_ws`, compose mounts `/ros_ws`, `nacho` uses `/home/pinchy/colcon_ws`, and the bringup README says `~/sonar_ws`.
    - Pick one `ublox_dgnss`: the PinchyFamily fork or aussierobots upstream.
    - `mr_pinchy_bringup` needs **MAVROS** and **`smarc_msgs`**, but neither is installed in either image.
    - Push `pinchy-humble-container` to PinchyFamily.
    - Delete `explorehd_bringup` from the workspace; the camera is now part of `mr_pinchy_bringup`.

## Packages and launch

| Package | Launch | Notes |
|---------|--------|-------|
| `mr_pinchy_bringup` | `ros2 launch mr_pinchy_bringup bringup.launch.py` | Full vehicle, auxiliary camera included; profiles `full`, `sensors_only`, `gnss_only`, `sim`. Reads `config/pinchy.yaml` and `config/secrets.yaml` |
| `mr_pinchy_bringup` | `ros2 launch mr_pinchy_bringup camera.launch.py` | Camera only: `usb_cam` on `/dev/explorehd_cam`, 1920×1080 @ 30 fps; publishes `/explorehd/image_raw`. Settings in `config/camera.yaml` |
| `waterlinked_sonar_3d15` | `ros2 launch waterlinked_sonar_3d15 sonar_3d15.launch.py` | Also included by bringup |

Credentials (NTRIP and others) go in the untracked `mr_pinchy_bringup/config/secrets.yaml`. See [Networking → Secrets](networking.md#secrets).
