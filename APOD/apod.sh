#!/usr/bin/env bash

# APOD Wallpaper Setter
# Downloads NASA's Astronomy Picture of the Day and sets it as the wallpaper.
# Auto-detects the desktop: KDE Plasma, Cinnamon, GNOME, MATE, XFCE.
#
# Usage: apod.sh [--force]     --force re-downloads even if today's is present.

# ==============================================================================
# CONFIG
# ==============================================================================
ENABLE_SCRIPT=true          # false = exit immediately, touch nothing

# RSS feed published by science.nasa.gov (the old apod.nasa.gov now redirects
# there). Each <item> has an <apod:hdurl> pointing at the image.
APOD_FEED_URL="https://science.nasa.gov/feed/apod-basic/"
APOD_TZ="America/New_York"  # APOD dates follow US Eastern time

FIT_MODE="fit"              # fit | fill | stretch | center
BG_COLOR="#000000"          # bars around the image when it doesn't fill the screen
SET_LOCKSCREEN=true         # KDE only; other desktops share the desktop image
DAILY_RUN_TIME="00:30"      # systemd timer time (HH:MM)
INSTALL_AUTOSTART=true      # run on login
INSTALL_TIMER=true          # run daily at DAILY_RUN_TIME

RETRY_INTERVAL=2            # secs between network / desktop-ready retries
RETRY_MAX=180               # give up after this many secs
# ==============================================================================

if [[ "$ENABLE_SCRIPT" != true ]]; then
    echo "APOD Wallpaper script is currently disabled. Exiting."
    exit 0
fi

set -u

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
APOD_DIR="$(dirname "$SCRIPT_PATH")"
OL_DIR="$APOD_DIR/ol"
LOG_FILE="$APOD_DIR/apod.log"
LOCK_FILE="$APOD_DIR/.apod.lock"
TMP_FILE="$APOD_DIR/.apod_tmp"
FALLBACK_IMG="$APOD_DIR/hubbleUltraDeepFieldBG.png"

APP_ID="apod-wallpaper"
AUTOSTART_FILE="$HOME/.config/autostart/$APP_ID.desktop"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SYSTEMD_USER_DIR/$APP_ID.service"
TIMER_FILE="$SYSTEMD_USER_DIR/$APP_ID.timer"

FORCE=false
[[ "${1:-}" == "--force" ]] && FORCE=true

# When launched from cron or similar, the session bus may not be in the env.
if [[ -z "${DBUS_SESSION_BUS_ADDRESS:-}" && -S "/run/user/$(id -u)/bus" ]]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

mkdir -p "$OL_DIR"

log() {
    echo "$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# ------------------------------------------------------------------------------
# Desktop detection / wallpaper setting
# ------------------------------------------------------------------------------

detect_desktop() {
    local de="${XDG_CURRENT_DESKTOP:-${DESKTOP_SESSION:-}}"
    de="${de,,}"
    case "$de" in
        *kde*|*plasma*) echo kde;      return ;;
        *cinnamon*)     echo cinnamon; return ;;
        *mate*)         echo mate;     return ;;
        *xfce*)         echo xfce;     return ;;
        *gnome*|*ubuntu*|*unity*|*budgie*) echo gnome; return ;;
    esac

    # Env not set (e.g. started by systemd/cron): look at running processes.
    if   pgrep -u "$USER" -x plasmashell    >/dev/null; then echo kde
    elif pgrep -u "$USER" -x cinnamon       >/dev/null; then echo cinnamon
    elif pgrep -u "$USER" -x mate-session   >/dev/null; then echo mate
    elif pgrep -u "$USER" -x xfce4-session  >/dev/null; then echo xfce
    elif pgrep -u "$USER" -x gnome-shell    >/dev/null; then echo gnome
    else echo unknown
    fi
}

# Map FIT_MODE onto each desktop's vocabulary.
kde_fill_mode_num() {  # kscreenlockerrc uses Qt's numeric enum
    case "$FIT_MODE" in
        fill) echo 2 ;; stretch) echo 0 ;; center) echo 6 ;; *) echo 1 ;;
    esac
}
gsettings_fill_mode() {
    case "$FIT_MODE" in
        fill) echo zoom ;; stretch) echo stretched ;;
        center) echo centered ;; *) echo scaled ;;
    esac
}
xfce_fill_mode() {
    case "$FIT_MODE" in
        fill) echo 5 ;; stretch) echo 3 ;; center) echo 1 ;; *) echo 4 ;;
    esac
}

set_wallpaper_kde() {
    local img="$1" qdbus
    qdbus=$(command -v qdbus6 || command -v qdbus-qt6 || command -v qdbus) || return 1

    # plasma-apply-wallpaperimage can't set the background color, so script
    # every desktop directly.
    "$qdbus" org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
        desktops().forEach(function (d) {
            d.wallpaperPlugin = 'org.kde.image';
            d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
            d.writeConfig('Image', 'file://$img');
            d.writeConfig('FillMode', '$(kde_fill_mode_num)');
            d.writeConfig('Color', '$BG_COLOR');
            d.writeConfig('Blur', 'false');
        });" >/dev/null 2>&1 || return 1

    if [[ "$SET_LOCKSCREEN" == true ]]; then
        local kwc key val
        kwc=$(command -v kwriteconfig6 || command -v kwriteconfig5) || return 0
        for kv in "Image=file://$img" "FillMode=$(kde_fill_mode_num)" "Color=$BG_COLOR" "Blur=false"; do
            key="${kv%%=*}" val="${kv#*=}"
            "$kwc" --file kscreenlockerrc --group Greeter --group Wallpaper \
                --group org.kde.image --group General --key "$key" "$val"
        done
    fi
}

