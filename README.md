# Spotifree
Spotifree is a free OS X app that automatically detects and mutes Spotify audio ads.

## Installing
1. Download **Spotifree** from [the website](http://spotifree.gordinskiy.com);
2. Move **Spotifree.app** to the **Applications** folder, run, and enjoy your ad-free music listening experience :)

	On the first run, **Spotifree** will ask you if you want it to run automatically at login. If you agree, the app will be added to the login items. From this moment, **Spotifree** will mute all **Spotify** ads it detects (usually, all of them). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## How it works
**Spotifree** is polling Spotify every **.3** seconds to see if current track has **0 popularity** (as all ads do) and is  **40 seconds or less in length** (and all Spotify ads are). If it is, Spotify is muted for a duration of an ad. When an ad is over, the volume is set to the way it was before.

## Troubleshooting
1. Kill **SpotiFree** process (if any) using the **Activity Monitor** (Applications → Utilities → Activity Monitor);
2. Get a fresh app from the [website](http://Spotifree.gordinskiy.com). Then install it, replacing the old one.
3. Run the app again.
4. If nothing helps, [send me a message](http://Spotifree.gordinskiy.com/contact.html).

## Origin
Based on a clever AppleScript script by Chris Ferrara.
