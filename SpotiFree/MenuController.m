//
//  AppController.m
//  SpotiFree
//
//  Created by Eneas on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import <Sparkle/Sparkle.h>

#import "MenuController.h"
#import "SpotifyController.h"
#import "AppData.h"

@interface MenuController () <NSAlertDelegate, SpotifyControllerDelegate>

@property (unsafe_unretained) IBOutlet NSMenu *statusMenu;
@property (strong) NSStatusItem *statusItem;

@property (strong) SpotifyController *spotify;
@property (strong) AppData *appData;

@end

@implementation MenuController

#pragma mark -
#pragma mark Startup
- (void)awakeFromNib {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    [self.statusItem setImage:[NSImage imageNamed:@"statusBarIconActive"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"statusBarIconHighlighted"]];
    
    [self.statusItem setMenu:self.statusMenu];
    
    [self.statusItem setHighlightMode:YES];
        
    self.appData = [AppData sharedData];
    [self.appData addObserver:self forKeyPath:@"isInLoginItems" options:NSKeyValueObservingOptionInitial context:nil];
    
    [[SUUpdater sharedUpdater] addObserver:self forKeyPath:@"automaticallyDownloadsUpdates" options:NSKeyValueObservingOptionInitial context:nil];
    [[SUUpdater sharedUpdater] addObserver:self forKeyPath:@"automaticallyChecksForUpdates" options:NSKeyValueObservingOptionInitial context:nil];
    
    if ([self.appData isFirstRun]) {
        [self.appData firstRunExecuted];
        
        if (!self.appData.isInLoginItems) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want Spotifree to run automatically on login?" defaultButton:@"OK" alternateButton:@"No, thanks" otherButton:nil informativeTextWithFormat:@""];
            [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        }
    }
    
    self.spotify = [SpotifyController spotifyController];
    self.spotify.delegate = self;
    [self.spotify startService];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isInLoginItems"]) {
        if (self.appData.isInLoginItems) {
            [[self.statusMenu itemWithTitle:@"Run At Login"] setState:1];
        } else {
            [[self.statusMenu itemWithTitle:@"Run At Login"] setState:0];
        }
    }
    
    if ([keyPath isEqualToString:@"automaticallyChecksForUpdates"]) {
        if ([SUUpdater sharedUpdater].automaticallyChecksForUpdates) {
            [[self.statusMenu itemWithTitle:@"Check For Updates Automatically"] setState:1];
            [[self.statusMenu itemWithTitle:@"Download Updates Automatically"] setEnabled:YES];
        } else {
            [[self.statusMenu itemWithTitle:@"Check For Updates Automatically"] setState:0];
            [[self.statusMenu itemWithTitle:@"Download Updates Automatically"] setEnabled:NO];
            [[SUUpdater sharedUpdater] setAutomaticallyDownloadsUpdates:NO];
        }
    }
    
    if ([keyPath isEqualToString:@"automaticallyDownloadsUpdates"]) {
        if ([SUUpdater sharedUpdater].automaticallyDownloadsUpdates) {
            [[self.statusMenu itemWithTitle:@"Download Updates Automatically"] setState:1];
        } else {
            [[self.statusMenu itemWithTitle:@"Download Updates Automatically"] setState:0];
        }
    }
}

#pragma mark -
#pragma SpotifyControllerDelegate
- (void)activeStateShouldGetUpdated:(BOOL)isActive {
    [self.statusMenu.itemArray[0] setTitle:isActive ? @"Active" : @"Inactive"];
    [self.statusItem setImage:isActive ? [NSImage imageNamed:@"statusBarIconActive"] : [NSImage imageNamed:@"statusBarIconInactive"]];
}

#pragma mark -
#pragma mark NSAlertModalDelegate
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        [self.appData toggleLoginItem];
    }
}

#pragma mark -
#pragma mark IBActions
- (IBAction)aboutItemPushed:(NSMenuItem *)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}

- (IBAction)toggleLoginItem:(NSMenuItem *)sender {
    [self.appData toggleLoginItem];
}

- (IBAction)toggleAutomaticallyChecksForUpdates:(NSMenuItem *)sender {
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:![SUUpdater sharedUpdater].automaticallyChecksForUpdates];
}

- (IBAction)toggleAutomaticallyDownloadsUpdates:(NSMenuItem *)sender {
    [[SUUpdater sharedUpdater] setAutomaticallyDownloadsUpdates:![SUUpdater sharedUpdater].automaticallyDownloadsUpdates];
}

#pragma mark -
#pragma mark Dealloc
- (void)dealloc {
    [self.appData removeObserver:self forKeyPath:@"isInLoginItems"];
    [[SUUpdater sharedUpdater] removeObserver:self forKeyPath:@"automaticallyDownloadsUpdates"];
    [[SUUpdater sharedUpdater] removeObserver:self forKeyPath:@"automaticallyChecksForUpdates"];
}



@end
