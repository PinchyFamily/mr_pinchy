# Networking

The payload has up to four network paths:

| Interface | Role | Configured by |
|-----------|------|---------------|
| `eth0` | Tether / vehicle LAN (sonar, DVL, topside) | netplan (cloud-init), DHCP |
| `wlan0` | Built-in Wi-Fi, client of the lab network (bench work) | netplan (cloud-init) |
| `wlx00c0cab7c94c` | Alfa AWUS036ACS USB adapter, runs the **`pinchy-ap`** access point | systemd-networkd + hostapd + dnsmasq |
| `wwan0` | SIM7600G-H 4G modem (fallback) | manual / QMI, see [4G Modem](../vehicle/4g-modem.md) |

## Secrets

Wi-Fi keys, the access point passphrase and other credentials live in one untracked file, `mr_pinchy_bringup/config/secrets.yaml`. Create it from the tracked template in [mr_pinchy_bringup](https://github.com/PinchyFamily/mr_pinchy_bringup):

```bash
cd mr_pinchy_bringup/config
cp secrets.yaml.example secrets.yaml
chmod 600 secrets.yaml
# fill in the values
```

The access point installer below reads its passphrase from this file.

## Ethernet and Wi-Fi client

cloud-init writes `/etc/netplan/50-cloud-init.yaml` on first boot from the Imager settings: DHCP on `eth0` and `wlan0`, with `wlan0` joining the lab network (`wifi` section in `secrets.yaml`).

### Ethernet only

For deployments, [`switch-to-ethernet.sh`](https://github.com/PinchyFamily/mr_pinchy/blob/main/setup/network/switch-to-ethernet.sh) makes `eth0` the only interface:

- rewrites the netplan file and `/boot/firmware/network-config` to eth0-only, with backups in `~/net-backup-<timestamp>/`
- disables and masks `wpa_supplicant`
- blocks Wi-Fi with `rfkill`
- runs `netplan apply`

```bash
sudo setup/network/switch-to-ethernet.sh
```

!!! warning
    Run it from a wired session. If you're connected over `wlan0`, you'll lose the connection.

## Wi-Fi adapter driver (8821au)

The AP runs on an Alfa AWUS036ACS (Realtek RTL8811AU). The in-kernel `rtw88_8821au` driver doesn't support AP mode reliably, so the payload uses the out-of-tree [morrownr/8821au-20210708](https://github.com/morrownr/8821au-20210708) driver:

```bash
sudo apt install -y build-essential dkms linux-headers-$(uname -r)
git clone https://github.com/morrownr/8821au-20210708.git
cd 8821au-20210708
sudo ./install-driver.sh
```

The installer adds `/etc/modprobe.d/8821au.conf`, which blacklists `rtw88_8821au` and sets `options 8821au rtw_led_ctrl=1`.

!!! danger "Kernel updates break the AP"
    The driver was built for kernel `6.8.0-1060-raspi`. After unattended-upgrades installed 1062 and then 1065, the module stopped loading and `hostapd` failed in a loop with `wlx00c0cab7c94c: No such device`. After any kernel update, check:
    ```bash
    dkms status
    lsmod | grep 8821au
    ```
    If the module is missing, re-run `sudo ./install-driver.sh`, or hold the kernel (see [Base OS](setup.md#4-apt-sources-and-base-packages)).

## Access point: `pinchy-ap`

An isolated WPA2 network so laptops and tablets can reach the payload in the field without internet routing.

| Setting | Value |
|---------|-------|
| SSID | `pinchy-ap` |
| Band / channel | 2.4 GHz (`hw_mode=g`), channel 6, 802.11n, country `SE` |
| Payload address | `192.168.50.1/24` |
| DHCP range | `192.168.50.10`–`192.168.50.100`, 24 h leases |
| Gateway / DNS | none advertised, so clients keep their own internet path |
| Passphrase | `access_point.passphrase` in `secrets.yaml` |

Files in [`setup/ap/`](https://github.com/PinchyFamily/mr_pinchy/tree/main/setup/ap):

| File | Installed to | Purpose |
|------|--------------|---------|
| `20-ap.network` | `/etc/systemd/network/` | Static IP on the adapter, even without carrier |
| `hostapd.conf.example` | `/etc/hostapd/hostapd.conf` (mode 600) | AP config; passphrase filled in from `secrets.yaml` |
| `hostapd.default` | `/etc/default/hostapd` | Points hostapd at its config |
| `ap.conf` | `/etc/dnsmasq.d/` | DHCP only (`port=0` so it doesn't fight systemd-resolved on :53) |
| `dnsmasq-after-hostapd.conf` | `/etc/systemd/system/dnsmasq.service.d/after-hostapd.conf` | Start dnsmasq after hostapd |
| `install-ap.sh` | — | Installs packages and files, enables services |

### Install

With the 8821au driver loaded and `secrets.yaml` filled in:

```bash
sudo SECRETS=/path/to/mr_pinchy_bringup/config/secrets.yaml setup/ap/install-ap.sh
```

`SECRETS` defaults to `~pinchy/pinchy-humble-container/workspaces/src/mr_pinchy_bringup/config/secrets.yaml`. The script checks that the adapter and driver are present and that the driver advertises AP mode. It then installs `hostapd`, `dnsmasq` and `iw` (masking dnsmasq first so its default config never grabs port 53), copies the files, and enables both services.

### Verify

```bash
systemctl is-active hostapd dnsmasq
ip -br addr show wlx00c0cab7c94c      # 192.168.50.1/24
journalctl -u hostapd -n 20
```

!!! note
    The interface name `wlx00c0cab7c94c` comes from the adapter's MAC address. If you replace the adapter, update `IFACE` in `install-ap.sh`, `20-ap.network`, `hostapd.conf.example` and `ap.conf`.

## NetworkManager

`network-manager` was installed on Aug 20, and `NetworkManager.service` is enabled. Its config sets `[ifupdown] managed=false` and there are no NM connection profiles, so as far as the card shows it manages nothing. netplan uses systemd-networkd.

!!! question "To confirm"
    Was NetworkManager needed for something, such as the 4G modem? If not, disable it to avoid two network managers on one host.

## 4G modem

See [4G Modem](../vehicle/4g-modem.md). `libqmi-utils` and `modemmanager` are installed. Nothing brings the modem up at boot yet. ModemManager is enabled by default and can claim `/dev/cdc-wdm0`, so keep using `--device-open-proxy` as the modem page describes.
