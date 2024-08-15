#!/bin/sh
CURDIR=${1:-$HOME/build/gstreamer}
DEB_HOST_MULTIARCH=`echo $(dpkg-architecture -qDEB_HOST_MULTIARCH)`
RECONFIGURE=""
BUILDDIR=${2:-${CURDIR}/build-${DEB_HOST_MULTIARCH}}

cd ${CURDIR} && \
git pull && \
#meson subprojects update && \
meson setup \
  -Drs=enabled 
 ${BUILDDIR}