#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Must be run as root"
    exit
fi

echo "Removing extra packages..."
apt-get remove -y libreoffice-core libreoffice-common thunderbird synaptic

apt-get autoremove -y --purge
apt-get autoclean
apt-get clean
rm -rf /var/cache/apt/*.bin

snap remove --purge $(sudo snap list | grep gnome- | cut -d' ' -f 1)
snap remove --purge gtk-common-themes
snap remove --purge $(sudo snap list | grep core | cut -d' ' -f 1)
snap remove --purge bare
snap remove --purge snapd
systemctl stop snapd

rm /var/lib/snapd/seed/snaps/*

swapoff -a
dd if=/dev/zero of=/swapfile bs=1MiB count=$((4*1024))
truncate -s 0 /swapfile

echo '
SWAPSIZE=$(stat -c%s /swapfile)

if [ $SWAPSIZE -eq 0 ]; then
    swapoff -a
    dd if=/dev/zero of=/swapfile bs=1MiB count=$((4*1024))
    mkswap /swapfile
    swapon /swapfile
fi
' | tee /etc/rc.local
chmod +x /etc/rc.local

systemctl stop rsyslog
systemctl stop systemd-journald
find /var/log -type f -name '*.gz' -exec rm -rf {} \;
find /var/log -type f -name '*.old' -exec rm -rf {} \;
find /var/log -type f -exec truncate -s 0 {} \;