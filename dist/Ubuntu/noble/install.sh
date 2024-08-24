#!/bin/sh

#sudo apt install libunwind-dev libdw-dev
#sudo apt --fix-broken install
#sudo dpkg -i *.deb
sudo apt-get install -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew ./gstreamer1.0_1.25.0.1_amd64.deb