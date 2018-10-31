#!/usr/bin/env bash

if [ "$GNIREHTET_ENABLED" = "false" ]; then
  echo "Removing traces of gnirehtet"
  for device in `adb devices | sed -n '1!p' | sed '$d' | awk '{print ""$1""}'`; do
    echo "Processing $device"
    output=$(adb shell pm list packages com.genymobile.gnirehtet)
    echo "$output"
    if [[ "$output" =~ "com.genymobile.gnirehtet" ]]; then
      "$device has gnirehtet installed. Uninstalling..."
      (cd /; exec ./gnirehtet stop $device)
      (cd /; exec ./gnirehtet uninstall $device)
    fi
  done
fi
