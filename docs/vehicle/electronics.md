# Electronics

This page documents the electrical systems, wiring, and connector configuration for mr_pinchy.

## Power Distribution

!!! note
    Document the power architecture here — battery specs, voltage rails, regulators, and power budget.

| Rail | Voltage | Source | Consumers |
|------|---------|--------|-----------|
| Main battery | TBD | TBD | Thrusters, ESCs |
| Compute | TBD | TBD | Onboard computer |
| Sensors | TBD | TBD | Sonar, GNSS, cameras |

## Communication Interfaces

| Interface | Connection | Protocol |
|-----------|-----------|----------|
| Tether | Topside to ROV | Ethernet |
| 4G Modem | SimTech SIM7600G-H → onboard compute | USB (QMI via `/dev/cdc-wdm0`) |
| GNSS | u-blox → onboard compute | USB (NMEA on `/dev/ttyACM0`) |
| Onboard compute to sensors | TBD | USB / Serial |
| Sonar | TBD | TBD |

!!! info
    See [4G Modem](4g-modem.md) for detailed setup and operating instructions.

## Connector Pinouts

!!! note
    Document penetrator and connector pinouts as they are finalized.

## Wiring Diagram

!!! note
    Add a wiring diagram or link to a schematic here once available.
