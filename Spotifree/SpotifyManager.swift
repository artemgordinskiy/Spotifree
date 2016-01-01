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
    case Active
    case Muting
    case Polling
    case Inactive
}

protocol SpotifyManagerDelegate {
    func spotifreeStateChanged(state: SFSpotifreeState)
}
// Optional Functions
extension SpotifyManagerDelegate {
    func spotifreeStateChanged(state: SFSpotifreeState) {}
}

let kPatchFileURL = "https://raw.githubusercontent.com/ArtemGordinsky/Spotifree/master/Spotifree/Patches.plist"

class SpotifyManager: NSObject {
    var delegate : SpotifyManagerDelegate?
    
    private var timer : NSTimer?
    
    private let spotify = SBApplication(bundleIdentifier: "com.spotify.client") as! SpotifyApplication
    
    private var isMuted = false
    private var oldVolume = 75
    
    private var pollingMode = false
    
    private var state = SFSpotifreeState.Inactive {
        didSet {
            delegate?.spotifreeStateChanged(state)
        }
    }
    
    func start() {
        updatePatchFile()
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: "playbackStateChanged:", name: "com.spotify.client.PlaybackStateChanged", object: nil);
        
        if NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client").count != 0 && spotify.playerState! == .Playing {
            checkForAd()
            if pollingMode {
                startPolling()
            }
            state = pollingMode ? .Polling : .Active
        }
    }
    
    func playbackStateChanged(notification : NSNotification) {
        checkForAd()
        
        let playerState = notification.userInfo!["Player State"] as! String
        switch playerState {
        case "Paused", "Stopped":
            if pollingMode {stopPolling()}
            state = .Inactive
        case "Playing":
            if pollingMode {startPolling()}
            if !isMuted {
                state = pollingMode ? .Polling : .Active
            } else {
                state = .Muting
            }
        default: break
        }
    }
    
    func checkForAd() {
        let isAd = spotify.currentTrack!.spotifyUrl!.hasPrefix("spotify:ad")
        isAd ? mute() : unmute()
    }
    
    func startPolling() {
        if (timer != nil) {return}
        timer = NSTimer.scheduledTimerWithTimeInterval(DataManager.sharedData.pollingRate(), target: self, selector: "checkForAd", userInfo: nil, repeats: true)
        timer!.fire()
    }
    
    func stopPolling() {
        if let _timer = timer {
            _timer.invalidate()
            timer = nil
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
            displayNotificationWithText(String(format: NSLocalizedString("NOTIFICATION_AD_DETECTED", comment: "Notification: A Spotify ad was detected! Music will be back in about %i seconds…"), duration))
        }
        
        state = .Muting
    }
    
    func unmute() {
        if !isMuted {return}
        
        isMuted = false
        spotify.setSoundVolume!(oldVolume)
    }
    
    func displayNotificationWithText(text : String) {
        let notification = NSUserNotification()
        notification.title = "Spotifree"
        notification.informativeText = text
        notification.soundName = nil
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    
    func updatePatchFile() {
        if DataManager.sharedData.forcePolling() {
            pollingMode = true
            return
        }
        
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
                            let offset = data["offset"] as! Int
                            let replaceBytes = data["bytes"] as! [Int]
                            let length = replaceBytes.count
                            
                            let bytes = UnsafeMutablePointer<UInt8>(spotifyData.mutableBytes)
                            
                            for i in 0..<length {
                                bytes[offset + i] = UInt8(replaceBytes[i])
                            }
                        }
                        
                        spotifyData.writeToFile(spotifyFolder.stringByAppendingString("Spotify"), atomically: true)
                        
                        if let app = NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client").first {
                            let alert = NSAlert()
                            alert.messageText = NSLocalizedString("ALERT_SPOTIFY_RESTART", comment: "Alert: Spotify restart required")
                            alert.informativeText = NSLocalizedString("ALERT_SPOTIFY_RESTART_INFO", comment: "Alert info: Sorry to interrupt, but your Spotify app must be restarted to work with Spotifree. You can do it now or later, manually, if you'd rather enjoy that last McDonald's ad.")
                            alert.addButtonWithTitle(NSLocalizedString("OK", comment: "General: OK"))
                            alert.addButtonWithTitle(NSLocalizedString("ALERT_SPOTIFY_RESTART_BY_MYSELF_BUTTON", comment: "Button: I'll do it myself"))
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
            runModalQuitAlertWithText(NSLocalizedString("ALERT_SPOTIFY_NOT_FOUND", comment: "Alert: Spotify not found") , andInformativeText: NSLocalizedString("ALERT_SPOTIFY_NOT_FOUND_INFO", comment: "Alert info: Try again after installing Spotify\n(Preferably to \"/Applications/Spotify.app\")"))
        }
    }
    
    func runModalQuitAlertWithText(text : String, andInformativeText informative : String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.informativeText = informative
        let button = alert.addButtonWithTitle(NSLocalizedString("MENU_QUIT", comment: "Menu: Quit"))
        button.action = "terminate:"
        button.target = NSApplication.sharedApplication();
        alert.runModal()
    }
}