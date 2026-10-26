#!/bin/bash
set -euo pipefail
RULE_SRC="$(dirname "$0")/99-gnss.rules"
RULE_DST="/etc/udev/rules.d/99-gnss.rules"
sudo cp "$RULE_SRC" "$RULE_DST"
sudo chmod 644 "$RULE_DST"
sudo udevadm control --reload-rules
sudo udevadm trigger --subsystem-match=tty --attr-match=idVendor=1546 --attr-match=idProduct=01ab
echo "Installed $RULE_DST"
ls -la /dev/gnss 2>/dev/null || ls -la /dev/serial/by-id/*gnss* 2>/dev/null || true
ls -la /dev/ttyACM0 /dev/gnss 2>/dev/null || true
