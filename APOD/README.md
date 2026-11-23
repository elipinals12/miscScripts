# APOD Wallpaper

Sets your desktop wallpaper to NASA's Astronomy Picture of the Day, every day. Automatic.

## What it does
- Downloads today's APOD image (NASA RSS feed)
- Sets it as wallpaper (KDE Plasma, Cinnamon, GNOME, MATE, XFCE auto-detected)
- Runs on login + daily timer (systemd) — installs itself
- Video day / no image / offline → uses the Hubble picture instead
- Yesterday's image gets moved to `ol/` (old)

## Setup
1. Open `apod.sh`, set `ENABLE_SCRIPT=true` (top of file)
2. Run: `./apod.sh`

Done. It sets up autostart + daily timer by itself.
Force re-download: `./apod.sh --force`

## Files
Required:
- `apod.sh` — the script
- `hubbleUltraDeepFieldBG.png` — fallback wallpaper

Optional (auto-created, nice to have):
- `ol/` — archive of old wallpapers
- `apod.log` — log
- `last_date` — remembers last download date
- `apod_current.*` — today's image
- `.apod.lock` — stops double runs
