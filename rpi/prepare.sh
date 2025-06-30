#!/bin/sh
sudo mkdir -p /mnt/raspa64prod
#ld=$(sudo losetup -f)
#print "$ld"
ld=$(sudo losetup -f -P --show "2024-07-04-raspios-bookworm-arm64-lite.img")
sudo mount ${ld}p2 -o rw /mnt/raspa64prod
sudo mount ${ld}p1 -o rw /mnt/raspa64prod/boot

sudo cp ./configure.sh /mnt/raspa64prod/
#sudo systemd-nspawn -D /mnt/raspa64prod bin/bash ./configure.sh
sudo systemd-nspawn -D /mnt/raspa64prod bin/bash

sudo losetup -d $ld


sudo umount ${ld}p1
sudo umount ${ld}p2
