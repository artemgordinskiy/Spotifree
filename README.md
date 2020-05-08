# Spotifree (DISCONTINUED)
Spotifree is a free OS X app that automatically detects and mutes Spotify audio ads.

## Installing
1. Download **Spotifree** from [the website](http://spotifree.gordinskiy.com);
2. Move **Spotifree.app** to the **Applications** folder, run, and enjoy your ad-free music listening experience :)

On the first run, **Spotifree** will be added to the login items. From this moment, **Spotifree** will mute all **Spotify** ads it detects (usually, all of them). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## How it works
**Spotifree** is polling Spotify every **.3** seconds to see whether the current track number is 0 (as in all ads). If it is, Spotify is muted for a duration of an ad. When an ad is over, the volume is set to the way it was before.

#### Alternatives
[MuteSpotifyAds](https://github.com/simonmeusel/MuteSpotifyAds) by [Simon Meusel](https://github.com/simonmeusel) is a good alternative if Spotifree does not work for you.


#### Thanks
Thanks Chris Ferrara from MacRumors forums, for the original idea and the proof-of-concept script.  
Thanks [Eneas](https://github.com/E-n-e-a-s), for turning that brittle AppleScript into a robust native application.  
Thanks to all other contributors for helping make Spotifree better.
