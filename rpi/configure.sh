#!/bin/sh

apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl  gstreamer1.0-pulseaudio && \
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
      distro