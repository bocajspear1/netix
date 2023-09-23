#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Must be run as root"
    exit
fi

echo "Removing extra packages..."
apt-get remove libreoffice-core libreoffice-common thunderbird synaptic

apt-get autoclean
apt-get autoremove
apt-get clean
rm /var/cache/apt/*.bin

systemctl stop rsyslog
find /var/log -exec ls; truncate -s 0 {} \;


snap remove --purge $(sudo snap list | grep gnome- | cut -d' ' -f 1)
snap remove --purge gtk-common-themes
snap remove --purge $(sudo snap list | grep core | cut -d' ' -f 1)
snap remove --purge bare
snap remove --purge snapd

swapoff
truncate -s 0 /swapfile

echo '
SWAPSIZE=$(stat -c%s /swapfile)

if [ $SWAPSIZE -eq 0 ]; then
    swapoff -a
    dd if=/dev/zero of=/swapfile bs=1MiB count=$((4*1024))
    swapon /swapfile
fi
' | tee /etc/rc.local
chmod +x /etc/rc.local