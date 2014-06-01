//
//  AppDelegate.m
//  SpotiFree
//
//  Created by Eneas on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <NSUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    [self.menuController showMenuBarIconIfNeeded];
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

@end