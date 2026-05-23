# ROS2 Workspace

This page describes the ROS2 workspace structure for mr_pinchy.

## Workspace Layout

```
mr_pinchy_ws/
├── src/
│   ├── mr_pinchy/                  # This repo (documentation + launch files)
│   ├── waterlinked_sonar_3d15/     # Sonar driver package
│   ├── ublox_dgnss/                # GNSS driver package
│   └── ...                         # Additional packages as developed
├── build/                          # colcon build output
├── install/                        # colcon install output
└── log/                            # colcon build logs
```

## Package Organization

Each ROS2 package in the workspace is maintained in its own Git repository under the [PinchyFamily](https://github.com/PinchyFamily) organization. This keeps packages independently versioned and reusable.

### Current Packages

| Package | Repository | Type | Description |
|---------|-----------|------|-------------|
| waterlinked_sonar_3d15 | [GitHub](https://github.com/PinchyFamily/waterlinked_sonar_3d15) | Driver | Water Linked sonar 3D15 ROS2 driver |
| ublox_dgnss | [GitHub](https://github.com/PinchyFamily/ublox_dgnss) | Driver | UBLOX DGNSS ROS2 driver (ZED-F9P, ZED-F9R) |

### Planned Packages

!!! note
    Add new packages here as they are created.

## Build System

The workspace uses [colcon](https://colcon.readthedocs.io/) as the build tool:

```bash
cd ~/mr_pinchy_ws
colcon build --symlink-install
```

### Useful Build Commands

```bash
# Build a single package
colcon build --packages-select <package_name>

# Build with verbose output
colcon build --event-handlers console_direct+

# Clean build artifacts
rm -rf build/ install/ log/
```

## Launch Files

!!! note
    Document launch file organization and usage as they are developed. Launch files that bring up the full system or specific subsystems will live in this repository or in a dedicated launch package.
