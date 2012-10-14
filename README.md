# SpotiFree
SpotiFree is a tiny simple *AppleScript* script, that automatically detects and mutes Spotify ads on OS X.

## How it works
SpotiFree is polling Spotify every .5 seconds to see if current track has *0* popularity and is  *less then 40 seconds long*. If it is, Spotify is paused, it's volume is set to *0* and playback is restored. When an ad is over, the volume is set to the way it was set before.


## Origin
SpotiFree is based on the code I've [http://forums.macrumors.com/showthread.php?p=16033608](found) on MacRumors forums.