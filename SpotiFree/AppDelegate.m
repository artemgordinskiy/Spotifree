//
//  AppDelegate.m
//  SpotiFree
//
//  Created by Eneas Rotterdam on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end