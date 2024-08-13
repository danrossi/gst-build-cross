#!/bin/sh

export GST_ENV=1.0
export GST_PLUGIN_PATH=/opt/gstreamer/lib/gstreamer-1.0
export GST_VALIDATE_SCENARIOS_PATH=/opt/gstreamer/share/gstreamer-1.0/validate/scenarios
export GI_TYPELIB_PATH=/opt/gstreamer/lib/girepository-1.0
export PKG_CONFIG_PATH=/opt/gstreamer/lib/pkgconfig:$PKG_CONFIG_PATH
export LD_LIBRARY_PATH=/opt/gstreamer/lib:$LD_LIBRARY_PATH
export PYTHONPATH=/opt/gstreamer/lib/python3/dist-packages:$PYTHONPATH
export _GI_OVERRIDES_PATH=/opt/gstreamer/lib/python3/dist-packages/gi/overrides
export PATH=/opt/gstreamer/bin:$PATH