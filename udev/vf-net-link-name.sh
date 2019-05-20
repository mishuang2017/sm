#!/bin/bash

SWID=$1
# might be pf0vf1 so only get vf number
PORT=${2##*f}
PORT_UPLINK="65534"
PORT_UPLINK0="p0"
PORT_UPLINK1="p1"

echo "$(date) $1 $2 $PORT" >> /root/udev.txt

if [ "$PORT" = "$PORT_UPLINK0" ] || [ "$PORT" = "$PORT_UPLINK1" ]; then
    # old systemd (i.e. systemd-219-62 rhel 7.6) doesn't export ID_NET_NAME
    # but has ID_NET_NAME_PATH
    if [ -z "$ID_NET_NAME" ] && [ -n "$ID_NET_NAME_PATH" ]; then
        ID_NET_NAME=$ID_NET_NAME_PATH
    fi
    if [ -n "$ID_NET_NAME" ]; then
        n=${ID_NET_NAME##*n}
        if [ "$n" = "$PORT_UPLINK0" ] || [ "$n" = "$PORT_UPLINK1" ]; then
            # strip n*
            NAME=${ID_NET_NAME%n*}
        else
            NAME=$ID_NET_NAME
        fi
        echo "NAME=$NAME"
    fi
    exit
fi

if [ "$PORT" = "$PORT_UPLINK" ]; then
    if [ -n "$ID_NET_NAME" ]; then
        NAME=${ID_NET_NAME%n$PORT_UPLINK}
        echo "NAME=$NAME"
    fi
    exit
fi

for i in `ls -1 /sys/class/net/*/address`; do
    name=$(ls $i | cut -d / -f 5)
    [ "$name" == "br" ] && continue
    [ "$name" == "bond0" ] && continue
    nic=`echo $i | cut -d/ -f 5`
    address=`cat $i | tr -d :`
    if [ "$address" = "$SWID" ]; then
        echo "NAME=${nic}_$PORT"
        break
    fi
done
