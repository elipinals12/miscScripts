#!/bin/bash

trap 'kill $SHIFT_PID 2>/dev/null; xdotool keyup Up; xdotool keyup Down; xdotool keyup shift; echo "Done."; exit' INT TERM EXIT

HOLD=70
SHIFT_HOLD=30
SHIFT_PAUSE=3

# shift refresh cycle in background
shift_loop() {
    while true; do
        xdotool keydown shift
        sleep $SHIFT_HOLD
        xdotool keyup shift
        sleep $SHIFT_PAUSE
    done
}

echo "Starting in 5 seconds..."
sleep 5

#shift_loop &
#SHIFT_PID=$!

while true; do
    echo "Holding UP..."
    xdotool keydown Up
    sleep $HOLD
    xdotool keyup Up

    echo "Holding DOWN..."
    xdotool keydown Down
    sleep $HOLD
    xdotool keyup Down
done
