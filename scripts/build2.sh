#!/bin/sh

cd $HOME/build/gstreamer && \
git pull && \
meson subprojects update && \
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
  --reconfigure \
  build-x86_64-linux-gnu && \
  
  ninja -C build-x86_64-linux-gnu 
  #ninja -C build-x86_64-linux-gnu && \
  #meson install --no-rebuild --only-changed -C build-x86_64-linux-gnu/ && \
  #cd ../gst-plugins-rs && \
  #LD_LIBRARY_PATH=/opt/gstreamer/lib PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/opt/gstreamer/lib/pkgconfig:$PKG_CONFIG_PATH cargo cinstall --prefix=/opt/gstreamer --libdir=lib -p gst-plugin-webrtchttp

  #tar -zcf /build/dist/gstreamer.tar.gz /opt/gstreamer