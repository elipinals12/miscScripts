#!/bin/bash

TEST_MODE=0

if [[ "$1" == "-t" ]]; then
  TEST_MODE=1
  echo "TEST MODE ON"
fi

while true; do

  if [[ $TEST_MODE -eq 1 ]]; then
    sleep_sec=5
  else
    sleep_sec=$(awk 'BEGIN{srand(); print 40 + (rand()-0.5)*20}')
  fi

  # 1s ± 0.5s => 0.5–1.5s
  hold=$(awk 'BEGIN{srand(); print 1 + (rand()-0.5)*1}')
  hold_show=$(awk -v h="$hold" 'BEGIN{printf "%.2f", h}')

  echo "[$(date '+%H:%M:%S')] next in ${sleep_sec}s | hold=${hold_show}s"

  sleep $sleep_sec

  xdotool search --onlyvisible --class chrome windowactivate --sync

  xdotool keydown Down
  sleep $hold
  xdotool keyup Down

  echo "[$(date '+%H:%M:%S')] scrolled"
done
