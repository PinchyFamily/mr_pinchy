# Vehicle Overview

mr_pinchy is built on the [Blue Robotics BlueROV2](https://bluerobotics.com/store/rov/bluerov2/) platform — a widely-used, open-source underwater ROV designed for inspection, research, and exploration.

## Base Platform: BlueROV2

The BlueROV2 provides:

- 6-thruster vectored configuration for full 6-DOF control
- Depth rating to 100m
- Tether-based communication and power
- Open-source hardware and software design
- Modular payload and sensor integration

## Modifications

mr_pinchy extends the stock BlueROV2 with additional sensors and compute for autonomous operation. See the sub-pages for details:

- [Hardware Modifications](hardware.md) — additional sensors, actuators, and structural changes
- [Electronics](electronics.md) — wiring, power distribution, and connector details

## Key Additions

| Component | Purpose |
|-----------|---------|
| Water Linked sonar | Obstacle detection and bathymetry |
| UBLOX GNSS (ZED-F9P) | Surface positioning and heading |
| Onboard compute | ROS2 processing for autonomy |
| Cameras | Visual perception |
