#!/bin/bash

REPO="danrossi/gstreamer"
IMAGE="gst-build-cross"
IMAGE_PI="gst-build-cross-pi"
VERSION=$(cat VERSION)
WORKDIR="/build"

case "$1" in
  run)
    docker run -dit --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:${VERSION} /bin/bash
    ;;
  build)
    docker build --tag ${REPO}/${IMAGE}:${VERSION} --file Dockerfile .
    ;;
  buildpi)
    docker build --tag ${REPO}/${IMAGE_PI}:${VERSION} --file Dockerfile.pi .
    ;;
  *)
    echo "Usage: $0 {run|build}"
    exit 1
esac

