#!/bin/sh


arch=$(dpkg-architecture -qDEB_HOST_ARCH)
sudo apt-get install ./gstreamer1.0_1.25.0.1_${arch}.deb