# Cinnamon, GNOME and MATE share the same background keys.
set_wallpaper_gsettings() {
    local schema="$1" img="$2" key="${3:-picture-uri}" val="file://$2"
    [[ "$key" == picture-filename ]] && val="$img"
    gsettings set "$schema" "$key" "$val" || return 1
    gsettings set "$schema" picture-options "$(gsettings_fill_mode)"
    gsettings set "$schema" primary-color "$BG_COLOR"
    gsettings set "$schema" color-shading-type solid
}

set_wallpaper_xfce() {
    local img="$1" prop base found=false r g b
    # xfconf wants the color as RGBA doubles in 0..1.
    read -r r g b < <(printf '%d %d %d' "0x${BG_COLOR:1:2}" "0x${BG_COLOR:3:2}" "0x${BG_COLOR:5:2}" |
        awk '{printf "%.3f %.3f %.3f", $1/255, $2/255, $3/255}')
    while read -r prop; do
        base="${prop%/last-image}"
        xfconf-query -c xfce4-desktop -p "$prop" -s "$img"
        xfconf-query -c xfce4-desktop -p "$base/image-style" -n -t int -s "$(xfce_fill_mode)"
        xfconf-query -c xfce4-desktop -p "$base/color-style" -n -t int -s 0
        xfconf-query -c xfce4-desktop -p "$base/rgba1" -n \
            -t double -s "$r" -t double -s "$g" -t double -s "$b" -t double -s 1
        found=true
    done < <(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep '/last-image$')
    [[ "$found" == true ]]
}

# Usage: set_wallpaper <img> [wait]   wait = retry until the desktop is ready
set_wallpaper() {
    local img="$1" wait="${2:-}"
    if [[ ! -f "$img" ]]; then
        log "Wallpaper file missing: $img"
        return 1
    fi

    local deadline=$((SECONDS + RETRY_MAX)) de
    while true; do
        de=$(detect_desktop)
        case "$de" in
            kde)      set_wallpaper_kde "$img" ;;
            cinnamon) set_wallpaper_gsettings org.cinnamon.desktop.background "$img" ;;
            mate)     set_wallpaper_gsettings org.mate.background "$img" picture-filename ;;
            gnome)    set_wallpaper_gsettings org.gnome.desktop.background "$img" &&
                      gsettings set org.gnome.desktop.background picture-uri-dark "file://$img" 2>/dev/null ;;
            xfce)     set_wallpaper_xfce "$img" ;;
            *)        false ;;
        esac && { log "Wallpaper set ($de): $img"; return 0; }

        if [[ -z "$wait" ]] || (( SECONDS >= deadline )); then
            log "Could not set wallpaper (desktop: $de)."
            return 1
        fi
        sleep "$RETRY_INTERVAL"
    done
}

# ------------------------------------------------------------------------------
# Install autostart + systemd timer (only rewritten when contents change)
# ------------------------------------------------------------------------------

write_if_changed() {
    local file="$1" content="$2"
    [[ -f "$file" && "$(cat "$file")" == "$content" ]] && return 1
    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$content" > "$file"
    log "Wrote $file"
}

install_autostart() {
    write_if_changed "$AUTOSTART_FILE" "[Desktop Entry]
Type=Application
Name=APOD Wallpaper
Exec=/usr/bin/env bash \"$SCRIPT_PATH\"
Hidden=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel" || true
}

install_timer() {
    command -v systemctl >/dev/null || { log "systemctl not found; skipping timer."; return; }

    local changed=false
    write_if_changed "$SERVICE_FILE" "[Unit]
Description=Set APOD wallpaper

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash \"$SCRIPT_PATH\"" && changed=true

    write_if_changed "$TIMER_FILE" "[Unit]
Description=Run APOD wallpaper daily at $DAILY_RUN_TIME

[Timer]
OnCalendar=*-*-* $DAILY_RUN_TIME:00
Persistent=true

[Install]
WantedBy=timers.target" && changed=true

    if [[ "$changed" == true ]] || ! systemctl --user -q is-enabled "$APP_ID.timer" 2>/dev/null; then
        systemctl --user daemon-reload >/dev/null 2>&1
        systemctl --user enable --now "$APP_ID.timer" >/dev/null 2>&1 &&
            log "Systemd timer enabled ($DAILY_RUN_TIME daily)."
    fi
}

# ------------------------------------------------------------------------------
# Current image bookkeeping. Current image is apod_current_<date>.<ext>; the
# date in the name changes daily so desktops (KDE) notice the new file.
# ------------------------------------------------------------------------------

