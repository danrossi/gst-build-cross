#!/bin/sh
mkdir -p /mnt/raspa64prod
#ld=$(sudo losetup -f)
#print "$ld"
ld=$(losetup -f -P --show "2024-07-04-raspios-bookworm-arm64-lite.img")
mount ${ld}p2 -o rw /mnt/raspa64prod
mount ${ld}p1 -o rw /mnt/raspa64prod/boot

cp ./configure.sh /mnt/raspa64prod/
#sudo systemd-nspawn -D /mnt/raspa64prod bin/bash ./configure.sh
systemd-nspawn -D /mnt/raspa64prod bin/bash

losetup -d $ld


umount ${ld}p1
umount ${ld}p2
