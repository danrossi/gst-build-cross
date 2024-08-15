#!/bin/sh

cd $HOME/build/gstreamer && \
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
  --reconfigure \
  build-x86_64-linux-gnu && \
  ninja -C build-x86_64-linux-gnu 
  #ninja -C build-x86_64-linux-gnu && \
  #meson install --no-rebuild --only-changed -C build-x86_64-linux-gnu/ && \
  #cd subprojects/gst-plugins-rs/net/webrtchttp && \
  #LD_LIBRARY_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/subprojects/gstreamer/gst PKG_CONFIG_PATH=$HOME/build/gstreamer/build-x86_64-linux-gnu/meson-uninstalled cargo +nightly cinstall -r --prefix=/opt/gstreamer --libdir=lib --destdir=$HOME/build/gstreamer/debian/gstreamer1.0 -p gst-plugin-webrtchttp
