# SpotiFree
SpotiFree is a tiny simple **AppleScript** application, that automatically detects and mutes Spotify's ads on OS X.

## How it works
**SpotiFree** is polling Spotify every **0.5** seconds to see if current track has **0 popularity** (as all ads do) and is  **less then 40 seconds long** (and all Spotify ads are). If it is, Spotify is paused, its volume is set to **0** and the playback is restored. When an ad is over, the volume is set to the way it was before.

## Installing
1. Download and move **SpotiFree.app** to the **Applications** folder.

## Origin
**SpotiFree** is based on the code I've [found](http://forums.macrumors.com/showthread.php?p=16033608) on MacRumors forums. Thanks to the guy named **ctferrara**!