# Docker multi arch image build for the Rust image.

Turn on containerd with Docker to support multi arch image building. 

In the General settings check `Use containerd for pulling and storing images` and restart.

https://docs.docker.com/desktop/containerd/

Then build the rust priming image with

```
./docker.sh buildrust
```

Then continue with building the gstreamer builder image with

```
./docker.sh build
```