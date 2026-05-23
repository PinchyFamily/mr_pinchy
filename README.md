# mr_pinchy

A modified [BlueROV2](https://bluerobotics.com/store/rov/bluerov2/) running ROS2, working towards autonomous underwater operation.

**Documentation:** [https://pinchyfamily.github.io/mr_pinchy/](https://pinchyfamily.github.io/mr_pinchy/)

## About

mr_pinchy is a research and development platform for underwater autonomy. The project extends the Blue Robotics BlueROV2 with additional sensors and onboard compute to enable perception-guided navigation.

Key areas of development:

- **Perception** — sonar, GNSS, and camera-based environment understanding
- **Control** — station-keeping, depth/heading hold, waypoint following
- **Integration** — modular ROS2 packages composed into a full autonomy stack

## Repository Structure

This repository contains the project documentation (built with [MkDocs Material](https://squidfunnel.github.io/mkdocs-material/)). Individual ROS2 packages live in separate repositories under the [PinchyFamily](https://github.com/PinchyFamily) organization.

## Related Packages

| Package | Description |
|---------|-------------|
| [waterlinked_sonar_3d15](https://github.com/PinchyFamily/waterlinked_sonar_3d15) | ROS2 driver for Water Linked Sonar 3D15 |
| [ublox_dgnss](https://github.com/PinchyFamily/ublox_dgnss) | ROS2 driver for UBLOX GNSS (ZED-F9P, ZED-F9R) |

## Building the Docs Locally

```bash
pip install -r requirements.txt
mkdocs serve
```

Then open [http://127.0.0.1:8000](http://127.0.0.1:8000).

## License

TBD
