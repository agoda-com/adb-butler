#/usr/bin/env bash

adb devices | sed -n '1!p' | sed '$d' | awk '{gsub("device","online",$2); print "android,serial="$1",status="$2"","value=1",systime()}' > /custom-metrics/devices
