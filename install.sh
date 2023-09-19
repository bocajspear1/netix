#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "Must be run as root"
    exit
fi

apt-get update
apt-get install -y virtualbox-guest-additions open-vm-tools-desktop python3-pip python-venv mininet python3-tk wireshark tcpdump wget curl mousepad

echo "Install FRR..."
# add GPG key
curl -s https://deb.frrouting.org/frr/keys.gpg | tee /usr/share/keyrings/frrouting.gpg > /dev/null

# possible values for FRRVER: frr-6 frr-7 frr-8 frr-9 frr-stable
# frr-stable will be the latest official stable release
FRRVER="frr-stable"
echo deb '[signed-by=/usr/share/keyrings/frrouting.gpg]' https://deb.frrouting.org/frr \
     $(lsb_release -s -c) $FRRVER | tee -a /etc/apt/sources.list.d/frr.list

# update and install FRR
apt update && apt install -y frr frr-pythontools

echo "Install Faucet..."
apt-get install curl gnupg apt-transport-https lsb-release
mkdir -p /etc/apt/keyrings/
curl -1sLf https://packagecloud.io/faucetsdn/faucet/gpgkey | gpg --dearmor -o /etc/apt/keyrings/faucet.gpg
echo "deb [signed-by=/etc/apt/keyrings/faucet.gpg] https://packagecloud.io/faucetsdn/faucet/$(lsb_release -si | awk '{print tolower($0)}')/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/faucet.list
apt-get update
apt-get install -y faucet python-faucet

echo "Enabling forwarding..."
echo "net.ipv4.ip_forward=1" | tee --append /etc/sysctl.conf
echo "net.ipv6.conf.all.forwarding=1" | tee --append /etc/sysctl.conf
sysctl -p

echo "Installing custom scripts..."
chmod +x ./scripts/*
cp ./scripts/* /usr/local/bin/

echo "Installing custom apps..."
cp -r ./apps/miniedit2 /opt/miniedit2

echo "Installing custom .desktop files..."
cp ./desktop/* /usr/share/applications/

# https://askubuntu.com/questions/944685/pasting-external-text-into-xterm-or-uxterm
echo "Install xterm copy-paste fixes..."
cp ./configs/Xresources /home/*/.Xresources
cp ./configs/Xresources /root/.Xresources