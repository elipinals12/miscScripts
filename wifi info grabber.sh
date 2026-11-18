#!/usr/bin/env bash
# Print SSID and password of the currently connected Wi-Fi.
con=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2~/wireless/{print $1; exit}')
[ -z "$con" ] && { echo "Not connected to Wi-Fi" >&2; exit 1; }
ssid=$(nmcli -g 802-11-wireless.ssid connection show "$con")
pass=$(nmcli -s -g 802-11-wireless-security.psk connection show "$con")
echo "SSID: $ssid"
echo "Pass: ${pass:-<none/open or needs sudo>}"
