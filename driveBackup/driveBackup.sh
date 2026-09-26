#!/usr/bin/env bash
set -u
set -o pipefail

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# --- SCHEDULE TRIGGERS ---
# Run automatically on a recurring schedule? (true/false)
ENABLE_DAILY_SCHEDULE=true
# systemd OnCalendar format. "*-*-* *:00:00" = every hour, on the hour.
DAILY_SCHEDULE_TIME="*-*-* *:00:00"

# Run automatically when you log in / start the computer? (true/false)
ENABLE_STARTUP_RUN=false
STARTUP_DELAY_MINUTES=3

# --- RETRY / GIVE-UP ---
# Attempts per job (waits for network between tries), then gives up until next run.
MAX_ATTEMPTS=3
# Hard cap on whole run so it never overlaps the next hourly run.
MAX_RUNTIME_MIN=50

# --- DESTINATION ---
# Main destination inside your Google Drive
DEST_ROOT="gdrive:George - Framework Laptop"

# --- BACKUP JOBS ---
# Format: "Friendly Name | Local Source | Drive Destination | Exclusions (comma-separated)"
# Only the folders listed here are backed up; everything else in $HOME (including
# ~/media) is intentionally not backed up.
BACKUP_JOBS=(
  "Desktop               | $HOME/Desktop                                                                                               | Desktop               | "
  "Documents              | $HOME/Documents                                                                                             | Documents             | repos/**"
  "Videos                | $HOME/Videos                                                                                                | Videos                | "
  "Pictures               | $HOME/Pictures                                                                                              | Pictures              | "
  "Music                  | $HOME/Music                                                                                                 | Music                 | "
  "Scripts                | $HOME/scripts                                                                                               | scripts               | "
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
PID_FILE="/tmp/driveBackup.pid"
STATE_FILE="/tmp/driveBackup.state"
PROGRESS_FILE="/tmp/driveBackup.progress"
RUN_OUT="/tmp/driveBackup.out"
DEADLINE=0

ERRORS=0
FAILED_JOBS=()

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
  for _ in $(seq 1 15); do
    if ping -c 1 -W 2 google.com >/dev/null 2>&1; then
      return 0
    fi
    sleep 4
  done
  return 1
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
    FAILED_JOBS+=("$name (folder missing)")
    rm -f "$err_file"
    return 0
  fi

  say "Syncing: $name -> $dest"

  # Retry loop: completed files are skipped on each retry (resume at file level;
  # in-flight chunks retry inside rclone). Gives up on time cap / auth / attempts.
  local attempt rc=1 remaining
  for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
    remaining=$(( DEADLINE - $(date +%s) ))
    if (( remaining < 60 )); then
      say "Time cap reached, giving up: $name"
      echo "time cap reached" > "$err_file"
      rc=10
      break
    fi
    echo "$name (attempt $attempt/$MAX_ATTEMPTS)" > "$STATE_FILE"
    if ! wait_for_network; then
      say "No network (attempt $attempt/$MAX_ATTEMPTS)"
      echo "no network" > "$err_file"
      rc=1
      continue
    fi

    rclone sync "$source" "$dest" \
      "${exclude_args[@]}" \
      --create-empty-src-dirs \
      --fast-list \
      --transfers=4 \
      --checkers=8 \
      --tpslimit=8 \
      --tpslimit-burst=4 \
      --drive-chunk-size=16M \
      --retries=3 \
      --retries-sleep=20s \
      --low-level-retries=20 \
      --timeout=60s \
      --contimeout=30s \
      --max-duration "${remaining}s" \
      --stats=5s --stats-one-line --stats-log-level NOTICE \
      --log-level NOTICE \
      2> >(tee "$err_file" "$PROGRESS_FILE" >&2) &
    wait $!
    rc=$?
    (( rc == 0 )) && break
    say "Attempt $attempt/$MAX_ATTEMPTS failed (rc=$rc)"
    grep -q invalid_grant "$err_file" 2>/dev/null && { say "Auth expired, not retrying."; break; }
    (( rc == 10 )) && break
    sleep 5
  done

  if (( rc == 0 )); then
    say "OK: $name"
  else
    say "FAILED: $name"
    log_error "failed syncing: $name ($source -> $dest)"
    grep -v 'ETA' "$err_file" | sed 's/^/    /' >> "$LOG_FILE"
    ERRORS=$((ERRORS + 1))
    FAILED_JOBS+=("$name")
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

  DEADLINE=$(( $(date +%s) + MAX_RUNTIME_MIN * 60 ))
  echo $$ > "$PID_FILE"
  : > "$PROGRESS_FILE"
  trap 'pkill -TERM -P $$ 2>/dev/null; rm -f "$PID_FILE" "$STATE_FILE"' EXIT
  trap 'exit 143' TERM INT

  say "Google Drive backup started. Logging to: $LOG_FILE"

  for job in "${BACKUP_JOBS[@]}"; do
    IFS='|' read -r raw_name raw_src raw_dest raw_excludes <<< "$job"
    execute_sync "$(trim "$raw_name")" "$(trim "$raw_src")" "$(trim "$raw_dest")" "$(trim "$raw_excludes")"
  done

  if [[ "$ERRORS" -eq 0 ]]; then
    say "Backup finished successfully."
    log_ok
  else
    say "Backup finished with $ERRORS error(s). See: $LOG_FILE"
    local failed_list
    failed_list=$(printf '%s\n' "${FAILED_JOBS[@]}")
    notify "⚠️ Google Drive Backup" "$ERRORS error(s):
$failed_list"
  fi
}

