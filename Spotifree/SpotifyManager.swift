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
    case kSFSpotifreeStateMuting
    case kSFSpotifreeStatePolling
    case kSFSpotifreeStateNotPolling
}

protocol SpotifyManagerDelegate {
    func spotifreeStateChanged(state: SFSpotifreeState)
}
// Optional Functions
extension SpotifyManagerDelegate {
    func spotifreeStateChanged(state: SFSpotifreeState) {}
}

let kPatchFileURL = "https://raw.githubusercontent.com/ArtemGordinsky/Spotifree/swift/Spotifree/Patches.plist"

class SpotifyManager: NSObject {
    var delegate : SpotifyManagerDelegate?
    
    private let spotify : SpotifyApplication!
    
    private var isMuted : Bool
    private var oldVolume : Int
    
    private var pollingMode : Bool
    private var timer : NSTimer?
    
    convenience init(delegate : SpotifyManagerDelegate) {
        self.init()
        
        self.delegate = delegate
        
        if pollingMode {
            if NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client").count != 0 && spotify.playerState! == .Playing {
                startPolling()
            } else {
                self.delegate!.spotifreeStateChanged(.kSFSpotifreeStateNotPolling)
            }
        }
    }
    
    override init() {
        spotify = SBApplication(bundleIdentifier: "com.spotify.client")
        isMuted = false;
        oldVolume = 75;
        
        pollingMode = false
        
        super.init()
        
        updatePatchFile()
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "playbackStateChanged:", name: "com.spotify.client.PlaybackStateChanged", object: nil);
    }
    
    func playbackStateChanged(notification : NSNotification) {
        if pollingMode {
            let state = notification.userInfo!["Player State"] as! String
            switch state {
            case "Paused", "Stopped":
                stopPolling()
            case "Playing":
                startPolling()
            default:
                break
            }
        } else {
            checkForAd()
        }
    }
    
    func checkForAd() {
        let isAd = spotify.currentTrack!.id!().hasPrefix("spotify:ad")
        isAd ? mute() : unmute()
    }
    
    func startPolling() {
        if (timer != nil) {return}
        timer = NSTimer.scheduledTimerWithTimeInterval(DataManager.sharedData.pollingRate(), target: self, selector: "checkForAd", userInfo: nil, repeats: true)
        timer!.fire()
        delegate?.spotifreeStateChanged(.kSFSpotifreeStatePolling)
    }
    
    func stopPolling() {
        if let _timer = timer {
            _timer.invalidate()
            timer = nil
            delegate?.spotifreeStateChanged(.kSFSpotifreeStateNotPolling)
        }
    }
    
    func mute() {
        if isMuted {return}
        
        isMuted = true
        oldVolume = (spotify.soundVolume)!
        
        spotify.pause!()
        spotify.setSoundVolume!(0);
        spotify.play!()
        
        if DataManager.sharedData.shouldShowNofifications() {
            var duration = 0
            duration = spotify.currentTrack!.duration! / 1000
            displayNotificationWithText(String(format: "A Spotify ad was detected! Music will be back in about %i seconds…", duration))
        }
        
        delegate?.spotifreeStateChanged(.kSFSpotifreeStateMuting)
    }
    
    func unmute() {
        if !isMuted {return}
        
        isMuted = false
        spotify.setSoundVolume!(oldVolume)
        delegate?.spotifreeStateChanged(pollingMode ? .kSFSpotifreeStatePolling : .kSFSpotifreeStateActive)
    }
    
    func displayNotificationWithText(text : String) {
        let notification = NSUserNotification()
        notification.title = "Spotifree"
        notification.informativeText = text
        notification.soundName = nil
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func updatePatchFile() {
        fixSpotifyIfNeeded()
        let request = NSURLRequest(URL: NSURL(string: kPatchFileURL)!)
        NSURLConnection .sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if (error == nil) {
                do {
                    let localFilePath = NSBundle.mainBundle().pathForResource("Patches", ofType: "plist")!
                    let localPatchInfo = NSDictionary(contentsOfFile: localFilePath)!
                    
                    let onlinePatchInfo = try NSPropertyListSerialization.propertyListWithData(data!, options: .Immutable, format: nil) as! NSDictionary
                    
                    if (!localPatchInfo.isEqualToDictionary(onlinePatchInfo as! [NSObject : AnyObject])) {
                        onlinePatchInfo.writeToFile(localFilePath, atomically: true)
                        print("Patch data file updated")
                    }
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        
            self.fixSpotifyIfNeeded()
        }
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
                        if manager.fileExistsAtPath(backupFile) {
                            try manager.removeItemAtPath(backupFile)
                        }
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
                    } catch let error as NSError {
                        print(error.localizedDescription)
                        pollingMode = true
                    }
                }
            } else {
                pollingMode = true
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