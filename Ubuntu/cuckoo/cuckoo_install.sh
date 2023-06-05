#!/bin/bash

dir=$(pwd)

sudo apt-get update -y && sudo apt-get upgrade -y

sudo apt-get install curl wget neofetch qemu-guest-agent net-tools -y && echo "neofetch" >> .bashrc


cd $dir

## Ignoring below to see if cuckoo can still function with no network leak. 
### It should be in a DMZ regardless
# echo -ne "
# -------------------------------------------------------------------------
#                             Setup Network
# -------------------------------------------------------------------------
# "

# sudo rm -rf /etc/netplan/00-installer-config.yaml
# sudo cp $dir/configs/00-installer-config.yaml /etc/netplan/
# sudo netplan apply

echo -ne "
-------------------------------------------------------------------------
                            Install Packages
-------------------------------------------------------------------------
"

printf "Installing packages"
input="$dir/pkg_files/cuckoo_pkgs.txt"
while read -r line
do
  echo "Installing $line"
  sudo apt-get install ${line} -y
done < "$input"

sudo adduser cayub kvm

echo -ne "
-------------------------------------------------------------------------
                            Config Perms
-------------------------------------------------------------------------
"

## Fix kvm perms
sudo adduser "$USER" kvm && sudo chmod 666 /dev/kvm

## Setup tcpdump
sudo adduser "$USER" pcap

## Disable apparmor
sudo ln -s /etc/apparmor.d/usr.sbin.tcpdump /etc/apparmor.d/disable/ && sudo apparmor_parser -R /etc/apparmor.d/disable/usr.sbin.tcpdump && sudo apparmor_parser -r /etc/apparmor.d/usr.sbin.tcpdumpz


echo -ne "
-------------------------------------------------------------------------
                            Install Conda
-------------------------------------------------------------------------
"

cd /tmp
sleep 5
wget https://repo.anaconda.com/archive/Anaconda3-2023.03-1-Linux-x86_64.sh
bash Anaconda3-2023.03-1-Linux-x86_64.sh

conda create -n cuckoo python=3.10 && conda activate cuckoo && pip install wheel


echo -ne "
-------------------------------------------------------------------------
                            Install Cuckoo
-------------------------------------------------------------------------
"

sleep 15

sudo chown "$USER" /opt && cd /opt && git clone https://github.com/cert-ee/cuckoo3 && cd cuckoo3

./install.sh && cuckoo createcwd && cuckoo getmonitor monitor.zip && unzip signatures.zip -d ~/.cuckoocwd/signatures/cuckoo/


echo -ne "
-------------------------------------------------------------------------
                            Install/Config vmcloak
-------------------------------------------------------------------------
"

git clone https://github.com/hatching/vmcloak.git && cd vmcloak && pip install . && cd ..

sudo /home/cayub/.anaconda3/envs/cuckoo/bin/vmcloak-qemubridge br0 192.168.30.1/24

sudo mkdir -p /etc/qemu && echo 'allow br0' | sudo tee /etc/qemu/bridge.conf

sudo chmod u+s /usr/lib/qemu/qemu-bridge-helper


echo -ne "
-------------------------------------------------------------------------
                            Install/Config VM
-------------------------------------------------------------------------
"

vmcloak isodownload --win10x64 --download-to ~/win10x64.iso

sudo mkdir /mnt/win10x64 && sudo mount -o loop,ro /home/cayub/win10x64.iso /mnt/win10x64

vmcloak --debug init --win10x64 --hddsize 128 --cpus 4 --ramsize 4096 --network 192.168.30.0/24 --vm qemu --ip 192.168.30.2 --iso-mount /mnt/win10x64 win10base br0

vmcloak --debug install win10base dotnet:4.7.2 java:7u80 vcredist:2013 vcredist:2019 edge carootcert wallpaper disableservices


echo -ne "
-------------------------------------------------------------------------
            Read post-install.md in ~/Documents
-------------------------------------------------------------------------
"
