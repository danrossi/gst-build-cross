# Streaming Tests

Provided is a two whepsrc test scripts to test using `gst-launch-1.0` or python.

This is configured to stream from Dolby.io as a WebRTC whepsrc.

Environment variables are required to be set for the account id and a subscribe token

```
export DOLBY_ACCOUNT=""
export DOLBY_SUBSCRIBE_TOKEN=""
```

Run the scripts like so

```
./whep.sh
```
```
./whep.py
```
