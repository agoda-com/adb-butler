#!/usr/bin/env bash

adb -P 5037 kill-server
adb -a -P 5037 server nodaemon
