#!/bin/bash
# Sets up an isolated WPA2 access point on the Alfa AWUS036ACS.
# Leaves eth0/wlan0 under systemd-networkd completely untouched.
set -euo pipefail

IFACE=wlx00c0cab7c94c
SRC="$(cd "$(dirname "$0")" && pwd)"

echo "==> Preflight"
ip link show "$IFACE" >/dev/null || { echo "ERROR: $IFACE missing"; exit 1; }
grep -q "^8821au " /proc/modules || { echo "ERROR: 8821au module not loaded"; exit 1; }
# The WPA2 passphrase comes from the untracked mr_pinchy_bringup/config/secrets.yaml.
SECRETS=${SECRETS:-/home/pinchy/pinchy-humble-container/workspaces/src/mr_pinchy_bringup/config/secrets.yaml}
[ -f "$SECRETS" ] || { echo "ERROR: $SECRETS missing (set SECRETS=/path/to/secrets.yaml)"; exit 1; }
PASSPHRASE=$(python3 -c 'import sys, yaml; print(yaml.safe_load(open(sys.argv[1]))["access_point"]["passphrase"])' "$SECRETS")
[ ${#PASSPHRASE} -ge 8 ] && [ "$PASSPHRASE" != CHANGE_ME ] || { echo "ERROR: set access_point.passphrase in $SECRETS"; exit 1; }

echo "==> Installing packages"
# Mask dnsmasq first so its default config never races systemd-resolved on port 53.
systemctl mask dnsmasq >/dev/null 2>&1 || true
DEBIAN_FRONTEND=noninteractive apt-get install -y hostapd dnsmasq iw

echo "==> Checking the driver actually advertises AP mode"
PHY=$(iw dev "$IFACE" info | awk '/wiphy/{print "phy"$2}')
MODES=$(iw phy "$PHY" info | sed -n '/Supported interface modes/,/^\t[A-Za-z]/p')
if grep -qw AP <<< "$MODES"; then
    echo "    OK: $PHY supports AP mode"
else
    echo "    WARNING: AP mode not advertised by $PHY - hostapd may refuse to start"
fi

echo "==> Installing config files"
install -m 644 -o root -g root "$SRC/20-ap.network"  /etc/systemd/network/20-ap.network
install -m 644 -o root -g root "$SRC/hostapd.default" /etc/default/hostapd
install -m 644 -o root -g root "$SRC/ap.conf"         /etc/dnsmasq.d/ap.conf
# Contains the WPA2 passphrase - root-only.
TMP_CONF=$(umask 077 && mktemp)
PASSPHRASE="$PASSPHRASE" awk '/^wpa_passphrase=/{print "wpa_passphrase=" ENVIRON["PASSPHRASE"]; next} {print}' \
    "$SRC/hostapd.conf.example" > "$TMP_CONF"
install -m 600 -o root -g root "$TMP_CONF"           /etc/hostapd/hostapd.conf
rm -f "$TMP_CONF"
install -d -m 755 /etc/systemd/system/dnsmasq.service.d
install -m 644 -o root -g root "$SRC/dnsmasq-after-hostapd.conf" \
    /etc/systemd/system/dnsmasq.service.d/after-hostapd.conf

echo "==> Bringing up the interface address"
systemctl daemon-reload
networkctl reload
sleep 2
ip -br addr show "$IFACE"

echo "==> Enabling services"
systemctl unmask hostapd dnsmasq
systemctl enable --now hostapd
sleep 3
systemctl enable --now dnsmasq

echo "==> Done. Status:"
systemctl is-active hostapd dnsmasq || true
