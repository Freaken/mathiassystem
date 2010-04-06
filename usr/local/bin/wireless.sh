#!/bin/sh

# eduroam skal køres fra en terminal
#if [ -z $TERM ]; then
#    gnome-terminal -e ~/bin/eduroam.sh &
#    exit 0
#fi

# Og skal køres som root
if [ `whoami` != "root" ]; then
    if [ -z " $TERM" ]; then
        gksudo $0
        exit 0
    fi

    sudo $0
    exit 0
fi


# Genererer /etc/wpa_supplicant.conf ud fra de filer der ligger i
# /etc/wpa_supplicant/conf.d
cat /etc/wpa_supplicant/conf.d/* > /etc/wpa_supplicant.conf

# make sure we have a clean environment
killall wpa_supplicant
killall dhclient

if [ `hostname` = "phobetor" ]; then
    modprobe -r iwlagn
    modprobe iwlagn
fi

sleep 1
wpa_supplicant -iwlan0 -c/etc/wpa_supplicant.conf -Dwext &
sleep 5
dhclient wlan0 &
