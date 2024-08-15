#!/bin/sh

#Script run from Debian rules
RS_BUILDDIR=${1:-build-x86_64-linux-gnu}
RS_DESTDIR=${2:-$HOME/build/gstreamer/debian/gstreamer1.0}
RS_CURDIR=${3:-$HOME/build/gstreamer}

cd ${RS_CURDIR}/subprojects/gst-plugins-rs/net/webrtchttp

LD_LIBRARY_PATH=${RS_CURDIR}/${RS_BUILDDIR}/subprojects/gstreamer/gst:${LD_LIBRARY_PATH} PKG_CONFIG_PATH=${RS_CURDIR}/${RS_BUILDDIR}/meson-uninstalled:${PKG_CONFIG_PATH} cargo +nightly cinstall -r --prefix=/opt/gstreamer --libdir=lib --destdir=${RS_DESTDIR} -v -p gst-plugin-webrtchttp

