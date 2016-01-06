//
//  DataManager.swift
//  Spotifree
//
//  Created by Eneas Rotterdam on 29.12.15.
//  Copyright © 2015 Eneas Rotterdam. All rights reserved.
//

import Cocoa

let KEY_MENU_BAR_ICON_HIDDEN = "SFMenuBarIconHidden"
let KEY_SHOW_NOTIFICATIONS = "SFShowNotifications"
let KEY_POLLING_RATE = "SFPollingRate"

class DataManager : NSObject {
    static let sharedData = DataManager()
    
    private let appleScriptCmds = NSDictionary(contentsOfFile: NSBundle.mainBundle().pathForResource("AppleScriptCmds", ofType: "plist")!)!
    
    override init() {
        super.init()
        
        if isInLoginItems() && !isLoginItemPathCorrect() {
            removeLoginItem()
            addLoginItem()
        }
        
        let defaults = [KEY_MENU_BAR_ICON_HIDDEN : false, KEY_SHOW_NOTIFICATIONS : false, KEY_POLLING_RATE : 0.3]
        NSUserDefaults.standardUserDefaults().registerDefaults(defaults)
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("SUHasLaunchedBefore") {
            addLoginItem()
        }
    }
    
    func pollingRate() -> Double {
        return NSUserDefaults.standardUserDefaults().doubleForKey(KEY_POLLING_RATE)
    }
    
    func isMenuBarIconHidden() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(KEY_MENU_BAR_ICON_HIDDEN)
    }
    
    func setMenuBarIconHidden(hidden : Bool) {
        NSUserDefaults.standardUserDefaults().setBool(hidden, forKey: KEY_MENU_BAR_ICON_HIDDEN)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func toggleLoginItem() {
        isInLoginItems() ? removeLoginItem() : addLoginItem()
    }
    
    func addLoginItem() {
        NSAppleScript(source: String(format: appleScriptCmds["addLoginItem"] as! String, NSBundle.mainBundle().bundlePath))?.executeAndReturnError(nil)
    }
    
    func removeLoginItem() {
        NSAppleScript(source: appleScriptCmds["removeLoginItem"] as! String)?.executeAndReturnError(nil)
    }
    
    
    func isInLoginItems() -> Bool{
        var isInItems = true
        let desc = NSAppleScript(source: appleScriptCmds["isInLoginItems"] as! String)?.executeAndReturnError(nil)
        if let desc = desc {
            isInItems = desc.booleanValue
        }
        return isInItems
    }
    
    func isLoginItemPathCorrect() -> Bool {
        var isCorrect = true
        let desc = NSAppleScript(source: String(format: appleScriptCmds["isLoginItemPathCorrect"] as! String, NSBundle.mainBundle().bundlePath))?.executeAndReturnError(nil)
        if let desc = desc {
            isCorrect = desc.booleanValue
        }
        return isCorrect
    }
    
    func toggleShowNotifications() {
        let showNotifications = NSUserDefaults.standardUserDefaults().boolForKey(KEY_SHOW_NOTIFICATIONS)
        NSUserDefaults.standardUserDefaults().setBool(!showNotifications, forKey: KEY_SHOW_NOTIFICATIONS)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func shouldShowNofifications() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(KEY_SHOW_NOTIFICATIONS)
    }
}