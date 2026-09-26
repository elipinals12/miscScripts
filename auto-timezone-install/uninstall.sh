#!/bin/bash
# Remove the automatic-timezone setup. Run as root.
set -uo pipefail

[[ $EUID -eq 0 ]] || { echo "run this with sudo" >&2; exit 1; }

systemctl disable --now auto-timezone.timer
rm -f /etc/systemd/system/auto-timezone.timer \
      /etc/systemd/system/auto-timezone.service \
      /etc/NetworkManager/dispatcher.d/90-auto-timezone \
      /usr/local/bin/auto-timezone
systemctl daemon-reload

echo "Removed. Set your timezone manually with: timedatectl set-timezone <Zone>"
