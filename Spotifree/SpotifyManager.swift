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
    case Inactive
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
    
    private var timer : NSTimer?
    
    private let spotify = SBApplication(bundleIdentifier: "com.spotify.client") as! SpotifyApplication
    
    private var isMuted = false
    private var oldVolume = 75
    
    private var state = SFSpotifreeState.Inactive {
        didSet {
            delegate?.spotifreeStateChanged(state)
        }
    }
    
    func start() {
        NSDistributedNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SpotifyManager.playbackStateChanged(_:)), name: "com.spotify.client.PlaybackStateChanged", object: nil);
        
        if NSRunningApplication.runningApplicationsWithBundleIdentifier("com.spotify.client").count != 0 && spotify.playerState! == .Playing {
            startPolling()
        }
    }
    
    func playbackStateChanged(notification : NSNotification) {
        let playerState = notification.userInfo!["Player State"] as! String
        switch playerState {
        case "Stopped":
            state = .Inactive
            fallthrough
        case "Paused":
            stopPolling()
        case "Playing":
            startPolling()
        case _: break
        }
    }
    
    func checkForAd() {
        let currentTrack = spotify.currentTrack!
        let isAd = currentTrack.trackNumber! == 0 && !currentTrack.spotifyUrl!.hasPrefix("spotify:local")
        isAd ? mute() : unmute()
    }
    
    func startPolling() {
        if (timer != nil) {return}
        timer = NSTimer.scheduledTimerWithTimeInterval(DataManager.sharedData.pollingRate(), target: self, selector: #selector(SpotifyManager.checkForAd), userInfo: nil, repeats: true)
        timer!.fire()
        
        state = .Active
    }
    
    func stopPolling() {
        if let timer = timer {
            timer.invalidate()
            self.timer = nil
            state = isMuted ? .Muting : .Inactive
        }
    }
    
    func mute() {
        if isMuted {return}
        
        isMuted = true
        oldVolume = (spotify.soundVolume)!
        
        stopPolling()
        
        spotify.pause!()
        spotify.setSoundVolume!(0);
        spotify.play!()
        
        if DataManager.sharedData.shouldShowNofifications() {
            var duration = 0
            duration = spotify.currentTrack!.duration! / 1000
            displayNotificationWithText(String(format: NSLocalizedString("NOTIFICATION_AD_DETECTED", comment: "Notification: A Spotify ad was detected! Music will be back in about %i seconds…"), duration))
        }
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
}
