#!/usr/bin/env bash

while read d
do
  adb -s $d reconnect
done < "${1:-/dev/stdin}"
