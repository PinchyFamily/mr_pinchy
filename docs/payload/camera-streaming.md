# Camera Streaming

Besides the ROS camera node (see [ROS container](ros-container.md)), the payload can stream the exploreHD camera straight to a topside ground station with Blue Robotics' [mavlink-camera-manager](https://github.com/mavlink/mavlink-camera-manager). This runs on the host, outside Docker.

| Property | Value |
|----------|-------|
| Binary | `mavlink-camera-manager-aarch64`, version 0.2.4 (`c46c41d`) |
| Location on the Pi | `~/workspaces/mavlink-camera-manager-aarch64` |
| Camera | exploreHD, `/dev/explorehd_cam` (H.264 / MJPEG, see [udev](udev.md)) |
| Logs | `~/workspaces/logs/` |

## Dependencies

```bash
sudo apt install -y --no-install-recommends \
  libgstreamer1.0-0 libgstreamer-plugins-base1.0-0 libgstreamer-plugins-bad1.0-0 \
  libgstrtspserver-1.0-0 gstreamer1.0-x gstreamer1.0-nice \
  gstreamer1.0-tools gstreamer1.0-libav
sudo apt install -y ffmpeg   # optional, for testing
```

Check that the H.264 decoder is available:

```bash
gst-inspect-1.0 avdec_h264
```

## Install

Download the `aarch64` release binary from the [mavlink-camera-manager releases](https://github.com/mavlink/mavlink-camera-manager/releases):

```bash
mkdir -p ~/workspaces && cd ~/workspaces
# copy or download mavlink-camera-manager-aarch64 here
chmod +x mavlink-camera-manager-aarch64
```

## Run

The configuration used on the payload:

```bash
cd ~/workspaces
./mavlink-camera-manager-aarch64 --mavlink=udpout:0.0.0.0:14000 --verbose
```

Ports seen in its logs:

| Port | Use |
|------|-----|
| 14000/udp | MAVLink out (camera announcements for QGroundControl / Cockpit) |
| 8554/tcp | RTSP server (`rtsp://payload.local:8554/video2`) |
| 5600/udp | UDP H.264 stream |
| 6020/tcp | Web UI / REST API |
| 6021/tcp | WebRTC signalling |

Open the web UI at `http://payload.local:6020` to pick the camera, format and stream endpoints.

!!! warning "Not a service yet"
    The manager has always been started by hand inside `tmux`, and stale instances were killed with `kill -9`. To start it on boot, add a systemd unit, for example:

    ```ini
    # /etc/systemd/system/mavlink-camera-manager.service
    [Unit]
    Description=mavlink-camera-manager
    After=network-online.target
    Wants=network-online.target

    [Service]
    User=pinchy
    WorkingDirectory=/home/pinchy/workspaces
    ExecStart=/home/pinchy/workspaces/mavlink-camera-manager-aarch64 --mavlink=udpout:0.0.0.0:14000
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target
    ```

!!! note
    The ROS `usb_cam` node and mavlink-camera-manager both open `/dev/explorehd_cam`. Run only one of them at a time.
