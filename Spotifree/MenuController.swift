//
//  MenuController.swift
//  Spotifree
//
//  Created by Eneas Rotterdam on 29.12.15.
//  Copyright © 2015 Eneas Rotterdam. All rights reserved.
//

import Cocoa
import Sparkle

class MenuController : NSObject {
    fileprivate var statusItem : NSStatusItem?
    
    override init() {
        super.init()
        
        if !DataManager.sharedData.isMenuBarIconHidden() {
            setUpMenu()
        }
    }
    
    func setUpMenu() {
        let statusMenu = NSMenu(title: "Spotifree")
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_INACTIVE", comment: "Spotify state: Inactive"), action: nil, keyEquivalent: "").tag = 1
        statusMenu.addItem(NSMenuItem.separator())
        
        let updateMenu = NSMenu()
        updateMenu.addItem(withTitle: NSLocalizedString("MENU_UPDATES_CHECK_FOR_UPDATES", comment:"Menu: Check For Updates..."), action: #selector(SUUpdater.checkForUpdates(_:)), keyEquivalent: "").target = SUUpdater.shared()
        updateMenu.addItem(NSMenuItem.separator())
        updateMenu.addItem(withTitle: NSLocalizedString("MENU_UPDATES_CHECK_AUTOMATICALLY", comment: "Menu: Check Automatically"), action: #selector(MenuController.toggleAutomaticallyCheckForUpdates), keyEquivalent: "").target = self
        updateMenu.addItem(withTitle: NSLocalizedString("MENU_UPDATES_DOWNLOAD_AUTOMATICALLY", comment: "Menu: Download automatically"), action: #selector(MenuController.toggleAutomaticallyDownloadUpdates), keyEquivalent: "").target = self
        let updateItem = NSMenuItem(title:NSLocalizedString("MENU_UPDATES", comment: "Menu: Updates"), action: nil, keyEquivalent: "")
        updateItem.submenu = updateMenu;
        
        statusMenu.addItem(updateItem);
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_HIDE_ICON", comment: "Menu: Hide Icon"), action: #selector(MenuController.hideIconClicked), keyEquivalent: "").target = self
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_RUN_AT_LOGIN", comment: "Menu: Run At Login"), action: #selector(MenuController.toggleLoginItem), keyEquivalent: "").target = self
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_NOTIFICATIONS", comment: "Menu: Notifications"), action: #selector(MenuController.toggleNotifications), keyEquivalent: "").target = self
        statusMenu.addItem(NSMenuItem.separator())
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_DONATE", comment: "Menu: Donate"), action: #selector(MenuController.donateLinkClicked), keyEquivalent: "").target = self
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_ABOUT", comment: "Menu: About"), action: #selector(MenuController.aboutItemClicked), keyEquivalent: "").target = self
        statusMenu.addItem(withTitle: NSLocalizedString("MENU_QUIT", comment: "Menu: Quit"), action: #selector(NSApplication.shared().terminate(_:)), keyEquivalent: "q").keyEquivalentModifierMask = NSEventModifierFlags(rawValue: UInt(Int(NSEventModifierFlags.command.rawValue)));
        statusMenu.addItem(NSMenuItem.separator())
        
        statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
        statusItem!.image = NSImage(named: "statusBarIconInactiveTemplate")
        statusItem!.menu = statusMenu
        statusItem!.highlightMode = true
    }
    
    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        if menuItem.action == #selector(MenuController.toggleNotifications) {
            menuItem.state = Int(DataManager.sharedData.shouldShowNofifications())
        }
        if menuItem.action == #selector(MenuController.toggleLoginItem) {
            menuItem.state = Int(DataManager.sharedData.isInLoginItems())
        }
        if menuItem.action == #selector(MenuController.toggleAutomaticallyCheckForUpdates) {
            menuItem.state = Int(SUUpdater.shared().automaticallyChecksForUpdates)
        }
        if menuItem.action == #selector(MenuController.toggleAutomaticallyDownloadUpdates) {
            menuItem.state = Int(SUUpdater.shared().automaticallyDownloadsUpdates)
            return SUUpdater.shared().automaticallyChecksForUpdates
        }
        return true
    }
    
    func hideIconClicked() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("ALERT_HIDE_ICON_INFO", comment: "Alert info: To show the icon again, simply launch Spotifree from Dock or Finder")
        alert.addButton(withTitle: NSLocalizedString("OK", comment: "General: OK"))
        alert.addButton(withTitle: NSLocalizedString("CANCEL", comment: "General: Cancel"))
        
        if !DataManager.sharedData.isInLoginItems() {
            alert.informativeText = NSLocalizedString("ALERT_HIDE_ICON_LAUNCH_AT_LOGIN_INFO", comment: "Alert info: If you want to make the app truly invisible, we suggest also allowing it to launch at login")
            alert.showsSuppressionButton = true
            alert.suppressionButton?.title = NSLocalizedString("MENU_RUN_AT_LOGIN", comment: "Menu: Run At Login")
            alert.suppressionButton?.state = NSOffState
        }
        
        statusItem?.highlightMode = false
        let response = alert.runModal()
        if response == NSAlertFirstButtonReturn {
            DataManager.sharedData.setMenuBarIconHidden(true)
            NSStatusBar.system().removeStatusItem(statusItem!)
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
        SUUpdater.shared().automaticallyChecksForUpdates = !SUUpdater.shared().automaticallyChecksForUpdates
        SUUpdater.shared().automaticallyDownloadsUpdates = false;
    }
    
    func toggleAutomaticallyDownloadUpdates() {
        SUUpdater.shared().automaticallyDownloadsUpdates = !SUUpdater.shared().automaticallyDownloadsUpdates
    }
    
    func donateLinkClicked() {
        let donateURL = "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=UG7ECWW2QNWBJ&lc=US&item_name=Donation%20for%20the%20development%20of%20Spotifree%20app&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"
        
        NSWorkspace.shared().open(URL(string: donateURL)!)
    }
    
    func aboutItemClicked() {
        NSApplication.shared().activate(ignoringOtherApps: true)
        NSApplication.shared().orderFrontStandardAboutPanel(self)
    }
}

extension MenuController : SpotifyManagerDelegate {
    func spotifreeStateChanged(_ state: SFSpotifreeState) {
        if let statusItem = statusItem {
            var label = "Status Unknown"
            var icon : NSImage?
            
            switch state {
            case .active:
                label = NSLocalizedString("MENU_ACTIVE", comment: "Spotify state: Active")
                icon = NSImage(named: "statusBarIconActiveTemplate")
            case .muting:
                label = NSLocalizedString("MENU_MUTING_AD", comment: "Spotify state: Muting Ad")
                icon = NSImage(named: "statusBarIconBlockingAdTemplate")
            case .inactive:
                label = NSLocalizedString("MENU_INACTIVE", comment: "Spotify state: Inactive")
                icon = NSImage(named: "statusBarIconInactiveTemplate")
            }
            
            statusItem.image = icon
            statusItem.menu?.item(withTag: 1)?.title = label
        }
    }
}

extension Int {
    init(_ bool:Bool) {
        self = bool ? 1 : 0
    }
}
