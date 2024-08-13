#!/bin/sh


cd $HOME/build/gstreamer/subprojects/gst-plugins-rs/net/webrtchttp

LD_LIBRARY_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/subprojects/gstreamer/gst PKG_CONFIG_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/meson-uninstalled cargo cbuild --prefix=/opt/gstreamer --libdir=lib -p gst-plugin-webrtchttp