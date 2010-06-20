# For at bruge mit system skal følgende pakker være installeret:
# xmonad
# dzen2
# acpi
# alsa-utils
# pavucontroller
# pidgin
# mplayer
# gnome (for at kunne logge ind i gnome + lock)
# wpa_supplicant
# x11-xserver-utils (til xmodmap)
# xbindkeys (til genvejstaster)

# Får japansk input til at virke
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
im-switch -s ibus


# Der køres programmer fra min bin-mappe
export PATH="$HOME/bin:$PATH"

# Default browser er chrome
export BROWSER="google-chrome"

# Fixer en bug i ubuntu, som gør at den første lyd der bliver spillet muter
# systemet (gnome fixer det normalt)
soundcontroller init

# Sætter min skærm op til at køre som jeg vil have. Kan fjernes, hvis man ikke
# jævnligt tilslutter andre skærme
tvconnect

# Gør så ctrl+alt+backspace dræber X
setxkbmap -option terminate:ctrl_alt_bksp

# Laver headeren
dzenheader &

# Gør så at tasterne opfører sig fornuftigt. Eksempelvis fjernes caps-lock og
# shift+4 bliver til at $-tegn.
xmodmap ~/.xmodmap

# Gør så jeg kan bruge gnome screensaveren til at låse skærmen
gnome-screensaver

# Starter wireless scriptet, så der logges på nettet
wireless.sh &

# Starter chats
(skype & (sleep 10; pidgin)) &

# Låser skærmen, når låget er lukket og der ikke er eksterne skærme tilsluttet
screenlocker &

# Gemmer DBUS
set | grep DBUS > ~/.xmonad/tempenv

# Starter xmonad
xmonad

# Det så ikke ud som om at dzen lukkede automatisk ved logud - så det gør den
# nu.
killall dzenheader dzen2
