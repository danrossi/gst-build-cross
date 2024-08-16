#Gtreamer Build Cross Environment

The purpose of this build environment which includes `gst-plugins-rs` is because GSTreamer does not compile out of the box with many points of failure. 

`gst-plugins-rs` requires Rustc for compiling which requires 16GB or more of memory to properly compile without a critical SIGINT failure in Docker. Rust is incredibly bloaty and took 4 weeks to get to a point of building these plugins with little help of failure problems. There is a bug with meson and cargo that disabling plugins doesn't work. To work around this individual plugins need to be compiled seperately so a seperate build is required. Unless you have a machine with big resources building gst-plugin-rs in the same build as gstreamer will fail. The rest of the project uses minimal memory and cpu.

There is poor support trying to deal with the typical build issues with GStreamer so it has to be figured out yourself. I've got it to a point where it will build out of the box without problems.

TODO: Add the RPI image build as cross compile options is too difficult to figure out and no current documentation how to do that.

In Windows a Windows command is required to turn on case sensitive to the mount path or a rust package will fail due to files being named the same.

```
fsutil.exe file setCaseSensitiveInfo  D:\path\to\mount
```

It attempts to build and package a custom gstreamer into a deb package which can be used for installing into a prefix of `/opt/gstreamer`

An initial build of gstreamer is required first while creating the Docker image or pychairo complains about missing libpython links during a deb package build. Which is in the standard lib location. It's possibly stripping more environment variables.

#Building the image

```
./docker.sh build
```

#Running the build environment

```
./docker.sh run
```

```
 & ./docker.ps1  
```

#Run the build

For now in docker it can be manually built with this command

```
build.sh
```

#Packaging the build

To run a debian package build that automates the whole meson configure, install process.

```
build-package
```

This is run automatically from the Docker entrypoint script `entrypoint.sh` when launching a container.

#Fixing subprojects errors

Wierd conflict errors show so subprojects may need to be purged

```
/build/scripts/purge_subprojects.sh
``

#Installing Package

Inside the dist directory is an install script and the deb package to install. It will prepare a few depencies required.

```
./install.sh
```