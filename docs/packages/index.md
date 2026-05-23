# Packages

This page serves as a registry of ROS2 packages used by mr_pinchy. Each package lives in its own repository under the [PinchyFamily](https://github.com/PinchyFamily) GitHub organization.

## Driver Packages

### waterlinked_sonar_3d15

| | |
|---|---|
| **Repository** | [github.com/PinchyFamily/waterlinked_sonar_3d15](https://github.com/PinchyFamily/waterlinked_sonar_3d15) |
| **Language** | Python |
| **Type** | Sensor driver |
| **Description** | ROS2 driver for the Water Linked Sonar 3D15 |

### ublox_dgnss

| | |
|---|---|
| **Repository** | [github.com/PinchyFamily/ublox_dgnss](https://github.com/PinchyFamily/ublox_dgnss) |
| **Language** | — |
| **Type** | Sensor driver |
| **Description** | USB-based ROS2 driver for UBLOX UBX messaging (ZED-X20P, ZED-F9P, ZED-F9R). Supports high precision positioning and moving base station configurations. |

## Perception Packages

!!! note
    Perception packages will be listed here as they are developed.

## Control Packages

!!! note
    Control packages will be listed here as they are developed.

## Adding a New Package

When creating a new package for mr_pinchy:

1. Create a new repository under the [PinchyFamily](https://github.com/PinchyFamily) organization
2. Follow ROS2 package conventions (`package.xml`, `setup.py` or `CMakeLists.txt`)
3. Add the package to this registry with its repository link and description
4. Update the [ROS2 Workspace](../architecture/ros2-workspace.md) page if needed
5. Document any new topics/services in the [Communication](../architecture/communication.md) page
