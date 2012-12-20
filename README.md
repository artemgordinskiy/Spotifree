# Spotifree
Spotifree is a free OS X app that automatically detects and mutes Spotify audio ads. Hence making your music listening experience much more peaceful and enjoyable experience.

## Installing
1. Download **Spotifree** [from Google Drive](https://docs.google.com/open?id=0B-t0udcux2NUNkZFVnllejFjdGM).
2. Move the app to the **Applications** folder, run it, and enjoy your ad-free music listening experience :)

	On the first run, **Spotifree** will ask you if you want it to run automatically at login. If you agree, the app will be added to the login items. From this moment, **Spotifree** will mute all **Spotify** ads it detects (all of them, usually). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## How it works
**Spotifree** is polling Spotify every **.3** seconds to see if current track has **0 popularity** (as all ads do) and is  **less then 40 seconds long** (and all Spotify ads are). If it is, Spotify is muted for a duration of an ad. When an ad is over, the volume is set to the way it was before.



## Troubleshooting
1. Kill **SpotiFree** process (if any) using the **Activity Monitor** (Applications → Utilities → Activity Monitor);
2. Get a fresh app from the [Downloads](https://github.com/ArtemGordinsky/Spotifree/downloads) page, and install it, replacing the old one.
3. Run the app again.
4. If nothing helps, open a [new issue](https://github.com/ArtemGordinsky/Spotifree/issues) here on GitHub. I'll be glad to help you!

## Origin
**Spotifree** is based on the AppleScript script made by the Macrumors user **ctferrara**. If not for him, this app probably wouldn't have existed.
