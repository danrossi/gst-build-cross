# syntax = docker/dockerfile:1.2
FROM debian:bookworm-slim
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV CARGO_HTTP_DEBUG=true
ENV CARGO_LOG=cargo::ops::registry=debug
ENV CARGO_HOME=/root/.cargo
ENV RUSTUP_HOME=/root/.cargo
ENV PATH=$RUSTUP_HOME/bin:$PATH
ENV XDG_CACHE_HOME=/build/src/.cache
ENV CARGO_REGISTRIES_CRATES_IO_PROTOCOL=sparse
ENV RUSTFLAGS="-Z threads=8 -C linker=x86_64-linux-gnu-gcc"
ENV CARGO_NET_GIT_FETCH_WITH_CLI=true
#ENV PKG_CONFIG_PATH=/usr/lib/x86_64-linux-gnu/pkgconfig:/opt/gstreamer/lib/pkgconfig:$PKG_CONFIG_PATH
#ENV NSS_UNKNOWN_HOME=/home/user
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /build
# GStreamer needs meson version >= 1.1.
#$RUN groupadd -r builduser && useradd -r -g builduser builduser

COPY scripts/nsswitch/nsswitch.conf /etc/nsswitch.conf

RUN --mount=type=cache,target=/var/cache/apt \
    dpkg --add-architecture arm64 && \
    apt update && \
    apt install -y  dbus-system-bus-common && \
    dpkg --configure -a && \ 
    apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl  gstreamer1.0-pulseaudio && \
    apt-get remove -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-pulseaudio && \
    apt remove -y gir1.2-gst-plugins-bad-1.0 gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0 libgstreamer* && \
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
      libnice-dev \
      libglib2.0-dev \
      libgirepository1.0-dev \
      libglib2.0-doc \
      liborc-0.4-dev-bin \
      git \
      cpio \
      build-essential \
      debhelper \
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
      meson \
      python3-pip \
      python3-venv \
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
      meson \
      pytest \
      distro

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal --target x86_64-unknown-linux-gnu && \
rustup toolchain install nightly && \
rustup default nightly && \
cargo +nightly install cargo-c && \
cargo +nightly install cargo-deb && \
#echo "alias cargo=\"RUSTFLAGS='-Z threads=8' cargo +nightly\"" >> $HOME/.bashrc && \
echo "alias cargo=\"cargo +nightly\"" >> $HOME/.bashrc && \
printf "[net]\ngit-fetch-with-cli = true" >> "$CARGO_HOME/config.toml" && \
printf "\n[build]\njobs = 4" >> "$CARGO_HOME/config.toml"

COPY scripts/gst-plugins-rs/Cargo.toml.deb /tmp/

RUN mkdir $HOME/build && \
    cd $HOME/build && \
      git clone https://gitlab.freedesktop.org/gstreamer/gstreamer.git gstreamer && \
      cd gstreamer && \ 
      meson wrap install openssl && \
      meson subprojects download && \
      meson subprojects update &&
      cat tmp/Cargo.toml.deb >> subprojects/gst-plugins-rs/net/webrtchttp/Cargo.toml &&
      rm tmp/Cargo.toml.deb
      #cd $HOME/build && \
      #git clone https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs.git gst-plugins-rs



  
  ENTRYPOINT /build/scripts/build.sh