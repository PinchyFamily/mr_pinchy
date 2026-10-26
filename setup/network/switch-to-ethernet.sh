#!/bin/bash
set -euo pipefail

NETPLAN=/etc/netplan/50-cloud-init.yaml
BOOT_NET=/boot/firmware/network-config
BACKUP_DIR=/home/pinchy/net-backup-$(date +%Y%m%d-%H%M%S)

mkdir -p "$BACKUP_DIR"
cp -a "$NETPLAN" "$BACKUP_DIR/" 2>/dev/null || true
cp -a "$BOOT_NET" "$BACKUP_DIR/" 2>/dev/null || true

cat > "$NETPLAN" <<'EOF'
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
      optional: false
EOF
chmod 600 "$NETPLAN"

cat > "$BOOT_NET" <<'EOF'
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp6: true
      optional: false
EOF

# Stop and disable WiFi services so wlan0 stays down across reboots.
systemctl disable --now wpa_supplicant.service netplan-wpa-wlan0.service 2>/dev/null || true
systemctl mask wpa_supplicant.service netplan-wpa-wlan0.service 2>/dev/null || true

# Block WiFi at the RF level as a belt-and-suspenders measure.
if command -v rfkill >/dev/null; then
  rfkill block wifi || true
fi

netplan apply

ip link set wlan0 down 2>/dev/null || true

echo
echo "=== Done. Current default routes ==="
ip route show default
echo
echo "=== Interface addresses ==="
ip -4 -br addr show eth0 wlan0
echo
echo "Backups saved in: $BACKUP_DIR"
