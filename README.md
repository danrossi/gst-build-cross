#Gtreamer Build Cross Environment

The purpose of this build environment which includes `gst-plugins-rs` is because GSTreamer does not compile out of the box with many points of failure. 

`gst-plugins-rs` requires Rustc for compiling which requires 16GB or more of memory to properly compile without a critical SIGINT failure in Docker. Rust is incredibly bloaty and took 4 weeks to get to a point of building these plugins. There is a bug with meson and cargo that disabling plugins doesn't work. To work around this individual plugins need to be compiled seperately so a seperate build is required.

There is poor support trying to deal with the typical build issues with GStreamer so it has to be figured out yourself. I've got it to a point where it will build out of the box without problems.

TODO: Add the RPI image build as cross compile options is too difficult to figure out and no current documentation how to do that.

In Windows a Windows command is required to turn on case sensitive to the mount path or a rust package will fail due to files being named the same. 

It attempts to build and package a custom gstreamer into a deb package which can be used for installing into a prefix of `/opt/gstreamer`

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
/build/scripts/build2.sh
```

#Packaging the build

To run a debian package build that automates the whole meson configure, install process

```
/build/scripts/build-package.sh
```

#Fixing subprojects errors

Wierd conflict errors show so subprojects may need to be purged

```
/build/scripts/purge_subprojects.sh
``