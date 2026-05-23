# mr_pinchy

**mr_pinchy** is a modified [Blue Robotics BlueROV2](https://bluerobotics.com/store/rov/bluerov2/) running ROS2, with the long-term goal of achieving autonomous underwater operation.

## Project Goals

- Build a robust ROS2-based software stack on the BlueROV2 platform
- Develop perception capabilities using sonar, GNSS, and camera sensors
- Implement control algorithms for station-keeping, path following, and autonomous navigation
- Create a modular architecture where individual packages can be developed and tested independently

## Approach

This repository serves as the **central documentation hub** for the mr_pinchy project. Specific algorithms, drivers, and ROS2 packages live in their own repositories under the [PinchyFamily](https://github.com/PinchyFamily) GitHub organization and are linked from here.

The documentation is organized into:

| Section | Description |
|---------|-------------|
| [Getting Started](getting-started/index.md) | Development environment setup and build instructions |
| [Vehicle](vehicle/index.md) | Hardware platform, modifications, and electronics |
| [Architecture](architecture/index.md) | System design, ROS2 workspace layout, and communication topology |
| [Perception](perception/index.md) | Sensor stack and perception algorithms |
| [Control](control/index.md) | Control systems and motion planning |
| [Packages](packages/index.md) | Registry of external packages with links to their repos |

## Platform Summary

| Property | Value |
|----------|-------|
| Base vehicle | BlueROV2 (Blue Robotics) |
| Middleware | ROS2 |
| Compute | TBD |
| Primary sensors | Water Linked sonar, UBLOX GNSS, cameras |
| Target autonomy | Perception-guided waypoint navigation |
