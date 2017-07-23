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

    var menuController = MenuController()
    var spotifyManger = SpotifyManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        spotifyManger.delegate = menuController
        spotifyManger.start()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        menuController.showMenuBarIconIfNeeded()
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

