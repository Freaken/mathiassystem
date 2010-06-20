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

# Japanese input
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
im-switch -s ibus

# Add ~/bin to PATH
export PATH="$HOME/bin:$PATH"

# Default browser er chrome
export BROWSER="google-chrome"

# Turns off audio
soundcontroller init

# Fixes screen
tvconnect

# Enables the ctrl+alt+backspace shortcut to kill X
setxkbmap -option terminate:ctrl_alt_bksp

# Creates the header
dzenheader &

# Remaps some of the keys
xmodmap ~/.xmodmap

# For locking the screen
gnome-screensaver

# Starts the wireless script
wireless.sh &

# Starts IMs
(skype & (sleep 10; pidgin)) &

# Låser skærmen, når låget er lukket og der ikke er eksterne skærme tilsluttet
screenlocker &

# Saves DBUS
set | grep DBUS > ~/.xmonad/tempenv

# Starts xmonad
xmonad

# Make sure that dzen doesn't keep running after logout
killall dzenheader dzen2

