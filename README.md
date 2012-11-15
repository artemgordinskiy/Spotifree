# SpotiFree
	SpotiFree is a tiny simple **AppleScript** application, that automatically detects and mutes Spotify's ads on OS X.

## How it works
			**SpotiFree** is polling Spotify every **0.5** seconds to see if current track has **0 popularity** (as all ads do) and is  **less then 40 seconds long** (and all Spotify ads are). If it is, Spotify is paused, its volume is set to **0** and the playback is restored. When an ad is over, the volume is set to the way it was before.

## Installing
1. Download **SpotiFree** [here](https://github.com/ArtemGordinsky/SpotiFree/downloads).
2. Move the app to the **Applications** folder.
3. Run SpotiFree from your Applications folder.

	On the first run, **SpotiFree** will ask you if you want it to run automatically at login. If you agree, the app will be added to the login items. From this moment, **SpotiFree** will mute all **Spotify** ads it detects (all of them, usually). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## Troubleshooting
1. Kill **SpotiFree** process (if any) using the **Activity Monitor** (Applications → Utilities → Activity Monitor);
2. Get a fresh app from the [Downloads](https://github.com/ArtemGordinsky/SpotiFree/downloads) page, and install it, replacing the old one.
3. Run the app again.
4. If nothing helps, open a [new issue](https://github.com/ArtemGordinsky/SpotiFree/issues) here on GitHub. I'll be glad to help you!

## Origin
**SpotiFree** is based on the AppleScript script made by the Macrumors user **ctferrara**. If not for him, this app probably wouldn't have existed.