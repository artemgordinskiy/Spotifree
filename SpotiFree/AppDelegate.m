//
//  AppDelegate.m
//  SpotiFree
//
//  Created by Eneas on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuController.h"

@interface AppDelegate ()

@property (unsafe_unretained) IBOutlet MenuController *menuController;

@end

@implementation AppDelegate

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.menuController showMenuBarIconIfNeeded];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end