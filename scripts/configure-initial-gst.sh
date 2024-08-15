#!/bin/sh
BASEDIR=${1:-$HOME/build/gstreamer}
DEB_HOST_MULTIARCH=`echo $(dpkg-architecture -qDEB_HOST_MULTIARCH)`
RECONFIGURE=""
BUILDDIR=${2:-build-${DEB_HOST_MULTIARCH}}

cd ${BASEDIR} && \
git pull && \
#meson subprojects update && \
meson setup \
  -Dauto_features=disabled \
  -Drs=enabled \
 ${BUILDDIR}