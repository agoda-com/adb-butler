#/usr/bin/env bash

# set -x

array=`adb devices | grep device$ | awk '{print $1}'`

for f in $(find /sys/devices/* -name "bInterfaceSubClass" -type f -print | xargs grep "42" |  rev | cut -c 23- | rev); do

  if [ "$(cat $f/bInterfaceClass)" == "ff" ] &&
     [ "$(cat $f/bInterfaceProtocol)" == "01" ]; then
    serial=$(cat $f/../serial)
    device=`echo $array | grep $serial`
    if [[ ! -z "${device// }" ]]; then
      echo "device is connected : $serial"
    else
      echo "device is not connected : $serial"
      echo "device path : $f"
      ID=$(echo "$f" | rev | cut -d/ -f2 | rev)
      echo "device id is $ID"
      echo -n "$ID" > /sys/bus/usb/drivers/usb/unbind
      echo -n "$ID" > /sys/bus/usb/drivers/usb/bind
    fi
  fi
done;

for f in $(dmesg | egrep -o "usb [0-9]+\\-[0-9\\.]+" | sort | uniq | cut -c 5-); do
  if [ -L "/sys/bus/usb/devices/$f" ] && [ ! -L "/sys/bus/usb/devices/$f/driver" ] ; then
    echo "device $f: driver is not binded. trying to bind the device back"
    echo -n "$f" > /sys/bus/usb/drivers/usb/bind
  fi
done;
