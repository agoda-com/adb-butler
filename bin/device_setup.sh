#!/usr/bin/env bash

DL=/tmp/devices_list
PKG=com.genymobile.gnirehtet

rm -f $DL
touch -f $DL
sleep 10

cd /

function setup_gnirehtet {
  local DEVICE=$1

  if (echo -n | adb -s $d shell pm list packages | grep -q $PKG); then
    echo Already have $PKG
  else
    echo Not installed $PKG
    echo -n | timeout -t 30 ./gnirehtet install $DEVICE
    echo -n | timeout -t 30 adb -s $d reverse localabstract:gnirehtet tcp:31416
    echo -n | timeout -t 30 adb -s $d shell am broadcast -a com.genymobile.gnirehtet.START -n com.genymobile.gnirehtet/.GnirehtetControlReceiver --esa dnsServers 10.120.1.123
  fi
}

function cleanup_gnirehtet {
  local DEVICE=$1
  echo -n | timeout -t 30  ./gnirehtet stop $DEVICE
  echo -n | timeout -t 30  ./gnirehtet uninstall $DEVICE
}

function clean_agoda_staff {
  local DEVICE=$1

  echo -n | timeout -t 30 adb -s $DEVICE uninstall com.agoda.mobile.consumer.debug.test
  echo -n | timeout -t 30 adb -s $DEVICE uninstall com.agoda.mobile.consumer.debug
  echo -n | timeout -t 30 adb -s $DEVICE uninstall com.agoda.mobile.consumer
  echo -n | timeout -t 30 adb -s $DEVICE uninstall com.agoda.mobile.swipe.debug.test
  echo -n | timeout -t 30 adb -s $DEVICE uninstall com.agoda.mobile.swipe.debug

}

while sleep 5; do
  echo -n | adb devices | egrep 'device$' | awk '{ print $1 }' | sort > $DL.new
  diff -u $DL $DL.new | grep '^[+][^+]' | sed -E 's/^\+//' | while read d; do

    echo Connected $d

    if [ "$GNIREHTET_ENABLED" = "true" ]; then
      echo Gonna setup gnirehtet for $d
      setup_gnirehtet $d
    else
      echo Gonna cleanup gnrehtet for $d
      cleanup_gnirehtet $d
    fi

    clean_agoda_staff $d
  done

  mv $DL.new $DL
done