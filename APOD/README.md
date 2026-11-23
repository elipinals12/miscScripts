# APOD Wallpaper

Sets your desktop wallpaper to NASA's Astronomy Picture of the Day, automatically every day.

## Setup

Download just these two files into one folder:

- `apod.sh`
- `hubbleUltraDeepFieldBG.png`

Then run:

```
./apod.sh
```

That's it. It installs its own autostart entry and a daily timer (00:30), so you never run it again.

Force a re-download: `./apod.sh --force`
Turn it off: set `ENABLE_SCRIPT=false` at the top of `apod.sh`.

## What it does

Grabs today's picture from NASA's RSS feed and sets it as your wallpaper. It auto-detects your desktop (KDE Plasma, Cinnamon, GNOME, MATE, XFCE). On video days, or if there's no image or no internet, it uses the Hubble picture instead. Yesterday's picture moves to `ol/`.

## Files

`apod.sh` and `hubbleUltraDeepFieldBG.png` are required. Everything else is created automatically and optional, but nice to have:

- `ol/` archive of old wallpapers
- `apod.log` log
- `last_date` remembers the last download date
- `apod_current_*` today's image
- `.apod.lock` prevents double runs
