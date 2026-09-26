#!/bin/bash
# Install the automatic-timezone setup. Run as root.
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "run this with sudo" >&2; exit 1; }

src=$(dirname "$(readlink -f "$0")")

install -m 0755 -o root -g root "$src/auto-timezone"          /usr/local/bin/auto-timezone
install -m 0644 -o root -g root "$src/auto-timezone.service"  /etc/systemd/system/auto-timezone.service
install -m 0644 -o root -g root "$src/auto-timezone.timer"    /etc/systemd/system/auto-timezone.timer
install -m 0755 -o root -g root "$src/90-auto-timezone"       /etc/NetworkManager/dispatcher.d/90-auto-timezone

systemctl daemon-reload
systemctl enable --now auto-timezone.timer

echo
echo "Installed. Running an immediate check..."
systemctl start auto-timezone.service || true
echo
timedatectl status | head -4
echo
journalctl -t auto-timezone -n 10 --no-pager
