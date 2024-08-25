#!/bin/sh

. /etc/os-release
mkdir -p /build/dist/${ID}/${VERSION_CODENAME}

cp /build/scripts/deb/debian/bookworm/debian/control $HOME/build/gstreamer/debian/ && \
cp /build/scripts/deb/debian/bookworm/debian/changelog $HOME/build/gstreamer/debian/
#echo $ID
#echo ${VERSION_CODENAME}

cd $HOME/build/gstreamer && \
build.sh &&
debuild \
--preserve-envvar=PATH \
--preserve-envvar=CCACHE_DIR \
--preserve-envvar=RUSTFLAGS \
--preserve-envvar=CARGO_HOME \
--preserve-envvar=RUSTUP_HOME \
--preserve-envvar=PYTHONPATH \
--preserve-envvar=PY_LIB_FNAME \
--prepend-path=/usr/lib/ccache -uc -us -b

cp $HOME/build/*.deb /build/dist/${ID}/${VERSION_CODENAME}/