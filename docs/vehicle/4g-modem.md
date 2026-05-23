# 4G Modem — SimTech SIM7600G-H

This page documents the onboard 4G LTE modem used for over-the-horizon communication with mr_pinchy.

## Hardware Overview

| Property | Value |
|----------|-------|
| Module | SimTech SIM7600G-H |
| Chipset | Qualcomm MDM9x07 |
| USB Vendor:Product | `1e0e:9001` |
| IMEI | `868822042682912` |
| Firmware | `LE20B03SIM7600M22` |
| Supported bands | Global LTE Cat-4 (FDD & TDD), HSPA+, GSM |
| Max throughput | 150 Mbps DL / 50 Mbps UL (LTE Cat-4) |
| Interface | USB 2.0 (6 endpoints) |
| Protocol | QMI (Qualcomm MSM Interface) via `/dev/cdc-wdm0` |
| SIM slot | Nano-SIM (currently Tele2 SE) |

## USB Interface Layout

The SIM7600G-H exposes 6 USB interfaces when enumerated:

| Interface | Device Node | Driver | Function |
|-----------|-------------|--------|----------|
| 0 | `/dev/ttyUSB0` | option1 | Diagnostic/DIAG |
| 1 | `/dev/ttyUSB1` | option1 | NMEA GPS output |
| 2 | `/dev/ttyUSB2` | option1 | AT commands |
| 3 | `/dev/ttyUSB3` | option1 | AT commands (secondary) |
| 4 | `/dev/ttyUSB4` | option1 | Audio/PPP |
| 5 | `/dev/cdc-wdm0` | qmi_wwan | QMI control + `wwan0` data |

!!! warning
    The AT command ports (`ttyUSB2`/`ttyUSB3`) may not respond when the QMI interface is actively managing the modem. Use QMI via `/dev/cdc-wdm0` as the primary control interface.

## Network Interface

The data interface is exposed as `wwan0`:

- **Type:** Raw IP (not Ethernet-framed)
- **Kernel driver:** `qmi_wwan`
- **Control device:** `/dev/cdc-wdm0`
- **MTU:** 1430 (set by carrier)

## System Requirements

### Kernel Modules

The following kernel modules must be loaded (all present in stock Ubuntu 22.04+ kernels):

| Module | Purpose |
|--------|---------|
| `qmi_wwan` | QMI data interface driver |
| `cdc_wdm` | CDC WDM control channel |
| `option` | USB serial for AT/DIAG/NMEA ports |
| `usb_wwan` | USB WAN serial helper |
| `usbserial` | USB serial core |
| `usbnet` | USB networking core |

Verify with:

```bash
lsmod | grep -E "qmi_wwan|cdc_wdm|option|usb_wwan|usbserial|usbnet"
```

### Required Packages

Install the QMI userspace tools and network utilities:

```bash
apt-get install -y libqmi-utils iproute2 iputils-ping
```

| Package | Version (tested) | Purpose |
|---------|-----------------|---------|
| `libqmi-utils` | 1.32.0 | `qmicli` — QMI command-line interface |
| `iproute2` | 5.15.0 | `ip` — network interface configuration |
| `iputils-ping` | 20211215 | `ping` — connectivity testing |

Optional but useful:

```bash
apt-get install -y usbutils picocom python3-serial
```

| Package | Purpose |
|---------|---------|
| `usbutils` | `lsusb` — USB device enumeration |
| `picocom` | Serial terminal for AT commands |
| `python3-serial` | Python serial port access |

## Operating the Modem

### Checking Modem Status

```bash
# Verify modem is online
qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-get-operating-mode

# Get modem identity
qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-get-manufacturer
qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-get-model
qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-get-ids
```

### Checking Signal & Registration

```bash
# Signal strength
qmicli -d /dev/cdc-wdm0 --device-open-proxy --nas-get-signal-strength

# Network registration & carrier info
qmicli -d /dev/cdc-wdm0 --device-open-proxy --nas-get-serving-system
```

Signal strength reference:

| RSSI | Quality |
|------|---------|
| > -65 dBm | Excellent |
| -65 to -75 dBm | Good |
| -75 to -85 dBm | Fair |
| -85 to -95 dBm | Poor |
| < -95 dBm | No service likely |

### Establishing a Data Connection

```bash
# 1. Bring the network interface up
ip link set wwan0 up

# 2. Start a data session (adjust APN for your carrier)
qmicli -d /dev/cdc-wdm0 --device-open-proxy \
  --wds-start-network="apn=internet.tele2.se,ip-type=4" \
  --client-no-release-cid

# 3. Retrieve assigned IP settings
qmicli -d /dev/cdc-wdm0 --device-open-proxy \
  --wds-get-current-settings --client-cid=<CID> --client-no-release-cid

# 4. Configure the interface (use values from step 3)
ip addr flush dev wwan0
ip addr add <IPv4_ADDRESS>/<PREFIX> dev wwan0
ip link set dev wwan0 mtu 1430
ip route add default via <GATEWAY> dev wwan0 metric 200

# 5. Verify connectivity
ping -I wwan0 -c 3 8.8.8.8
```

!!! tip
    The `--client-no-release-cid` flag keeps the WDS client ID alive. Note the CID printed in the output — you need it for subsequent commands on the same session and for disconnecting.

!!! note
    The default route metric of 200 ensures the 4G connection won't override existing wired/WiFi routes. Lower the metric if you want 4G to be the primary route.

