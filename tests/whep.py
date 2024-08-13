#!/usr/bin/env python3
import signal
import sys
import os
import gi# type: ignore
gi.require_version("GLib","2.0")
gi.require_version("Gst","1.0")
from gi.repository import GLib, Gst# type: ignore

Gst.init(None)

ACCOUNT_ID=os.environ['DOLBY_ACCOUNT']
STREAM_NAME="wheptest"

DOLBYIO_ENDPOINT="https://director.millicast.com/api/whep/{0}/{1}".format(ACCOUNT_ID, STREAM_NAME)

TOKEN=os.environ['DOLBY_SUBSCRIBE_TOKEN']

#audio_sink="fakeaudiosink"
audio_sink="autoaudiosink"
#audio_sink="directsoundsink"
#"autoaudiosink"

glibMainLoop: GLib.MainLoop=None
pipe: Gst.Element=None
bus: Gst.Bus=None
def log(*args):
    print(*args,file=sys.stderr)
          
def busMessage(_bus: Gst.Bus, message: Gst.Message, loop: GLib.MainLoop)-> bool:
    t=message.type
    
    if t==Gst.MessageType.EOS:
        log("End of stream. Shutting down pipeline.")
        loop.quit()
    elif t==Gst.MessageType.ERROR:
        err, debug=message.parse_error()
        debug=f"{err}: {debug}"
        log("Pipeline error: ", err, debug)
        glibMainLoop.quit()
    return True

def debugDumpPipeline(phase:str)-> None:
    Gst.debug_bin_to_dot_file_with_ts(
        pipe, Gst.DebugGraphDetails.VERBOSE,"gst-whep-" + phase
    )

def handleMediaStream(pad: Gst.Pad, is_video: bool)-> None:
    queue: Gst.Element=Gst.ElementFactory.make("queue")
    convert: Gst.Element=Gst.ElementFactory.make("videoconvert"if is_video else "audioconvert")
    sink: Gst.Element=Gst.ElementFactory.make("autovideosink"if is_video else audio_sink)

    pipe.add(queue)
    pipe.add(convert)
    pipe.add(sink)

    queue.link(convert)
    convert.link(sink)

    queue.sync_state_with_parent()
    convert.sync_state_with_parent()
    sink.sync_state_with_parent()

    sinkPad: Gst.Pad=queue.get_static_pad("sink")
    pad.link(sinkPad)


def decodeBinPadAdded(_dbin: Gst.Element, pad: Gst.Pad)->None:
    caps: Gst.Caps=pad.get_current_caps()
    s=caps.get_structure(0)
    name=s.get_name()

    if name.startswith("video"):
        handleMediaStream(pad,True)
        debugDumpPipeline("video")
    elif name.startswith("audio"):
        handleMediaStream(pad,False)
        debugDumpPipeline("audio")
    else:
        return


def whepSrcPadAdded(_dbin: Gst.Element, pad: Gst.Pad)->None:
    decodeBin=Gst.ElementFactory.make("decodebin")
    decodeBin.connect("pad-added", decodeBinPadAdded)

    pipe.add(decodeBin)

    decodeBin.sync_state_with_parent()

    sinkPad: Gst.Pad=decodeBin.get_static_pad("sink")
    linked=pad.link(sinkPad)
    log("Linked decodebin to WHEP src pad ", pad.name, linked)


def setupWHEPPipeline()->None:
    global bus
    global pipe

    pipe=Gst.Pipeline.new()

    whepSrc: Gst.Element=Gst.ElementFactory.make("whepsrc")

    whepSrc.set_property("use-link-headers",True)
    whepSrc.set_property("ice-transport-policy","all")
    #whepSrc.set_property("stun-server", "")
    #whepSrc.set_property("turn-server", "")

    if (TOKEN is not None):
        whepSrc.set_property("auth-token", TOKEN)

    whepSrc.set_property("whep-endpoint", DOLBYIO_ENDPOINT)
    audio_caps = Gst.caps_from_string("application/x-rtp,payload=96,encoding-name=OPUS,media=audio,clock-rate=48000")
    video_caps = Gst.caps_from_string("application/x-rtp,payload=101,encoding-name=VP8,media=video,clock-rate=90000")

    #audio_caps=Gst.caps_from_string("")
    #video_caps=Gst.caps_from_string("application/x-rtp,payload=101,encoding-name=VP8,media=video,clock-rate=90000")

    whepSrc.set_property("audio-caps", audio_caps)
    whepSrc.set_property("video-caps", video_caps)

    pipe.add(whepSrc)

    whepSrc.connect("pad-added", whepSrcPadAdded)

    bus=pipe.get_bus()
    bus.add_watch(GLib.PRIORITY_DEFAULT, busMessage, glibMainLoop)


def sigintHandler(_signum, _frame):
    log("Sending EOS to pipeline")
    pipe.send_event(Gst.Event.new_eos())


def main(_args)->int:
    global bus
    global glibMainLoop
    global pipe

    glibMainLoop=GLib.MainLoop()

    setupWHEPPipeline()

    signal.signal(signal.SIGINT, sigintHandler)

    ret=pipe.set_state(Gst.State.PLAYING)

    if ret==Gst.StateChangeReturn.FAILURE:
        log("Failed to set pipeline in PLAYING state")
        return-1

    glibMainLoop.run()

    pipe.set_state(Gst.State.NULL)

    log("Exited GLib main loop")

    bus.remove_watch()

    pipe=None
    bus=None

    Gst.deinit()

    return 0


if __name__=="__main__":
    sys.exit(main(sys.argv))
