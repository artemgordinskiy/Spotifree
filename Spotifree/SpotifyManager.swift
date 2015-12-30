//
//  SpotifyManager.swift
//  Spotifree
//
//  Created by Eneas Rotterdam on 29.12.15.
//  Copyright © 2015 Eneas Rotterdam. All rights reserved.
//

import Cocoa
import ScriptingBridge

enum SFSpotifreeState {
    case kSFSpotifreeStateActive
    case kSFSpotifreeStateInactive
    case kSFSpotifreeStateMuting
}

protocol SpotifyManagerDelegate {
    func spotifreeStateChanged(state: SFSpotifreeState)
}
// Optional Functions
extension SpotifyManagerDelegate {
    func spotifreeStateChanged(state: SFSpotifreeState) {}
}

class SpotifyManager: NSObject {
    var delegate : SpotifyManagerDelegate?
    
    private let spotify : SpotifyApplication?
    
    private var isMuted : Bool
    private var oldVolume : Int
    
    override init() {
        spotify = SBApplication(bundleIdentifier: "com.spotify.client")
        isMuted = false;
        oldVolume = 75;
        
        super.init()
        
        fixSpotifyIfNeeded()
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "playbackStateChanged", name: "com.spotify.client.PlaybackStateChanged", object: nil);
    }
    
    func playbackStateChanged() {
        checkForAd()
    }
    
    func checkForAd() {
        if let isAd = spotify?.currentTrack!.id!().hasPrefix("spotify:ad") {
            isAd ? mute() : unmute()
        }
    }
    
    func mute() {
        if isMuted {return}
        
        isMuted = true
        oldVolume = (spotify?.soundVolume)!
        
        spotify?.pause!()
        spotify?.setSoundVolume!(0);
        spotify?.play!()
        
        if DataManager.sharedData.shouldShowNofifications() {
            var duration = 0
            duration = (spotify?.currentTrack!.duration)! / 1000
            displayNotificationWithText(String(format: "A Spotify ad was detected! Music will be back in about %i seconds…", duration))
        }
        
        delegate?.spotifreeStateChanged(.kSFSpotifreeStateMuting)
    }
    
    func unmute() {
        if !isMuted {return}
        
        isMuted = false
        spotify?.setSoundVolume!(oldVolume)
        delegate?.spotifreeStateChanged(.kSFSpotifreeStateActive)
    }
    
    func displayNotificationWithText(text : String) {
        let notification = NSUserNotification()
        notification.title = "Spotifree"
        notification.informativeText = text
        notification.soundName = nil
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func fixSpotifyIfNeeded() {
        if let spotifyFolder = NSWorkspace.sharedWorkspace().absolutePathForAppBundleWithIdentifier("com.spotify.client")?.stringByAppendingString("/Contents/MacOS/") {
            let originalFile = spotifyFolder.stringByAppendingString("Spotify")
            
            let patches = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("Patches", ofType: "plist")!)
            let md5hash = NSData(contentsOfFile: originalFile)!.MD5().hexString()
            
            if let currentPatch = patches?[md5hash] {
                if currentPatch["patched"] as! Bool == false {
                    do {
                        let manager = NSFileManager.defaultManager()
                        let backupFile = spotifyFolder.stringByAppendingString("SpotifyBackup")
                        try manager.copyItemAtPath(originalFile, toPath: backupFile)
                        
                        let spotifyData = NSMutableData(contentsOfFile: originalFile)!
                        
                        let patchData = currentPatch["patchData"] as! [NSDictionary]
                        for data in patchData {
                            let location = data["location"] as! Int
                            let bytes = data["bytes"] as! [Int]
                            let length = bytes.count
                            let range = NSRange(location: location, length: length)
                            
                            let byteArray = UnsafeMutablePointer<UInt8>.alloc(length)
                            for i in 0..<length {
                                let index = UInt8(bytes[i])
                                byteArray[i] = index
                            }
                            
                            spotifyData.replaceBytesInRange(range, withBytes: byteArray)
                            byteArray.dealloc(length)
                        }
                        
                        spotifyData.writeToFile(spotifyFolder.stringByAppendingString("Spotify"), atomically: true)
                        
                        if let app = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client").first {
                            let alert = NSAlert()
                            alert.messageText = "Spotify restart required"
                            alert.informativeText = "Sorry to interrupt, but your Spotify app must be restarted to work with Spotifree. You can do it now or later, manually, if you'd rather enjoy that last McDonald's ad."
                            alert.addButtonWithTitle("OK")
                            alert.addButtonWithTitle("I'll do it myself")
                            if NSAlertFirstButtonReturn == alert.runModal() {
                                app.terminate()
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), {
                                    NSWorkspace.sharedWorkspace().launchApplication("Spotify")
                                });
                            }
                        }
                    } catch {
                        runModalQuitAlertWithText("Something went wrong patching Spotify", andInformativeText: "Sometimes restarting Spotify helps")
                    }
                }
            } else {
                runModalQuitAlertWithText("Spotify version not supported", andInformativeText: "")
            }
        } else {
            runModalQuitAlertWithText("Spotify not found" , andInformativeText: "Try again after installing Spotify\n(Preferably to \"/Applications/Spotify.app\")")
        }
    }
    
    func runModalQuitAlertWithText(text : String, andInformativeText informative : String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = informative
        let button = alert.addButtonWithTitle("Quit")
        button.action = "terminate:"
        button.target = NSApplication.sharedApplication();
        alert.runModal()
    }
}