#!/bin/sh
CONF_BASEDIR=${1:-$HOME/build/gstreamer}
DEB_HOST_MULTIARCH=`echo $(dpkg-architecture -qDEB_HOST_MULTIARCH)`
CONF_BUILDDIR=${2:-build-${DEB_HOST_MULTIARCH}}

cd ${CONF_BASEDIR} && \
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
  -Dintrospection=enabled \
  -Dpython=enabled \
  -Dgpl=enabled \
  -Drs=enabled \
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
  -Dgst-plugins-rs:audiofx=disabled \
  -Dgst-plugins-rs:claxon=disabled \
  -Dgst-plugins-rs:audiofx=disabled \
  -Dgst-plugins-rs:csound=disabled \
  -Dgst-plugins-rs:lewton=disabled \
  -Dgst-plugins-rs:spotify=disabled \
  -Dgst-plugins-rs:speechmatics=disabled \
  -Dgst-plugins-rs:file=disabled \
  -Dgst-plugins-rs:originalbuffer=disabled \
  -Dgst-plugins-rs:gopbuffer=disabled \
  -Dgst-plugins-rs:sodium=disabled \
  -Dgst-plugins-rs:threadshare=disabled \
  -Dgst-plugins-rs:inter=disabled \
  -Dgst-plugins-rs:cdg=disabled \
  -Dgst-plugins-rs:closedcaption=disabled \
  -Dgst-plugins-rs:dav1d=disabled \
  -Dgst-plugins-rs:ffv1=disabled \
  -Dgst-plugins-rs:gif=disabled \
  -Dgst-plugins-rs:gtk4=disabled \
  -Dgst-plugins-rs:hsv=disabled \
  -Dgst-plugins-rs:png=disabled \
  -Dgst-plugins-rs:rav1e=disabled \
  -Dgst-plugins-rs:videofx=disabled \
  -Dgst-plugins-rs:webp=disabled \
  -Dgst-plugins-rs:textahead=disabled \
  -Dgst-plugins-rs:json=disabled \
  -Dgst-plugins-rs:regex=disabled \
  -Dgst-plugins-rs:textwrap=disabled \
  -Dgst-plugins-rs:fallbackswitch=disabled \
  -Dgst-plugins-rs:livesync=disabled \
  -Dgst-plugins-rs:togglerecord=disabled \
  -Dgst-plugins-rs:tracers=disabled \
  -Dgst-plugins-rs:uriplaylistbin=disabled \
  -Dgst-plugins-rs:aws=disabled \
  -Dgst-plugins-rs:hlssink3=disabled \
  -Dgst-plugins-rs:mpegtslive=disabled \
  -Dgst-plugins-rs:ndi=disabled \
  -Dgst-plugins-rs:onvif=disabled \
  -Dgst-plugins-rs:raptorq=disabled \
  -Dgst-plugins-rs:reqwest=disabled \
  -Dgst-plugins-rs:rtsp=disabled \
  -Dgst-plugins-rs:webrtc=disabled \
  -Dgst-plugins-rs:quinn=disabled \
  -Dgst-plugins-rs:flavors=disabled \
  -Dgst-plugins-rs:fmp4=disabled \
  -Dgst-plugins-rs:mp4=disabled \
 ${CONF_BUILDDIR}
