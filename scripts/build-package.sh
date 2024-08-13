#!/bin/sh

cd $HOME/build/gstreamer
debuild --preserve-envvar=PATH --preserve-envvar=CCACHE_DIR --prepend-path=/usr/lib/ccache -us -nc -uc 