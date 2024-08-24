# syntax = docker/dockerfile:1.2
FROM danrossi/gstreamer/rust:bookworm-slim as rustbuilder

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
ENV RUSTFLAGS="-Z threads=8"
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /build
# GStreamer needs meson version >= 1.1.

COPY scripts/nsswitch/nsswitch.conf /etc/nsswitch.conf

RUN --mount=type=cache,target=/var/cache/apt \
    dpkg --add-architecture arm64 && \
    apt update && \
    apt install -y  dbus-system-bus-common && \
    dpkg --configure -a && \ 
    apt install -y \
      --no-install-recommends \
      binutils-aarch64-linux-gnu \
      g++-aarch64-linux-gnu \
      gcc-aarch64-linux-gnu \
      ccache \
      libssl-dev \
      libssl-dev:arm64 \
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


ENTRYPOINT /build/scripts/entrypoint.sh