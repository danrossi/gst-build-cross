#!/bin/sh

cd $HOME/build/gstreamer/subprojects/gst-plugins-rs/net/webrtchttp

LD_LIBRARY_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/subprojects/gstreamer/gst PKG_CONFIG_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/meson-uninstalled cargo +nightly cbuild -r --prefix=/opt/gstreamer --libdir=lib --destdir=$HOME/build/gstreamer/debian/gstreamer1.0 -p gst-plugin-webrtchttp

