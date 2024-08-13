#!/bin/sh

PROJECT="gstreamer"
VERSION="1.25.0.1"
cd $HOME/build/gstreamer
dh_make --native -p ${PROJECT}_${VERSION}