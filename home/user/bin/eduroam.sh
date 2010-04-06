#!/bin/sh

# eduroam skal køres fra en terminal
#if [ -z $TERM ]; then
#    gnome-terminal -e ~/bin/eduroam.sh &
#    exit 0
#fi

# Og skal køres som root
if [ `whoami` != "root" ]; then
    sudo $0
    read TEST
    exit 0
fi


# Genererer /etc/wpa_supplicant.conf ud fra de filer der ligger i
# /etc/wpa_supplicant/conf.d
/etc/wpa_supplicant/generate_conf.sh

# make sure we have a clean environment
service network-manager stop
killall wpa_supplicant
killall dhclient


modprobe -r iwlagn
modprobe iwlagn

sleep 1
wpa_supplicant -iwlan0 -c/etc/wpa_supplicant.conf -Dwext &
sleep 5
dhclient wlan0 &
