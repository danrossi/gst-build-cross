#!/bin/bash

REPO="danrossi/gstreamer"
IMAGE="gst-build-cross"
IMAGE_PI="gst-build-cross-pi"
IMAGE_RUST="gst-rust"
IMAGE_UBUNTU="gst-build-cross-ubuntu"
VERSION=$(cat VERSION)
WORKDIR="/build"

DEBIAN_VARIANT="bookworm-slim"

case "$1" in
  run)
    docker run --platform linux/amd64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE}:${DEBIAN_VARIANT} /bin/bash
    #docker run -dit --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:${VERSION} /bin/bash
    ;;
  checkpi)
    docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE}:${DEBIAN_VARIANT} uname -m
    ;;
  runpi)
    docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE}:${DEBIAN_VARIANT} /bin/bash
    #docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE_PI}:${VERSION} /bin/bash
    #docker run --platform linux/arm64  -dit -v $(pwd):/build ${REPO}/${IMAGE_PI}:${VERSION} /bin/bash
    ;;
  runubuntu)
    docker run -it --platform linux/amd64 --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} --rm ${REPO}/${IMAGE}:noble /bin/bash
    #docker run -dit --platform linux/amd64 --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:noble /bin/bash
    #docker run --platform linux/amd64  -it -v $(pwd):/build  ${REPO}/${IMAGE}:noble /bin/bash
    #docker run --platform linux/amd64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE}:noble /bin/bash
    #docker run -dit --net=host -v ${PWD}:${WORKDIR}:z --workdir ${WORKDIR} ${REPO}/${IMAGE}:${VERSION} /bin/bash
    ;;
  build)
    #docker build --tag ${REPO}/${IMAGE}:${DEBIAN_VARIANT} --file Dockerfile .
    docker buildx build --platform=linux/arm64,linux/amd64 --tag ${REPO}/${IMAGE}:${DEBIAN_VARIANT}  --file Dockerfile .
    ;;
  buildubuntu)
    docker buildx build --platform=linux/amd64 --tag ${REPO}/${IMAGE}:noble --file Dockerfile.ubuntu .
    ;;
  buildrust)
    #docker build --tag ${REPO}/${IMAGE_RUST}:bookworm-slim  --file Dockerfile.rust .
    docker buildx build --platform=linux/arm64,linux/amd64 --tag ${REPO}/${IMAGE_RUST}:${DEBIAN_VARIANT}  --file Dockerfile.rust .
    ;;
  runrust)
    docker run --platform linux/amd64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE_RUST}:${DEBIAN_VARIANT} /bin/bash
    #docker run --platform linux/arm64  -it -v $(pwd):/build --rm ${REPO}/${IMAGE_RUST}:${VERSION} /bin/bash
    ;;
  *)
    echo "Usage: $0 {run|build}"
    exit 1
esac

