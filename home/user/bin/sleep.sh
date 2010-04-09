#!/bin/sh

if [ `whoami` != 'root' ]; then
	sudo $0
	exit 0
fi

sudo -u daniel /usr/bin/gnome-screensaver-command -l
sleep 2
/etc/acpi/sleep.sh force

