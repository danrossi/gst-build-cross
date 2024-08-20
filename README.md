# Gtreamer Build Cross Environment

The purpose of this build environment which includes `gst-plugins-rs` is because GSTreamer does not compile out of the box with many points of failure. 

`gst-plugins-rs` requires Rustc for compiling which requires 16GB or more of memory to properly compile without a critical SIGINT failure in Docker. Rust is incredibly bloaty and took 4 weeks to get to a point of building these plugins with little help of failure problems. There is a bug with meson and cargo that disabling plugins doesn't work. To work around this individual plugins need to be compiled seperately so a seperate build is required. Unless you have a machine with big resources building gst-plugin-rs in the same build as gstreamer will fail. The rest of the project uses minimal memory and cpu. C compiling is very fast and no fuss although there was many Gstreamer build failures along the way that needed wrangling.

There is poor support trying to deal with the typical build issues with GStreamer so it has to be figured out yourself. I've got it to a point where it will build out of the box without problems.

[!NOTE]
The PI Image makes use of Bulkit QEMU emulation for ARM64. Rustc and Cargoc Debian binaries can't be used as `gst-plugins-rs` requires a newer version of `cargo-cbuild`. Because Rust is so intensive and quite frankly ridiculous and a mistake and the point of taking 5 weeks to get a build system working for it. The PI image build trying to compile `cargo-c` and all it's bloaty dependancies may take hours to just build the image and still fail. Taking arm64 binaries from a pre-built image may be possible but can't find anything that has cargo-c installed.

In Windows a Windows command is required to turn on case sensitive to the mount path or a rust package will fail due to files being named the same.

```
fsutil.exe file setCaseSensitiveInfo  D:\path\to\mount
```

It attempts to build and package a custom gstreamer into a deb package stored in the `dist` directory which can be used for installing into a prefix of `/opt/gstreamer`

An initial configure of gstreamer is required first to fetch the `gst-plugins-rs` subproject. Which will then be built seperately to Gstreamer to avoid SIGINT failures.

# Building the image

```
./docker.sh build
```

# Running the build environment

```
./docker.sh run
```

```
 & ./docker.ps1  
```

See [PI Build Readme](README.pi.md) for PI Image Building.

# Run the build and package

The docker container is set to run the `/build/entrypoint.sh` script which will call `build-package` automatically. It can be commented out to get into shell to run commands manually. 

GStreamer can be manually built with this command

```
build.sh
```

# Packaging the build

To run a debian package build that automates the whole meson configure, install process.

```
build-package
```

This is run automatically from the Docker entrypoint script `entrypoint.sh` when launching a container.

Deb packages for variants and arch will be found in `/build/dist`

# Fixing subprojects errors

Wierd conflict errors show so subprojects may need to be purged

```
/build/scripts/purge_subprojects.sh
``

# Installing Package

Inside the dist directory is an install script and the deb package to install. It will prepare a few depencies required.

```
./install.sh
```