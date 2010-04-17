# The following packages need to be installed (probably others as well):
# xmonad
# dzen2
# acpi
# alsa-utils
# pavucontroller
# pidgin
# mplayer
# wpa_supplicant
# x11-xserver-utils (for xmodmap)
# xbindkeys (for shortcuts)

# Add ~/bin to PATH
export PATH="$HOME/bin:$PATH"

soundcontroller init

# Creates the header
dzenheader &

# Remaps some of the keys
xmodmap ~/.xmodmap

# For locking the screen
gnome-screensaver

# Starts the wireless script
wireless.sh &

# Starts KeePassX
keepassx &

# Saves DBUS
set | grep DBUS > ~/.xmonad/tempenv

# Starts xmonad/gnome
runwindowmanagers

# Make sure that dzen doesn't keep running after logout
killall dzenheader dzen2

