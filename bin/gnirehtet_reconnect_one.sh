#!/usr/bin/env bash

DEVICE=$1

PID=$$
echo ${PID}

PIDFILE=/tmp/one_${DEVICE}.pid
trap "rm -f ${PIDFILE}" EXIT

if [ -f ${PIDFILE} ]; then
  kill -KILL `cat ${PIDFILE}`
  rm -f ${PIDFILE}
fi

echo $$ > ${PIDFILE}

NS=$(cat /etc/resolv.conf | grep nameserver | sed 's/nameserver//')

while true; do
  sleep 20
  if [ "$GNIREHTET_ENABLED" = "true" ]; then
    (adb devices | grep ${DEVICE}) && \
    echo -n | timeout -t 5 adb -s ${DEVICE} reverse localabstract:gnirehtet tcp:31416 && \
    echo -n | timeout -t 10 adb -s ${DEVICE} shell am broadcast \
               -a com.genymobile.gnirehtet.START -n com.genymobile.gnirehtet/.GnirehtetControlReceiver --esa dnsServers ${NS}
  fi
done
