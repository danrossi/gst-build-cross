#!/bin/sh

PYTHON=${PYTHON:-/usr/bin/python3}

# Ensure pygst to be installed in current environment
LIBPYTHON=$($PYTHON -c 'from distutils import sysconfig; print(sysconfig.get_config_var("LDLIBRARY"))')
LIBPYTHONPATH=$(dirname $(ldconfig -p | grep -w $LIBPYTHON | head -1 | tr ' ' '\n' | grep /))

echo $LIBPYTHONPATH