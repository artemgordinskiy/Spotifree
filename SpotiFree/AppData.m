//
//  AppData.m
//  Spotifree
//
//  Created by Eneas on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import "AppData.h"

#define KEY_HAS_RAN_BEFORE @"SFHasRanBefore"

@interface AppData ()
@property (strong) NSDictionary *appleScriptCmds;
@end

@implementation AppData
@synthesize isFirstRun = _isFirstRun;

#pragma mark -
#pragma mark Initialisation of the singleton
+ (instancetype)sharedData {
    static AppData *sharedData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedData = [[self alloc] init];
    });
    return sharedData;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.appleScriptCmds = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AppleScriptCmds" ofType:@"plist"]];
        [self updateLoginItemState];
    }
    return self;
}

#pragma mark -
#pragma mark Handling LoginItem
- (void)addLoginItem {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:self.appleScriptCmds[@"addLoginItem"], [[NSBundle mainBundle] bundlePath]]];
    [script executeAndReturnError:nil];
}

- (void)removeLoginItem {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:self.appleScriptCmds[@"removeLoginItem"]];
    [script executeAndReturnError:nil];
}

- (void)updateLoginItemState {
    NSAppleScript *script = [[NSAppleScript alloc] initWithSource:self.appleScriptCmds[@"updateLoginItemState"]];
    NSAppleEventDescriptor *desc = [script executeAndReturnError:nil];
    self.isInLoginItems = [desc booleanValue];
}

- (void)toggleLoginItem {
    self.isInLoginItems ? [self removeLoginItem] : [self addLoginItem];
    [self updateLoginItemState];
}

#pragma mark -
#pragma mark NSUserDefaults
- (void)firstRunExecuted {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_HAS_RAN_BEFORE];
}

- (BOOL)isFirstRun {
    _isFirstRun = ![[NSUserDefaults standardUserDefaults] boolForKey:KEY_HAS_RAN_BEFORE];
    return _isFirstRun;
}

@end
