#!/usr/bin/env bash
set -u
set -o pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# --- SCHEDULE TRIGGERS ---
# Run automatically every day at a specific time? (true/false)
ENABLE_DAILY_SCHEDULE=true
# Format: "YYYY-MM-DD HH:MM:SS" (Uses 24-hour clock, use "*-*-*" for every day)
DAILY_SCHEDULE_TIME="*-*-* 12:00:00"

# Run automatically when you log in / start the computer? (true/false)
ENABLE_STARTUP_RUN=false
STARTUP_DELAY_MINUTES=3

# --- DESTINATION ---
# Main destination inside your Google Drive
DEST_ROOT="gdrive:George - Framework Laptop"

# --- BACKUP JOBS ---
# Format: "Friendly Name | Local Source | Drive Destination | Exclusions (comma-separated)"
BACKUP_JOBS=(
  "Desktop               | $HOME/Desktop                                                                                               | Desktop               | Media/**"
  "Documents             | $HOME/Documents                                                                                             | Documents             | repos/**"
  "Pictures              | $HOME/Pictures                                                                                              | Pictures              | "
  "Minecraft screenshots | $HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/1.21.6/minecraft/screenshots    | minecraft/screenshots | "
  "Minecraft saves       | $HOME/.var/app/org.prismlauncher.PrismLauncher/data/PrismLauncher/instances/1.21.6/minecraft/saves          | minecraft/saves       | "
)

# ==============================================================================
# SCRIPT LOGIC (Do not edit below unless modifying core behavior)
# ==============================================================================

SCRIPT_PATH=$(readlink -f "$0")
BACKUP_DIR=$(dirname "$SCRIPT_PATH")
LOG_FILE="$BACKUP_DIR/driveBackup.log"
LOCK_FILE="/tmp/driveBackup.lock"
SYSTEMD_DIR="$HOME/.config/systemd/user"

ERRORS=0

say() {
  echo "$1"
}

notify() {
  local title="$1"
  local msg="$2"
  export DISPLAY=:0
  export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
  command -v notify-send >/dev/null && notify-send "$title" "$msg" -i drive-harddisk -t 5000 || true
}

log_ok() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): OK: backup completed" >> "$LOG_FILE"
}

log_error() {
  echo "$(date '+%Y-%m-%d %H:%M:%S'): ERROR: $1" >> "$LOG_FILE"
}

install_triggers() {
  mkdir -p "$SYSTEMD_DIR"
  
  rm -f "$HOME/.config/autostart/google-drive-backup.desktop"
  rm -f "$HOME/.config/autostart/drive-backup.desktop"

  local service_file="$SYSTEMD_DIR/google-drive-backup.service"
  local timer_file="$SYSTEMD_DIR/google-drive-backup.timer"

  # 1. Update Service File
  cat > "$service_file" <<EOF
[Unit]
Description=Google Drive Backup Service

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash "$SCRIPT_PATH"
EOF

  # 2. Update Timer File based on variables
  if [[ "$ENABLE_DAILY_SCHEDULE" == "false" ]] && [[ "$ENABLE_STARTUP_RUN" == "false" ]]; then
    systemctl --user disable --now google-drive-backup.timer >/dev/null 2>&1 || true
    say "All automated schedules disabled."
    return 0
  fi

  cat > "$timer_file" <<EOF
[Unit]
Description=Run Google Drive backup triggers

[Timer]
Persistent=true
EOF

  if [[ "$ENABLE_DAILY_SCHEDULE" == "true" ]]; then
    echo "OnCalendar=$DAILY_SCHEDULE_TIME" >> "$timer_file"
  fi

  if [[ "$ENABLE_STARTUP_RUN" == "true" ]]; then
    echo "OnStartupSec=${STARTUP_DELAY_MINUTES}m" >> "$timer_file"
  fi

  cat >> "$timer_file" <<EOF

[Install]
WantedBy=timers.target
EOF

  systemctl --user daemon-reload >/dev/null 2>&1 || true
  systemctl --user enable --now google-drive-backup.timer >/dev/null 2>&1 || true
}

wait_for_network() {
  say "Checking network..."
  for _ in $(seq 1 15); do
    if ping -c 1 -W 2 google.com >/dev/null 2>&1; then
      say "Network ok."
      return 0
    fi
    sleep 4
  done
  say "Network not confirmed. Trying anyway."
}

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}

execute_sync() {
  local name="$1"
  local source="$2"
  local dest="$DEST_ROOT/$3"
  local raw_excludes="$4"

  local err_file
  err_file="$(mktemp)"

  local exclude_args=()
  if [[ -n "$raw_excludes" ]]; then
    IFS=',' read -ra excl_arr <<< "$raw_excludes"
    for e in "${excl_arr[@]}"; do
      exclude_args+=(--exclude "$(trim "$e")")
    done
  fi

  if [[ ! -d "$source" ]]; then
    say "Missing, skipped: $name"
    log_error "missing folder: $name | $source"
    ERRORS=$((ERRORS + 1))
    rm -f "$err_file"
    return 0
  fi

  say "Syncing: $name -> $dest"

  if rclone sync "$source" "$dest" \
    "${exclude_args[@]}" \
    --create-empty-src-dirs \
    --fast-list \
    --transfers=8 \
    --checkers=16 \
    --drive-chunk-size=64M \
    --retries=3 \
    --low-level-retries=10 \
    --log-level NOTICE \
    2> >(tee "$err_file" >&2); then

    say "OK: $name"
  else
    say "FAILED: $name"
    log_error "failed syncing: $name ($source -> $dest)"
    sed 's/^/    /' "$err_file" >> "$LOG_FILE"
    ERRORS=$((ERRORS + 1))
  fi

  rm -f "$err_file"
}

main() {
  chmod +x "$SCRIPT_PATH" 2>/dev/null || true

  exec 9>"$LOCK_FILE"
  if ! flock -n 9; then
    say "Backup already running. Exiting."
    exit 0
  fi

  install_triggers
  wait_for_network

  notify "Google Drive Backup" "Starting automated backup tasks..."
  say "Google Drive backup started. Logging to: $LOG_FILE"

  for job in "${BACKUP_JOBS[@]}"; do
    IFS='|' read -r raw_name raw_src raw_dest raw_excludes <<< "$job"
    execute_sync "$(trim "$raw_name")" "$(trim "$raw_src")" "$(trim "$raw_dest")" "$(trim "$raw_excludes")"
  done

  if [[ "$ERRORS" -eq 0 ]]; then
    say "Backup finished successfully."
    log_ok
    notify "Google Drive Backup" "✅ All folders successfully synced."
  else
    say "Backup finished with $ERRORS error(s). See: $LOG_FILE"
    notify "Google Drive Backup" "⚠️ Backup completed with $ERRORS error(s). Check logs."
  fi
}

main "$@"
