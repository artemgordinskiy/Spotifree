# Spotifree
Spotifree is a free OS X app that automatically detects and mutes Spotify audio ads.

## Installing
1. Download **Spotifree** from [the website](http://spotifree.gordinskiy.com);
2. Move **Spotifree.app** to the **Applications** folder, run, and enjoy your ad-free music listening experience :)

On the first run, **Spotifree** will be added to the login items. From this moment, **Spotifree** will mute all **Spotify** ads it detects (usually, all of them). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## How it works
**Spotifree** patches Spotify so it gets notified every time an ad starts. Then Spotify is muted as long as the ad plays. When the ad is over, the volume is set to way it was before. If there is no patch available for your Spotify version **Spotifree** polls Spotify every **.3** to detect whether an ad is playing.

#### Thanks
Thanks Chris Ferrara from MacRumors forums, for the original idea and the proof-of-concept script.  
Thanks [Eneas](https://github.com/E-n-e-a-s), for turning that brittle AppleScript into a robust native application.  
Thanks to all contributors for putting their time and effort into Spotifree.  
Thanks to everyone who took the time to express their gratitude in numerous heartfelt letters. That means a lot.  
Thanks [BrowserStack](https://www.browserstack.com), for generously providing me with a free "Open Source" unlimited plan, that enables me to test any website (even local one) on any device in just a couple of clicks.
