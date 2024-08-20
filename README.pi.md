# Gtreamer Build Cross Environment PI Image

After many failed attempts to find projects that work with bookworm and arm64 for PI and not broken. I found a solution that works with Docker.



These packages may be required first. 

```
apt install systemd-container qemu-utils binfmt-support qemu-user-static
```

Linux priming with QEMU without Docker Desktop may be required. 

https://docs.docker.com/build/building/multi-platform/#qemu

This will build the required arm64 Debian Bookworm image primed with qemu-user-static and the required packages for building Gstreamer.

```
./docker.sh buildpi
```

> [!NOTE]
> Preinstalling Rust for the rust plugins seems to be causing the same SIGINT failure trying to build rust and cargo like when building with GStreamer. Reducing it's jobs and threads might help but doing this within Qemu makes it even slower and resource intensive than it already is. The layer may fail and might help breaking it up into multiple layers. Rust is problematic and extremely bloaty and resource intensive.

> [!NOTE]
> cargo-c compiling in Docker is a total failure took hours compiling its bloaty dependancies and nothing. Trying to build a builder from a rust image with actually cargo-c preinstalled as they haven't bothered doing that. Then copy over the binaries from that.

Confirmation qemu-user-static priming is working. It should show it's arm64.

```
../docker.sh checkpi
```

```
docker run  --platform linux/arm64 -it --rm danrossi/gstreamer/gst-build-cross-pi uname -m
```

Run the PI build image which will bring up an emulated shell.

```
./docker.sh runpi
```

More info 

- https://docs.docker.com/build/building/multi-platform/
- https://martin-grigorov.medium.com/building-linux-packages-for-different-cpu-architectures-with-docker-and-qemu-d29e4ebc9fa5
