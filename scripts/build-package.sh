#!/bin/sh

cd $HOME/build/gstreamer
debuild \
--preserve-envvar=PATH \
--preserve-envvar=CCACHE_DIR \
--preserve-envvar=RUSTFLAGS \
--preserve-envvar=CARGO_HOME \
--preserve-envvar=RUSTUP_HOME \
--prepend-path=/usr/lib/ccache -uc -us -b