### Disconnecting

```bash
qmicli -d /dev/cdc-wdm0 --device-open-proxy \
  --wds-stop-network=<PACKET_DATA_HANDLE> --client-cid=<CID>

ip link set wwan0 down
```

### Checking Connection Status

```bash
# Is data connected?
qmicli -d /dev/cdc-wdm0 --device-open-proxy --wds-get-packet-service-status

# Current session settings
qmicli -d /dev/cdc-wdm0 --device-open-proxy \
  --wds-get-current-settings --client-cid=<CID> --client-no-release-cid
```

### APN Configuration

The stored profile can be viewed and modified:

```bash
# List profiles
qmicli -d /dev/cdc-wdm0 --device-open-proxy --wds-get-profile-list=3gpp

# Modify profile 1
qmicli -d /dev/cdc-wdm0 --device-open-proxy \
  --wds-modify-profile=3gpp,1,apn=internet.tele2.se
```

Common Swedish APNs:

| Carrier | APN |
|---------|-----|
| Tele2 | `internet.tele2.se` |
| Telia | `online.telia.se` |
| Telenor | `internet.telenor.se` |
| Tre (3) | `data.tre.se` |

## Automated Connection Script

A minimal script to bring the modem online:

```bash
#!/bin/bash
set -e

DEVICE="/dev/cdc-wdm0"
IFACE="wwan0"
APN="internet.tele2.se"
METRIC=200

# Bring interface up
ip link set "$IFACE" up

# Start data session
OUTPUT=$(qmicli -d "$DEVICE" --device-open-proxy \
  --wds-start-network="apn=${APN},ip-type=4" --client-no-release-cid)

CID=$(echo "$OUTPUT" | grep "CID:" | awk '{print $NF}' | tr -d "'")
HANDLE=$(echo "$OUTPUT" | grep "Packet data handle:" | awk '{print $NF}' | tr -d "'")

echo "CID=$CID  HANDLE=$HANDLE"

# Get IP settings
SETTINGS=$(qmicli -d "$DEVICE" --device-open-proxy \
  --wds-get-current-settings --client-cid="$CID" --client-no-release-cid)

IP=$(echo "$SETTINGS" | grep "IPv4 address:" | awk '{print $NF}' | tr -d "'")
MASK=$(echo "$SETTINGS" | grep "subnet mask:" | awk '{print $NF}' | tr -d "'")
GW=$(echo "$SETTINGS" | grep "gateway address:" | awk '{print $NF}' | tr -d "'")
DNS1=$(echo "$SETTINGS" | grep "primary DNS:" | awk '{print $NF}' | tr -d "'")
DNS2=$(echo "$SETTINGS" | grep "secondary DNS:" | awk '{print $NF}' | tr -d "'")
MTU=$(echo "$SETTINGS" | grep "MTU:" | awk '{print $NF}' | tr -d "'")

# Calculate prefix length from subnet mask
PREFIX=$(python3 -c "import ipaddress; print(ipaddress.IPv4Network('0.0.0.0/${MASK}').prefixlen)")

# Configure interface
ip addr flush dev "$IFACE"
ip addr add "${IP}/${PREFIX}" dev "$IFACE"
ip link set dev "$IFACE" mtu "$MTU"
ip route add default via "$GW" dev "$IFACE" metric "$METRIC"

echo "Connected: ${IP}/${PREFIX} via ${GW} (DNS: ${DNS1}, ${DNS2})"
echo "To disconnect: qmicli -d $DEVICE --device-open-proxy --wds-stop-network=$HANDLE --client-cid=$CID"
```

## Troubleshooting

### QMI commands timeout

Always use `--device-open-proxy`. Without it, concurrent access to `/dev/cdc-wdm0` causes CID allocation failures:

```
error: couldn't create client for the 'uim' service: CID allocation failed in the CTL client: Transaction timed out
```

### AT ports unresponsive

The AT serial ports (`ttyUSB2`, `ttyUSB3`) may not echo responses when the QMI subsystem is active. This is normal — use `qmicli` for all management instead.

### wwan0 shows no carrier

Ensure the modem is in `online` mode:

```bash
qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-set-operating-mode=online
```

### No SIM detected

Check with:

```bash
qmicli -d /dev/cdc-wdm0 --device-open-proxy --uim-get-card-status
```

If this times out, the SIM slot may use the legacy DMS interface:

```bash
qmicli -d /dev/cdc-wdm0 --device-open-proxy --dms-uim-get-pin-status
```

### DNS not resolving

Add the carrier DNS servers to `/etc/resolv.conf` or use systemd-resolved:

```bash
echo "nameserver 130.244.127.161" >> /etc/resolv.conf
echo "nameserver 130.244.127.169" >> /etc/resolv.conf
```

## Integration Notes

- The 4G modem provides over-the-horizon telemetry and command for mr_pinchy when beyond tether range or operating on the surface.
- Route priority (`metric 200`) ensures tether Ethernet is preferred when available; 4G acts as fallback.
- The same USB bus hosts the **u-blox GNSS receiver** (`/dev/ttyACM0`, USB ID `1546:01ab`) which provides GPS/GLONASS positioning data in NMEA format.
- Consider running a persistent connection manager (e.g., ModemManager + NetworkManager, or a systemd service with the script above) for automatic reconnection.
