#!/bin/sh
CURDIR=${1:-$HOME/build/gstreamer}
DEB_HOST_MULTIARCH=`echo $(dpkg-architecture -qDEB_HOST_MULTIARCH)`
BUILDDIR=${2:-${CURDIR}/build-${DEB_HOST_MULTIARCH}}

LC_ALL=C.UTF-8 ninja -j1 -v -C ${BUILDDIR}