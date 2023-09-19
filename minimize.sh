#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Must be run as root"
    exit
fi

echo "Removing extra packages..."
apt-get remove libreoffice-core libreoffice-common thunderbird

apt-get autoclean
apt-get autoremove
apt-get clean
rm /var/cache/apt/*.bin
rm -rf /var/log/*

find /var/log -exec ls; truncate -s 0 {} \;