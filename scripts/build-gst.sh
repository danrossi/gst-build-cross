#!/bin/sh
GST_CURDIR=${1:-$HOME/build/gstreamer}
DEB_HOST_MULTIARCH=`echo $(dpkg-architecture -qDEB_HOST_MULTIARCH)`
GST_BUILDDIR=${2:-${GST_CURDIR}/build-${DEB_HOST_MULTIARCH}}

LC_ALL=C.UTF-8 ninja -j1 -v -C ${GST_BUILDDIR}