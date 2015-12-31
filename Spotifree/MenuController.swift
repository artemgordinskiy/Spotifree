//
//  MenuController.swift
//  Spotifree
//
//  Created by Eneas Rotterdam on 29.12.15.
//  Copyright © 2015 Eneas Rotterdam. All rights reserved.
//

import Cocoa
import Sparkle

class MenuController : NSObject, SpotifyManagerDelegate {
    private var statusItem : NSStatusItem?
    
    override init() {
        super.init()
        
        if !DataManager.sharedData.isMenuBarIconHidden() {
            setUpMenu()
        }
    }
    
    func setUpMenu() {
        let statusMenu = NSMenu(title: "Spotifree")
        statusMenu.addItemWithTitle("Active", action: nil, keyEquivalent: "")?.tag = 1
        statusMenu.addItem(NSMenuItem.separatorItem())
        
        let updateMenu = NSMenu()
        updateMenu.addItemWithTitle("Check For Updates...", action: "checkForUpdates:", keyEquivalent: "")?.target = SUUpdater.sharedUpdater()
        updateMenu.addItem(NSMenuItem.separatorItem())
        updateMenu.addItemWithTitle("Check Automatically", action: "toggleAutomaticallyCheckForUpdates", keyEquivalent: "")!.target = self
        updateMenu.addItemWithTitle("Download Automatically", action: "toggleAutomaticallyDownloadUpdates", keyEquivalent: "")!.target = self
        let updateItem = NSMenuItem(title:"Updates", action: nil, keyEquivalent: "")
        updateItem.submenu = updateMenu;
        
        statusMenu.addItem(updateItem);
        statusMenu.addItemWithTitle("Hide Icon", action: "hideIconClicked", keyEquivalent: "")!.target = self
        statusMenu.addItem(NSMenuItem.separatorItem())
        statusMenu.addItemWithTitle("Run At Login", action: "toggleLoginItem", keyEquivalent: "")!.target = self
        statusMenu.addItemWithTitle("Notifications", action: "toggleNotifications", keyEquivalent: "")!.target = self
        statusMenu.addItem(NSMenuItem.separatorItem())
        statusMenu.addItemWithTitle("Donate", action: "donateLinkClicked", keyEquivalent: "")!.target = self
        statusMenu.addItemWithTitle("About", action: "aboutItemClicked", keyEquivalent: "")!.target = self
        statusMenu.addItemWithTitle("Quit", action: "terminate:", keyEquivalent: "q")!.keyEquivalentModifierMask = Int(NSEventModifierFlags.CommandKeyMask.rawValue);
        statusMenu.addItem(NSMenuItem.separatorItem())
        
        statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSSquareStatusItemLength)
        statusItem!.image = NSImage(named: "statusBarIconActiveTemplate")
        statusItem!.menu = statusMenu
        statusItem!.highlightMode = true
    }
    
    override func validateMenuItem(menuItem: NSMenuItem) -> Bool {
        if menuItem.action == "toggleNotifications" {
            menuItem.state = Int(DataManager.sharedData.shouldShowNofifications())
        }
        if menuItem.action == "toggleLoginItem" {
            menuItem.state = Int(DataManager.sharedData.isInLoginItems())
        }
        if menuItem.action == "toggleAutomaticallyCheckForUpdates" {
            menuItem.state = Int(SUUpdater.sharedUpdater().automaticallyChecksForUpdates)
        }
        if menuItem.action == "toggleAutomaticallyDownloadUpdates" {
            menuItem.state = Int(SUUpdater.sharedUpdater().automaticallyDownloadsUpdates)
            return SUUpdater.sharedUpdater().automaticallyChecksForUpdates
        }
        return true
    }
    
    func hideIconClicked() {
        let alert = NSAlert()
        alert.messageText = "To show the icon again, simply launch Spotifree from Dock or Finder"
        alert.addButtonWithTitle("OK")
        alert.addButtonWithTitle("Cancel")
        
        if !DataManager.sharedData.isInLoginItems() {
            alert.messageText.appendContentsOf("\n\nIf you want to make the app truly invisible, we suggest also allowing it to launch at login")
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = "Run At Login"
            alert.suppressionButton?.state = NSOffState
        }
        
        statusItem?.highlightMode = false
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            DataManager.sharedData.setMenuBarIconHidden(true)
            NSStatusBar.systemStatusBar().removeStatusItem(statusItem!)
            statusItem = nil
            
            if alert.suppressionButton?.state == NSOnState {
                DataManager.sharedData.toggleLoginItem()
            }
        }
        statusItem?.highlightMode = true
    }
    
    func showMenuBarIconIfNeeded() {
        if self.statusItem != nil {return}
        
        DataManager.sharedData.setMenuBarIconHidden(false)
        setUpMenu()
    }
    
    func toggleNotifications() {
        DataManager.sharedData.toggleShowNotifications()
    }
    
    func toggleLoginItem() {
        DataManager.sharedData.toggleLoginItem()
    }
    
    func toggleAutomaticallyCheckForUpdates() {
        SUUpdater.sharedUpdater().automaticallyChecksForUpdates = !SUUpdater.sharedUpdater().automaticallyChecksForUpdates
        SUUpdater.sharedUpdater().automaticallyDownloadsUpdates = false;
    }
    
    func toggleAutomaticallyDownloadUpdates() {
        SUUpdater.sharedUpdater().automaticallyDownloadsUpdates = !SUUpdater.sharedUpdater().automaticallyDownloadsUpdates
    }
    
    func donateLinkClicked() {
        let donateURL = "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=UG7ECWW2QNWBJ&lc=US&item_name=Donation%20for%20the%20development%20of%20Spotifree%20app&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"
        
        NSWorkspace.sharedWorkspace().openURL(NSURL(string: donateURL)!)
    }
    
    func aboutItemClicked() {
        NSApplication.sharedApplication().activateIgnoringOtherApps(true)
        NSApplication.sharedApplication().orderFrontStandardAboutPanel(self)
    }
    
    func spotifreeStateChanged(state: SFSpotifreeState) {
        if let _statusItem = statusItem {
            var label = "Status Unknown"
            var icon : NSImage?
            
            switch state {
            case .kSFSpotifreeStateActive:
                label = "Active"
                icon = NSImage(named: "statusBarIconActiveTemplate")
            case .kSFSpotifreeStateMuting:
                label = "Muting Ad"
                icon = NSImage(named: "statusBarIconBlockingAdTemplate")
            case .kSFSpotifreeStatePolling:
                label = "Polling"
                icon = NSImage(named: "statusBarIconActiveTemplate")
            case .kSFSpotifreeStateNotPolling:
                label = "Not Polling"
                icon = NSImage(named: "statusBarIconInactiveTemplate")
            }
            
            _statusItem.image = icon
            _statusItem.menu?.itemWithTag(1)?.title = label
        }
    }
}