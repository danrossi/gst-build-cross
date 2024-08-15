#!/bin/sh
CURDIR=${1:-$HOME/build/gstreamer}
DEB_HOST_MULTIARCH=`echo $(dpkg-architecture -qDEB_HOST_MULTIARCH)`
RECONFIGURE=""
BUILDDIR=${2:-${CURDIR}/build-${DEB_HOST_MULTIARCH}}


if [ -d ${BUILDDIR} ]; then RECONFIGURE=" --reconfigure"; fi

cd ${CURDIR} && \
git pull && \
#meson subprojects update && \
meson setup \
  --buildtype=release \
  --strip \
  --pkgconfig.relocatable \
  --prefix=/opt/gstreamer \
  -Dlibdir=lib \
  -Dgst-full-libraries=app,video,player \
  -Dgst-examples=disabled\
  -Dwebrtc=enabled \
  -Drtsp_server=disabled \
  -Dlibav=disabled \
  -Dges=disabled \
  -Dpython=enabled \
  -Dgpl=enabled \
  -Drs=disabled \
  -Dqt5=disabled \
  -Dqt6=disabled \
  -Dtests=disabled \
  -Dgtk_doc=disabled \
  -Dgstreamer:examples=disabled \
  -Dgstreamer:tests=disabled \
  -Dgstreamer:doc=disabled \
  -Dgst-plugins-base:examples=disabled \
  -Dgst-plugins-bad:magicleap=disabled \
  -Dgst-plugins-bad:examples=disabled \
  -Dgst-plugins-good:examples=disabled \
  -Dorc:orc-test=disabled \
  -Dorc:examples=disabled \
  -Dorc:gtk_doc=disabled \
  -Dorc:tests=disabled \
  -Dgst-python:libpython-dir=lib/x86_64-linux-gnu \
  --reconfigure \
 ${BUILDDIR}