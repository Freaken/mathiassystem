#!/bin/sh

INTERFACE=wlan0

# Needs root
if [ `whoami` != "root" ]; then
    if [ -z " $TERM" ]; then
        gksudo $0
    else
        sudo $0
    fi
    exit 0
fi


# Generates combined config file for wpa_supplicant
cat /etc/wpa_supplicant/conf.d/* > /etc/wpa_supplicant.conf

# make sure we have a clean environment
service network-manager stop
killall wpa_supplicant
killall dhclient

sleep 1
wpa_supplicant -i$INTERFACE -c/etc/wpa_supplicant.conf -Dwext &
sleep 5
dhclient $INTERFACE &
