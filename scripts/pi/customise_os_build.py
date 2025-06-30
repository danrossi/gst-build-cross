#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Run a Raspberry PI OS image with Docker and QEMU to customise it."""
import os
import sys
import uuid
import time
import subprocess
from datetime import datetime

import pexpect



import os,sys

sys.path.insert(1, os.path.join(sys.path[0], '../../rpi-os-custom-image/'))

import customise_os
from customise_os import *


customise_os.DOCKER_IMAGE = "lukechilds/dockerpi:vm pi3"

def install_build_apt_dependencies(child):
    child.sendline("df -h")
    child.expect_exact(customise_os.BASH_PROMPT)
    child.sendline("sudo apt-get update -qq")
    child.expect_exact(customise_os.BASH_PROMPT)
    child.sendline("sudo apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl  gstreamer1.0-pulseaudio && \
    apt-get remove -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-pulseaudio && \
    apt remove -y gir1.2-gst-plugins-bad-1.0 gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0 libgstreamer* && \
    apt install -y \
      --no-install-recommends \
      binutils-aarch64-linux-gnu \
      g++-aarch64-linux-gnu \
      gcc-aarch64-linux-gnu \
      ccache \
      libssl-dev \
      libogg-dev \
      libpng-dev \
      libtiff-dev \
      libnice-dev \
      libglib2.0-dev \
      libgirepository1.0-dev \
      libglib2.0-doc \
      liborc-0.4-dev-bin \
      git \
      cpio \
      build-essential \
      devscripts \
      debhelper \
      dh-sequence-python3 \
      dh-make \
      bison \
      flex \
      autotools-dev \
      automake \
      autoconf \
      libtool \
      g++ \
      autopoint \
      make \
      cmake \
      ninja-build \
      bison \
      flex \
      nasm \
      pkg-config \
      libxv-dev \
      libpulse-dev \
      python3 \
      python3-setuptools \
      ninja-build \
      meson \
      python3-pip \
      python3-venv \
      python3-all-dev \
      libcairo2-dev \
      libogg-dev \
      libopus-dev \
      libsrt-openssl-dev \
      openssl \
      curl \
      nano && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* && \
      pip3 install \
      --break-system-packages \
      --force-reinstall \
      meson \
      pytest \
      distro")
    # Break down the install in multiple commands to kee the time per command low 
    #child.sendline("sudo apt-get install -y xvfb")
    #child.expect_exact(customise_os.BASH_PROMPT, timeout=15*60)
    #child.sendline("sudo apt-get install -y git python3-pip")
    #child.expect_exact(customise_os.BASH_PROMPT)
    #child.sendline("sudo apt-get install -y python3-pyqt5 python3-pyqt5.qtserialport")
    #child.expect_exact(customise_os.BASH_PROMPT, timeout=15*60)
    #child.sendline("sudo apt-get install -y python3-pyqt5.qsci python3-pyqt5.qtsvg")
    #child.expect_exact(customise_os.BASH_PROMPT)
    # Older versions of Raspbian might not have QtChart
    #child.sendline("sudo apt-get install -y python3-pyqt5.qtchart")
    #child.expect_exact(customise_os.BASH_PROMPT)
    #child.sendline(
    #    "sudo apt-get install -y libxmlsec1-dev libxml2 libxml2-dev libxkbcommon-x11-0 libatlas-base-dev"
    #)
    child.expect_exact(customise_os.BASH_PROMPT)
    child.sendline("df -h")
    child.expect_exact(customise_os.BASH_PROMPT)



def run_edits(img_path, img_tag=None, needs_login=True, autologin=None, ssh=None, expand_fs=None):
    print("Staring Raspberry Pi OS customisation: {}".format(img_path))

    # Since bullseye 2022-04-07 an extra step is needed to create a username and password
    set_username_password(img_path)

    # Increase the image by 1 GB using qemu-img
    if expand_fs or (expand_fs is None and EXPAND_FS):
        print("Expanding {} image +1GB:".format(img_path))
        print(pexpect.run("qemu-img resize {} +1G".format(img_path)))

    child, docker_container_name = None, None
    try:
        child, docker_container_name = launch_docker_spawn(img_path)
        if needs_login:
            login(child, img_tag)
        if autologin or (autologin is None and AUTOLOGIN):
            enable_autologin(child)
        if ssh or (ssh is None and SSH):
            enable_ssh(child, img_tag)
        if expand_fs or (expand_fs is None and EXPAND_FS):
            expand_root_fs(child, img_tag)
        
        install_build_apt_dependencies(child)
        # We are done, let's exit
        child.sendline("sudo shutdown now")
        child.expect(pexpect.EOF)
        child.wait()
    # Let ay exceptions bubble up, but ensure clean-up is run
    finally:
        if child:
            close_container(child, docker_container_name)


if __name__ == "__main__":
    # We only use the first argument to receive a path to the .img file
    run_edits(sys.argv[1])
