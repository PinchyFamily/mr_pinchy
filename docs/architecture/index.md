# System Architecture

This section describes the high-level software architecture of mr_pinchy.

## Design Principles

- **Modular:** Each capability (drivers, perception, control) lives in its own ROS2 package
- **Decoupled:** Packages communicate via well-defined ROS2 interfaces (topics, services, actions)
- **Testable:** Individual components can be tested in isolation or with simulated inputs
- **Incremental:** Start with teleoperation, progressively add autonomous behaviors

## High-Level Architecture

```mermaid
graph TB
    subgraph sensors [Sensors]
        Sonar[Water Linked Sonar]
        GNSS[UBLOX GNSS]
        Camera[Cameras]
        IMU[IMU / Depth]
    end

    subgraph perception [Perception]
        ObstacleDetect[Obstacle Detection]
        Localization[Localization]
        Mapping[Mapping]
    end

    subgraph control [Control]
        PathPlanner[Path Planner]
        Controller[Motion Controller]
        Allocator[Thruster Allocator]
    end

    subgraph hardware [Hardware Interface]
        Thrusters[Thruster Drivers]
        Lights[Lights / Accessories]
    end

    Sonar --> ObstacleDetect
    GNSS --> Localization
    Camera --> ObstacleDetect
    IMU --> Localization

    ObstacleDetect --> PathPlanner
    Localization --> Controller
    Mapping --> PathPlanner

    PathPlanner --> Controller
    Controller --> Allocator
    Allocator --> Thrusters
```

## Layers

| Layer | Responsibility | Examples |
|-------|---------------|----------|
| **Drivers** | Hardware abstraction, raw data publishing | Sonar driver, GNSS driver, thruster interface |
| **Perception** | Sensor fusion, state estimation, environment modeling | Localization, obstacle detection, mapping |
| **Control** | Decision making, motion control | Path planning, PID controllers, thruster allocation |
| **Mission** | High-level task execution | Waypoint following, survey patterns |

## Further Reading

- [ROS2 Workspace](ros2-workspace.md) — package layout and build structure
- [Communication](communication.md) — topics, services, and actions map
