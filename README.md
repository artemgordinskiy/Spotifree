# Spotifree
Spotifree is a free OS X app that automatically detects and mutes Spotify audio ads.

[![Build Status](https://travis-ci.org/bemehiser/Spotifree.svg?branch=master)](https://travis-ci.org/bemehiser/Spotifree)

## Installing
1. Download **Spotifree** 
 - from [the website](http://spotifree.gordinskiy.com), or 
 - from the [GitHub releases page](https://github.com/ArtemGordinsky/Spotifree/releases) 
2. Move **Spotifree.app** to the **Applications** folder, run, and enjoy your ad-free music listening experience :)

On the first run, **Spotifree** will be added to the login items. From this moment, **Spotifree** will mute all **Spotify** ads it detects (usually, all of them). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## How it works
**Spotifree** is polling Spotify every **.3** seconds to see whether the current track number is 0 (as in all ads). If it is, Spotify is muted for a duration of an ad. When an ad is over, the volume is set to the way it was before.

#### Thanks
Thanks Chris Ferrara from MacRumors forums, for the original idea and the proof-of-concept script.  
Thanks [Eneas](https://github.com/E-n-e-a-s), for turning that brittle AppleScript into a robust native application.  
Thanks to all contributors for putting their time and effort into Spotifree.  
Thanks to everyone who took the time to express their gratitude in numerous heartfelt letters. That means a lot.  
Thanks [BrowserStack](https://www.browserstack.com), for generously providing me with a free "Open Source" unlimited plan, that enables me to test any website (even local one) on any device in just a couple of clicks.
