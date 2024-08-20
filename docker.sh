#!/bin/bash

REPO="danrossi/gstreamer"
IMAGE="gst-build-cross"
IMAGE_PI="gst-build-cross-pi"
IMAGE_RUST="rust"
IMAGE_UBUNTU="gst-build-cross-ubuntu"
VERSION=$(cat VERSION)
WORKDIR="/build"

case "$1" in
  run)
    docker run -dit --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:${VERSION} /bin/bash
    ;;
  checkpi)
    docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE_PI}:${VERSION} uname -m
    ;;
  runpi)
    docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE_PI}:${VERSION} /bin/bash
    ;;
  build)
    docker build --tag ${REPO}/${IMAGE}:${VERSION} --file Dockerfile .
    ;;
  buildubuntu)
    docker build --tag ${REPO}/${IMAGE_UBUNTU}:${VERSION} --file Dockerfile.ubuntu .
    ;;
  buildpi)
    docker build --platform=linux/arm64 --tag ${REPO}/${IMAGE_PI}:${VERSION}  --file Dockerfile.pi .
    #docker buildx build --platform=linux/arm64 --tag ${REPO}/${IMAGE_PI}:${VERSION}  --file Dockerfile.pi .
    ;;
  buildrust)
    docker build --platform=linux/arm64 --tag ${REPO}/${IMAGE_RUST}:${VERSION}  --file Dockerfile.rust .
    #docker buildx build --platform=linux/arm64 --tag ${REPO}/${IMAGE_PI}:${VERSION}  --file Dockerfile.pi .
    ;;
  runrust)
    docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE_RUST}:${VERSION} /bin/bash
    ;;
  *)
    echo "Usage: $0 {run|build}"
    exit 1
esac

