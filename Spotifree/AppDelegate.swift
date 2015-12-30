//
//  AppDelegate.swift
//  Spotifree
//
//  Created by Eneas Rotterdam on 29.12.15.
//  Copyright © 2015 Eneas Rotterdam. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var menuController : MenuController!
    var spotifyManger : SpotifyManager!

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        spotifyManger = SpotifyManager()
        menuController = MenuController()
        spotifyManger.delegate = menuController
    }

    func applicationShouldHandleReopen(sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        menuController.showMenuBarIconIfNeeded()
        return true
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }


}

