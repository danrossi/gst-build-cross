#!/bin/sh

STREAM_NAME="wheptest"

gst-launch-1.0 whepsrc whep-endpoint="https://director.millicast.com/api/whep/${DOLBY_ACCOUNT}/${STREAM_NAME}" auth-token="${DOLBY_SUBSCRIBE_TOKEN}" name=whepSrc video_caps="application/x-rtp,payload=96,encoding-name=h264,media=video,packetization-mode=(string)1" audio_caps="application/x-rtp,payload=96,encoding-name=OPUS,media=audio,clock-rate=48000" use-link-headers=True ice-transport-policy=all ! decodebin ! queue ! audioconvert ! fakeaudiosink

