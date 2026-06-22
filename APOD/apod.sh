#!/usr/bin/env bash

# APOD Wallpaper Setter for Linux Mint (Cinnamon)
# Location: ~/Desktop/random scripts/APOD/apod.sh

set -u

APOD_DIR="$HOME/Desktop/scripts/APOD"
OL_DIR="$APOD_DIR/ol"
STAMP_FILE="$APOD_DIR/last_date"
SCRIPT_PATH="$APOD_DIR/apod.sh"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/apod-wallpaper.desktop"
LOG_FILE="$APOD_DIR/apod.log"
FALLBACK_IMG="$APOD_DIR/hubbleUltraDeepFieldBG.png"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_USER_DIR/apod-wallpaper.service"
TIMER_FILE="$SYSTEMD_USER_DIR/apod-wallpaper.timer"
LOCK_FILE="$APOD_DIR/.apod.lock"

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

mkdir -p "$APOD_DIR" "$OL_DIR"

touch "$LOG_FILE" 2>/dev/null || true

log() {
    echo "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

set_wallpaper() {
    local img="$1"

    if [[ ! -f "$img" ]]; then
        log "Wallpaper file missing: $img"
        return 1
    fi

    gsettings set org.cinnamon.desktop.background picture-uri "file://$img"
    gsettings set org.cinnamon.desktop.background picture-options "scaled"
    log "Wallpaper set to: $img"
}

current_img() {
    find "$APOD_DIR" -maxdepth 1 -name 'apod_current.*' -type f | sort | head -n 1
}

is_today() {
    local file="$1"
    [[ -f "$file" ]] || return 1

    local file_date
    file_date=$(date -d "@$(stat -c '%Y' "$file" 2>/dev/null)" +%Y-%m-%d 2>/dev/null || true)
    [[ "$file_date" == "$(date +%Y-%m-%d)" ]]
}

startup_wait() {
    local uptime_secs
    uptime_secs=$(awk '{print int($1)}' /proc/uptime 2>/dev/null || echo 999999)

    if [[ "$uptime_secs" -lt 120 ]]; then
        log "Startup detected, uptime ${uptime_secs}s. Waiting 30s..."
        sleep 30
    fi
}

write_autostart() {
    mkdir -p "$AUTOSTART_DIR"

    cat > "$DESKTOP_FILE" <<EOF_DESKTOP
[Desktop Entry]
Type=Application
Name=APOD Wallpaper
Exec=/usr/bin/env bash "$SCRIPT_PATH"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-GNOME-Autostart-Delay=10
EOF_DESKTOP

    chmod +x "$DESKTOP_FILE"
    log "Autostart entry written: $DESKTOP_FILE"
}

write_systemd_timer() {
    mkdir -p "$SYSTEMD_USER_DIR"

    cat > "$SERVICE_FILE" <<EOF_SERVICE
[Unit]
Description=Set APOD wallpaper

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash "$SCRIPT_PATH"
EOF_SERVICE

    cat > "$TIMER_FILE" <<EOF_TIMER
[Unit]
Description=Run APOD wallpaper daily and after login

[Timer]
OnBootSec=2min
OnUnitActiveSec=1d
Persistent=true

[Install]
WantedBy=timers.target
EOF_TIMER

    if command -v systemctl >/dev/null 2>&1; then
        systemctl --user daemon-reload >/dev/null 2>&1 || true
        systemctl --user enable --now apod-wallpaper.timer >/dev/null 2>&1 || true
        log "Systemd user timer written/enabled if available."
    else
        log "systemctl not found. Skipping systemd timer enable."
    fi
}

archive_current() {
    local cur_img="$1"
    [[ -n "$cur_img" && -f "$cur_img" ]] || return 0

    local old_date old_ext archive_name base_archive_name n

    if [[ -f "$STAMP_FILE" && -s "$STAMP_FILE" ]]; then
        old_date=$(head -n 1 "$STAMP_FILE")
    else
        old_date=$(date -d "@$(stat -c '%Y' "$cur_img" 2>/dev/null)" +%Y-%m-%d 2>/dev/null || echo "unknown")
    fi

    old_ext="${cur_img##*.}"
    base_archive_name="$OL_DIR/apod_${old_date}.${old_ext}"
    archive_name="$base_archive_name"
    n=1

    while [[ -e "$archive_name" ]]; do
        archive_name="$OL_DIR/apod_${old_date}_${n}.${old_ext}"
        n=$((n + 1))
    done

    log "Archiving previous APOD to: $archive_name"
    mv "$cur_img" "$archive_name"
}

wait_for_network() {
    log "Waiting for network..."

    for _ in $(seq 1 15); do
        if ping -c 1 -W 2 apod.nasa.gov >/dev/null 2>&1; then
            log "Network is up."
            return 0
        fi
        sleep 4
    done

    log "Network not available after about 60s."
    return 1
}

fetch_apod() {
    local today="$1"
    local page rel_url full_url ext new_img

    log "Fetching APOD page..."
    page=$(curl -fsSL --max-time 30 "https://apod.nasa.gov/apod/astropix.html" 2>/dev/null || true)

    rel_url=$(printf '%s' "$page" | grep -oP '(?<=<a href=")(image|video)/[^"]+\.(jpg|jpeg|png|gif|mp4|webm|mov)' | head -n 1 || true)

    if [[ -z "$rel_url" ]]; then
        log "No APOD media link found. Using fallback."
        startup_wait
        set_wallpaper "$FALLBACK_IMG"
        echo "$today" > "$STAMP_FILE"
        return 0
    fi

    full_url="https://apod.nasa.gov/apod/$rel_url"
    ext="${full_url##*.}"
    ext="${ext%%\?*}"
    new_img="$APOD_DIR/apod_current.$ext"

    log "Downloading: $full_url"

    if ! curl -fsSL --max-time 60 "$full_url" -o "$new_img"; then
        rm -f "$new_img"
        log "Download failed. Using fallback."
        startup_wait
        set_wallpaper "$FALLBACK_IMG"
        return 1
    fi

    if [[ ! -s "$new_img" ]]; then
        rm -f "$new_img"
        log "Downloaded file is empty. Using fallback."
        startup_wait
        set_wallpaper "$FALLBACK_IMG"
        return 1
    fi

    case "$ext" in
        mp4|webm|mov)
            log "Today's APOD is a video. Using fallback image."
            mv "$new_img" "$OL_DIR/apod_${today}_video.$ext" 2>/dev/null || rm -f "$new_img"
            startup_wait
            set_wallpaper "$FALLBACK_IMG"
            echo "$today" > "$STAMP_FILE"
            return 0
            ;;
    esac

    startup_wait
    set_wallpaper "$new_img"
    echo "$today" > "$STAMP_FILE"
    log "Done. APOD set for $today ($ext)."
}

