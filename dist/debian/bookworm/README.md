# GStreamer Custom Binary Build with Whepsrc plugin 

These packages are built for the purpose of using whepsrc plugins for WebRTC streaming which isn't available in Debian as a binary package.

## Installing

Inside the directory is an install script and the deb package to install. It will prepare a few depencies required.

```
./install.sh
```

## Uninstalling

```
./uninstall.sh
```

#Python 11 required for focal

A repository is required to be setup to install the latest python in Ubuntu if it doesn't have Python 11 installed already.

To check the version installed
```
python3 -V
```

To setup a repository for the latest Python.

```
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt update
sudo apt install python3.11
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.11 1
sudo update-alternatives --config python
```

#Install pipenv for the tests

