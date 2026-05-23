# Getting Started

This guide covers setting up a development environment for working with mr_pinchy's ROS2 packages.

## Prerequisites

- Ubuntu 22.04 or 24.04
- [ROS2 Humble](https://docs.ros.org/en/humble/Installation.html) (or newer)
- Python 3.10+
- Git

## Clone the Workspace

```bash
mkdir -p ~/mr_pinchy_ws/src
cd ~/mr_pinchy_ws/src
git clone git@github.com:PinchyFamily/mr_pinchy.git
```

Clone additional packages as needed:

```bash
git clone git@github.com:PinchyFamily/waterlinked_sonar_3d15.git
git clone git@github.com:PinchyFamily/ublox_dgnss.git
```

## Install Dependencies

```bash
cd ~/mr_pinchy_ws
rosdep install --from-paths src --ignore-src -r -y
```

## Build

```bash
cd ~/mr_pinchy_ws
colcon build --symlink-install
```

## Source the Workspace

```bash
source ~/mr_pinchy_ws/install/setup.bash
```

!!! tip
    Add the source command to your `~/.bashrc` for convenience:
    ```bash
    echo "source ~/mr_pinchy_ws/install/setup.bash" >> ~/.bashrc
    ```

## Building the Documentation

To build and preview these docs locally:

```bash
cd ~/mr_pinchy_ws/src/mr_pinchy
pip install -r requirements.txt
mkdocs serve
```

The site will be available at `http://127.0.0.1:8000`.

## Next Steps

- Review the [Vehicle](../vehicle/index.md) section for hardware details
- See the [Architecture](../architecture/index.md) for system design overview
- Check the [Packages](../packages/index.md) page for available ROS2 packages
