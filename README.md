# Spotifree
Spotifree is a free OS X app that automatically detects and mutes Spotify audio ads.

## Installing
1. Download **Spotifree** from [the website](http://spotifree.gordinskiy.com);
2. Move **Spotifree.app** to the **Applications** folder, run, and enjoy your ad-free music listening experience :)

On the first run, **Spotifree** will ask you if you want it to run automatically at login. If you agree, the app will be added to the login items. From this moment, **Spotifree** will mute all **Spotify** ads it detects (usually, all of them). Don't worry though, it will not impact your Mac's performance and you'll never notice it running.

## How it works
**Spotifree** is polling Spotify every **.3** seconds to see if current track has a **track number of 0** (as all ads do). If it is, Spotify is muted for a duration of an ad. When an ad is over, the volume is set to the way it was before.

## Building
The first build may take a while because the **Sparkle Framework** will be downloaded automatically by this run script:

```sh
#Check whether Sparkle.framework exists
if [ ! -d "$SRCROOT/Sparkle.framework/" ]; then
    
    #Download
    echo "Downloading Sparkle. This may take a while."
    curl --silent "http://sparkle.andymatuschak.org/files/Sparkle%201.5b6.zip" > "$SRCROOT/Sparkle.zip"

    #Organize
    unzip -q "$SRCROOT/Sparkle.zip" -d "$SRCROOT/Sparkle/"
    mv "$SRCROOT/Sparkle/Sparkle.framework" "$SRCROOT/Sparkle.framework"

    #Cleanup
    rm -rf "$SRCROOT/Sparkle/"
    rm "$SRCROOT/Sparkle.zip"
    echo "Done"

fi
```

If this doesn't work for you, do it manually:

1. Download **Sparkle** from [the website](http://sparkle.andymatuschak.org).
2. Go to the unzipped **Sparkle** folder.
3. Copy "Sparkle.framework" to your project folder.
4. Done. You can now build the app in **Xcode**.