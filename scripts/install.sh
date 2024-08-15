#!/bin/sh

cd $HOME/build/gstreamer && \
  meson install --no-rebuild --only-changed -C build-x86_64-linux-gnu/ && \
  cd subprojects/gst-plugins-rs/net/webrtchttp && \
  LD_LIBRARY_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/subprojects/gstreamer/gst PKG_CONFIG_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/meson-uninstalled cargo +nightly cinstall -r --prefix=/opt/gstreamer --libdir=lib  -p gst-plugin-webrtchttp