is_running() { ! ( flock -n 8 ) 8>"$LOCK_FILE"; }

cmd_status() {
  if is_running; then
    echo "RUNNING pid=$(cat "$PID_FILE" 2>/dev/null || echo ?)"
    echo "job:      $(cat "$STATE_FILE" 2>/dev/null)"
    echo "progress: $(tail -n 1 "$PROGRESS_FILE" 2>/dev/null | cut -c1-140)"
  else
    echo "IDLE"
  fi
  echo "timer:    $(systemctl --user list-timers google-drive-backup.timer --no-legend 2>/dev/null | awk '{print $1,$2,$3}')"
  echo "last log:"
  tail -n 3 "$LOG_FILE" 2>/dev/null | cut -c1-160 | sed 's/^/  /'
}

cmd_start() {
  if is_running; then echo "already running"; cmd_status; return 0; fi
  setsid nohup "$SCRIPT_PATH" --run > "$RUN_OUT" 2>&1 < /dev/null &
  sleep 1
  cmd_status
}

cmd_stop() {
  if ! is_running; then echo "not running"; return 0; fi
  local pid; pid=$(cat "$PID_FILE" 2>/dev/null)
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    kill -TERM "$pid"
  else
    for p in $(pgrep -f "$SCRIPT_PATH"); do [[ "$p" != "$$" ]] && kill -TERM "$p"; done
    pkill -TERM -f 'rclone sync' 2>/dev/null
  fi
  sleep 1
  is_running && echo "still running?" || echo "stopped"
}

cmd_progress() {
  while true; do
    clear; cmd_status
    is_running || break
    sleep 2
  done
}

cmd_help() {
  cat <<EOF
Usage: $(basename "$0") [option]
  (none), -r, --run    run backup now, foreground (systemd uses this)
  -s, --start          start in background
  -x, --stop           stop running backup
  -t, --status         running? current job, progress line, timer, last log
  -p, --progress       live status, refreshes every 2s (ctrl-c to exit)
  -l, --log            follow log file
  -h, --help           this help

Files: log=$LOG_FILE  stdout=$RUN_OUT
Gives up after $MAX_ATTEMPTS attempts/job or ${MAX_RUNTIME_MIN}min total; next hourly timer retries.
EOF
}

case "${1:-}" in
  ""|-r|--run)      main ;;
  -s|--start)       cmd_start ;;
  -x|--stop)        cmd_stop ;;
  -t|--status)      cmd_status ;;
  -p|--progress)    cmd_progress ;;
  -l|--log)         tail -n 20 -f "$LOG_FILE" ;;
  -h|--help)        cmd_help ;;
  *)                echo "unknown option: $1"; cmd_help; exit 1 ;;
esac
