#!/bin/sh

INTERFACE=wlan0
DRIVER=iwlagn
DRIVER_PARAMETERS="11n_disable=1"

# Needs root
if [ `whoami` != "root" ]; then
    if [ -z " $TERM" ]; then
        gksudo $0 $@
    else
        sudo $0 $@
    fi
    exit 0
fi

state() {
    if lsmod | grep -q "^$DRIVER"; then
        echo on
    else
        echo off
    fi
}

kill_wireless() {
    # make sure we have a clean environment
    if [ -e /etc/init.d/network-manager ]; then
        service network-manager stop
    fi

    killall wpa_supplicant dhclient dhclient3 2>/dev/null

    # the iwlagn driver sometimes becomes corrupted - reload it to be safe
    if [ `state` = "on" ]; then
        modprobe -r $DRIVER
    fi
}

start_wireless() {
    kill_wireless
    modprobe $DRIVER $DRIVER_PARAMETERS
    sleep 1
    wpa_supplicant -i$INTERFACE -c/etc/wpa_supplicant.conf -Dwext &
    sleep 5
    dhclient $INTERFACE &
}

# Generates combined config file for wpa_supplicant
cat /etc/wpa_supplicant/conf.d/* > /etc/wpa_supplicant.conf


if [ " $1" = " off" ]; then
    kill_wireless
elif [ " $1" = " state" ]; then
    state
elif [ " $1" = " toggle" ]; then
    if [ `state` = "on"]; then
        kill_wireless
    else
        start_wireless
    fi
else
    start_wireless
fi
