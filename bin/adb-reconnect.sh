#!/usr/bin/env bash

while read d
do
    timeout -t 3 adb -s $d reconnect
done < "${1:-/dev/stdin}"
