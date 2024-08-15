#!/bin/sh

cd $HOME/build/gstreamer &&
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

cp $HOME/build/*.deb /build/dist/
cp $HOME/build/*.dsc /build/dist/