main() {
    exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        log "Another APOD run is already active. Exiting."
        exit 0
    fi

    chmod +x "$SCRIPT_PATH" 2>/dev/null || true

    # One-time cleanup from older locations.
    if [[ -d "$HOME/.apod" ]]; then
        find "$HOME/.apod" -maxdepth 1 -name 'apod_current.*' -type f -exec mv {} "$OL_DIR/" \; 2>/dev/null || true
        rm -rf "$HOME/.apod"
        log "Cleaned up old ~/.apod folder."
    fi

    if [[ -d "$HOME/APOD" && "$HOME/APOD" != "$APOD_DIR" ]]; then
        find "$HOME/APOD" -maxdepth 1 -name 'apod_current.*' -type f -exec mv {} "$OL_DIR/" \; 2>/dev/null || true
        log "Moved old ~/APOD current images into new ol/ folder if any existed."
    fi

    write_autostart
    write_systemd_timer

    local today cur_img
    today=$(date +%Y-%m-%d)
    cur_img=$(current_img || true)

    log "Today: $today | Current image: ${cur_img:-none} | Force: $FORCE"

    if [[ "$FORCE" != true && -n "$cur_img" && -f "$cur_img" && -f "$STAMP_FILE" ]]; then
        if [[ "$(head -n 1 "$STAMP_FILE")" == "$today" ]] && is_today "$cur_img"; then
            startup_wait
            set_wallpaper "$cur_img"
            log "Already have today's APOD. Use --force to re-download."
            exit 0
        fi
    fi

    wait_for_network || true

    archive_current "$cur_img"
    fetch_apod "$today"
}

main "$@"
