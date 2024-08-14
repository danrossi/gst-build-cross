#!/bin/sh

#Script run from Debian rules

BUILDDIR=${1:-build-x86_64-linux-gnu}
CURDIR=${2:-$HOME/build/gstreamer}

cd ${CURDIR}/subprojects/gst-plugins-rs/net/webrtchttp

LD_LIBRARY_PATH=${CURDIR}/${BUILDDIR}/subprojects/gstreamer/gst PKG_CONFIG_PATH=${CURDIR}/${BUILDDIR}/meson-uninstalled cargo +nightly cbuild -r -p gst-plugin-webrtchttp