current_img() {
    find "$APOD_DIR" -maxdepth 1 -type f -name 'apod_current*' | sort | tail -n 1
}

img_date() {
    local file="$1" name
    name=$(basename "$file")
    if [[ "$name" =~ ([0-9]{4}-[0-9]{2}-[0-9]{2}) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        date -d "@$(stat -c %Y "$file")" +%F
    fi
}

archive_current() {
    local cur="$1"
    [[ -n "$cur" && -f "$cur" ]] || return 0

    local d ext dest n=1
    d=$(img_date "$cur")
    ext="${cur##*.}"
    dest="$OL_DIR/apod_${d}.${ext}"
    while [[ -e "$dest" ]]; do
        dest="$OL_DIR/apod_${d}_${n}.${ext}"
        n=$((n + 1))
    done
    mv "$cur" "$dest"
    log "Archived previous APOD to: $dest"
}

# ------------------------------------------------------------------------------
# Fetching
# ------------------------------------------------------------------------------

# Prints "<date>\t<image url>" for the newest feed item.
latest_apod() {
    local feed item pub url
    feed=$(curl -fsSL --connect-timeout 5 --max-time 30 "$APOD_FEED_URL") || return 1
    item=$(printf '%s' "$feed" | awk '/<item>/{f=1} f{print} /<\/item>/{exit}')
    [[ -n "$item" ]] || return 1

    pub=$(printf '%s' "$item" | grep -oP '(?<=<pubDate>)[^<]+' | head -n 1)
    url=$(printf '%s' "$item" | grep -oP '(?<=<apod:hdurl>)[^<]+' | head -n 1)
    url="${url//&#038;/&}"
    url="${url//&amp;/&}"

    printf '%s\t%s\n' "$(TZ="$APOD_TZ" date -d "$pub" +%F 2>/dev/null || date +%F)" "$url"
}

# The feed links a resized copy (/dynamicimage/...?w=744). The original lives
# at the same path under /content/dam/ with no query string.
original_url() {
    local url="${1%%\?*}"
    echo "${url/\/dynamicimage\/assets\//\/content\/dam\/}"
}

download_image() {
    local url="$1"
    curl -fsSL --connect-timeout 5 --max-time 120 "$url" -o "$TMP_FILE" &&
        [[ "$(file -b --mime-type "$TMP_FILE")" == image/* ]] && return 0
    rm -f "$TMP_FILE"
    return 1
}

fetch_apod() {
    local cur="$1" cur_date="$2"
    local deadline=$((SECONDS + RETRY_MAX)) info apod_date hdurl ext

    until info=$(latest_apod); do
        if (( SECONDS >= deadline )); then
            log "Feed unreachable after ${RETRY_MAX}s. Keeping current wallpaper."
            return 1
        fi
        sleep "$RETRY_INTERVAL"
    done
    IFS=$'\t' read -r apod_date hdurl <<< "$info"

    if [[ "$FORCE" != true && "$apod_date" == "$cur_date" ]]; then
        log "Newest APOD ($apod_date) is already set. Nothing new yet."
        return 0
    fi

    if [[ -z "$hdurl" ]]; then
        log "No image in today's APOD ($apod_date, probably a video). Using fallback."
        archive_current "$cur"
        set_wallpaper "$FALLBACK_IMG" wait
        return 0
    fi

    if ! download_image "$(original_url "$hdurl")" && ! download_image "$hdurl"; then
        log "Failed to download $hdurl. Keeping current wallpaper."
        return 1
    fi

    ext="${hdurl%%\?*}"
    ext="${ext##*.}"
    ext="${ext,,}"
    [[ "$ext" =~ ^(jpe?g|png|gif|webp)$ ]] || ext=jpg

    # Re-downloading the same day (--force) replaces it instead of archiving.
    if [[ "$apod_date" == "$cur_date" ]]; then rm -f "$cur"; else archive_current "$cur"; fi
    local new="$APOD_DIR/apod_current_${apod_date}.${ext}"
    mv "$TMP_FILE" "$new"
    set_wallpaper "$new" wait
    log "Done. APOD $apod_date set."
}

main() {
    exec 9>"$LOCK_FILE"
    if ! flock -n 9; then
        log "Another APOD run is already active. Exiting."
        exit 0
    fi

    [[ "$INSTALL_AUTOSTART" == true ]] && install_autostart
    [[ "$INSTALL_TIMER" == true ]] && install_timer

    local today cur cur_date=""
    today=$(TZ="$APOD_TZ" date +%F)
    cur=$(current_img)
    [[ -n "$cur" ]] && cur_date=$(img_date "$cur")

    log "Desktop: $(detect_desktop) | APOD date: $today | Current: ${cur:-none} | Force: $FORCE"

    # Show the existing image right away so the distro default never flashes
    # while we wait on the network.
    set_wallpaper "${cur:-$FALLBACK_IMG}" || true

    if [[ "$FORCE" != true && "$cur_date" == "$today" ]]; then
        log "Already have today's APOD. Use --force to re-download."
        exit 0
    fi

    fetch_apod "$cur" "$cur_date"
}

main "$@"
