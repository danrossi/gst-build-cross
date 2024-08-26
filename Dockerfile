# syntax = docker/dockerfile:1.2
FROM danrossi/gstreamer/gst-rust:bookworm-slim as rustbuilder

FROM debian:bookworm-slim
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV CARGO_HTTP_DEBUG=true
ENV CARGO_LOG=cargo::ops::registry=debug
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.cargo
ENV PATH=$RUSTUP_HOME/bin:/build/scripts:$PATH
#ENV XDG_CACHE_HOME=/build/src/.cache
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
ENV RUSTFLAGS="-C codegen-units=1 -C opt-level=3 -Z threads=8 -Z thinlto"
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
WORKDIR /build
# GStreamer needs meson version >= 1.1.


RUN --mount=type=cache,id=apt-$TARGETARCH$TARGETVARIANT,sharing=locked,target=/var/cache/apt \
    echo "[+] Installing APT base system dependencies for $TARGETPLATFORM..." && \
    apt update -qq && \
    apt install -qq -y \
      --no-install-recommends \
      ccache \
      libssl-dev \
      libogg-dev \
      libpng-dev \
      libtiff-dev \
      libglib2.0-dev \
      libglib2.0-doc \
      liborc-0.4-dev-bin \
      git \
      cpio \
      build-essential \
      devscripts \
      debhelper \
      dh-sequence-python3 \
      dh-make \
      bison \
      flex \
      autotools-dev \
      automake \
      autoconf \
      libtool \
      g++ \
      binutils \
      autopoint \
      make \
      cmake \
      ninja-build \
      bison \
      flex \
      nasm \
      pkg-config \
      libxv-dev \
      libpulse-dev \
      python3 \
      python3-setuptools \
      ninja-build \
      python3-pip \
      python3-all-dev \
      libcairo2-dev \
      libogg-dev \
      libopus-dev \
      libsrt-openssl-dev \
      openssl \
      curl \
      nano && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* && \
      pip3 install \
      --break-system-packages \
      --force-reinstall \
      meson \
      pytest \
      distro

COPY --from=rustbuilder /root/.cargo /root/.cargo
COPY --from=rustbuilder /root/build/gstreamer /root/build/gstreamer
COPY scripts/deb/debian/bookworm/debian /root/build/gstreamer/debian

ENTRYPOINT /build/scripts/entrypoint.sh