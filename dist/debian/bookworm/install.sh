#!/bin/sh


arch=$(dpkg-architecture -qDEB_HOST_ARCH)
#force new profile to be installed
sudo apt-get install -y -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confnew ./gstreamer1.0_1.25.0.1_${arch}.deb
