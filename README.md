# SpotiFree
SpotiFree is a tiny simple **AppleScript** script, that automatically detects and mutes Spotify ads on OS X.

## How it works
SpotiFree is polling Spotify every **0.5** seconds to see if current track has **0** popularity and is  **less then 40 seconds long**. If it is, Spotify is paused, its volume is set to **0** and the playback is restored. When an ad is over, the volume is set to the way it was set before.

## Installing
1. Place SpotiFree in an **Applications** folder.
2. *(autorun)* Open **SpotiFree** from your **Applications** folder and find its icon in the **Dock**. Then go into contextual menu and select **Options → Open at login** to run at login.
3. *(hiding the **Dock** icon)* Open **Terminal**, run **defaults write /Applications/SpotiFree.app/Contents/Info LSUIElement 1**. Then restart the app (you may need to **Force Quit** it).

## Origin
SpotiFree is based on the code I've [found](http://forums.macrumors.com/showthread.php?p=16033608) on MacRumors forums.