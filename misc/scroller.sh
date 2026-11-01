#!/usr/bin/env bash

# ==================== CONFIGURATION ====================
# 1. Wait Time Settings (Time between scrolls, in seconds)
NORMAL_WAIT_TIME=215         # Base time for normal mode
NORMAL_WAIT_TOLERANCE=29     # Plus or minus tolerance for normal wait

TEST_WAIT_TIME=3             # Base time for test mode
TEST_WAIT_TOLERANCE=0        # Plus or minus tolerance for test mode (0 = flat)

# 2. Scroll Click Settings (Number of mouse wheel clicks per action)
SCROLL_CLICKS=3              # Base number of scroll clicks (Button 5)
SCROLL_TOLERANCE=1           # Plus or minus tolerance for scroll clicks
# =======================================================

# Saved overrides from edit mode
CONFIG_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/scroller.conf"
[ -f "$CONFIG_FILE" ] && source "$CONFIG_FILE"

edit_mode() {
    local vars=(NORMAL_WAIT_TIME NORMAL_WAIT_TOLERANCE SCROLL_CLICKS SCROLL_TOLERANCE)
    local labels=("Wait time (s)" "Wait tolerance (±s)" "Scroll clicks" "Scroll tolerance (±clicks)")
    echo "Edit mode: Enter = keep current value"
    local i v input
    for i in "${!vars[@]}"; do
        v=${vars[$i]}
        while true; do
            read -r -p "${labels[$i]} [${!v}]: " input
            [ -z "$input" ] && break
            if [[ "$input" =~ ^[0-9]+$ ]]; then printf -v "$v" '%s' "$input"; break; fi
            echo "  Enter a non-negative integer."
        done
    done
    mkdir -p "$(dirname "$CONFIG_FILE")"
    for v in "${vars[@]}"; do echo "$v=${!v}"; done > "$CONFIG_FILE"
    echo "Saved to $CONFIG_FILE"
    echo ""
}

# Parse command line arguments
TEST_MODE=false
EDIT_MODE=false
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -t|--test) TEST_MODE=true ;;
        -e|--edit) EDIT_MODE=true ;;
        *) echo "Unknown option: $1"; echo "Usage: $0 [-t|--test] [-e|--edit]"; exit 1 ;;
    esac
    shift
done

[ "$EDIT_MODE" = true ] && edit_mode

# Determine active wait settings
if [ "$TEST_MODE" = true ]; then
    BASE_TIME=$TEST_WAIT_TIME
    TOLERANCE=$TEST_WAIT_TOLERANCE
    MODE_NAME="TEST MODE"
else
    BASE_TIME=$NORMAL_WAIT_TIME
    TOLERANCE=$NORMAL_WAIT_TOLERANCE
    MODE_NAME="NORMAL MODE"
fi

# Clear start screen and print status
clear
echo "========================================"
echo "         CHILL-SCROLL SCRIPT            "
echo "========================================"
echo " Status: RUNNING IN [$MODE_NAME]"
echo " Wait Time: ${BASE_TIME}s (Tolerance: ±${TOLERANCE}s)"
echo " Scroll Amount: ${SCROLL_CLICKS} clicks (Tolerance: ±${SCROLL_TOLERANCE})"
echo " Controls: Press 'p' to pause, 's' to stop"
echo "========================================"
echo ""

# Helper function to sleep with a live countdown and key listener
smart_sleep() {
    local remaining=$1
    while [ $remaining -gt 0 ]; do
        printf "\rNext scroll in: %3ds | [p]ause, [s]top   " "$remaining"
        if read -t 1 -n 1 key; then
            if [[ "$key" == "s" || "$key" == "S" ]]; then
                echo -e "\n\nStopped by user."
                exit 0
            elif [[ "$key" == "p" || "$key" == "P" ]]; then
                echo -e "\n\nPaused. Press any key to resume..."
                read -n 1 -s
                echo "Resumed."
            fi
        fi
        remaining=$((remaining - 1))
    done
    printf "\r%-50s\r" "" # Clear the countdown line
}

do_scroll() {
    local clicks
    if [ "$SCROLL_TOLERANCE" -eq 0 ]; then
        clicks=$SCROLL_CLICKS
    else
        clicks=$(( SCROLL_CLICKS + (RANDOM % (2 * SCROLL_TOLERANCE + 1)) - SCROLL_TOLERANCE ))
        [ $clicks -lt 1 ] && clicks=1
    fi
    for ((i=0; i<clicks; i++)); do
        if command -v ydotool >/dev/null && [ -S "${YDOTOOL_SOCKET:-/tmp/.ydotool_socket}" ]; then
            ydotool mousemove --wheel -x 0 -y -1   # uinput: no Wayland permission prompt
        else
            xdotool click 5                        # fallback: triggers KDE prompt on Wayland
        fi
        [ $clicks -gt 1 ] && sleep 0.05
    done
}

# Initial delay before first scroll
INITIAL_DELAY=3
smart_sleep "$INITIAL_DELAY"
do_scroll

while true; do
    # Calculate wait time with tolerance
    if [ "$TOLERANCE" -eq 0 ]; then
        total_sleep=$BASE_TIME
    else
        rand_offset=$(( (RANDOM % (2 * TOLERANCE + 1)) - TOLERANCE ))
        total_sleep=$(( BASE_TIME + rand_offset ))
        [ $total_sleep -lt 1 ] && total_sleep=1
    fi

    # Run the live countdown sleep
    smart_sleep "$total_sleep"

    do_scroll
done
