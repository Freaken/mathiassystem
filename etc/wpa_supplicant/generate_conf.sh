#!/bin/sh
rm -rf /etc/wpa_supplicant.conf
echo -n > /etc/wpa_supplicant.conf
chmod 400 /etc/wpa_supplicant.conf
for fil in /etc/wpa_supplicant/conf.d/*; do
  cat $fil >> /etc/wpa_supplicant.conf
done
