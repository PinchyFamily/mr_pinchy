# Hardware Modifications

This page documents the physical modifications made to the stock BlueROV2 to support autonomous operation.

## Sensors

### Water Linked Sonar (3D15)

- **Purpose:** Obstacle detection, terrain mapping
- **Mounting:** TBD
- **ROS2 package:** [waterlinked_sonar_3d15](https://github.com/PinchyFamily/waterlinked_sonar_3d15)

### UBLOX GNSS (ZED-F9P)

- **Purpose:** Surface positioning, RTK corrections, heading
- **Mounting:** TBD
- **ROS2 package:** [ublox_dgnss](https://github.com/PinchyFamily/ublox_dgnss)

### Intel RealSense D435i

- **Purpose:** Depth perception, visual odometry (built-in IMU)
- **Connection:** USB 3.0 (`8086:0b3a`)
- **Mounting:** TBD
- **udev rule:** [`setup/udev/99-realsense-d435i.rules`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/udev/99-realsense-d435i.rules)

Install the udev rule so the camera is accessible without root:

```bash
sudo cp setup/udev/99-realsense-d435i.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger
```

### Cameras

- **Purpose:** Visual perception, inspection
- **Type:** TBD
- **Mounting:** TBD

## Compute

- **Platform:** TBD
- **Connection:** TBD
- **Power:** TBD

## Structural Changes

!!! note
    Document any frame modifications, additional enclosures, or mounting brackets here as they are implemented.

## Weight and Buoyancy

Any hardware additions affect the vehicle's weight and buoyancy trim. Document changes and compensations here.

| Modification | Weight Impact | Buoyancy Compensation |
|-------------|---------------|----------------------|
| TBD | TBD | TBD |
