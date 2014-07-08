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

@property (unsafe_unretained) IBOutlet NSMenuItem *statusMenuItem;

@property (strong) SpotifyController *spotify;
@property (strong) AppData *appData;

@end

@implementation MenuController

#pragma mark -
#pragma mark Startup
- (void)awakeFromNib {
    BOOL hideMenuBarIcon = [[NSUserDefaults standardUserDefaults] boolForKey:@"hideMenuBarIcon"];
    if (!hideMenuBarIcon) {
        [self setUpMenu];
    }
    
    self.appData = [AppData sharedData];
    
    if ([self.appData isFirstRun]) {
        [self.appData firstRunExecuted];
        
        if (!self.appData.isInLoginItems) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Do you want Spotifree to run automatically on login?" defaultButton:@"OK" alternateButton:@"No, thanks" otherButton:nil informativeTextWithFormat:@""];
            [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:"firstRunAlert"];
        }
    }
    
    self.spotify = [SpotifyController spotifyController];
    self.spotify.delegate = self;
    [self.spotify startService];

	[[self.statusMenu itemWithTag:-1] setState:(self.appData.shouldShowNotifications ? NSOnState : NSOffState)];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    if (menuItem.action == @selector(toggleLoginItem:)) {
        menuItem.state = self.appData.isInLoginItems;
    }
    if (menuItem.action == @selector(toggleAutomaticallyChecksForUpdates:)) {
        menuItem.state = [SUUpdater sharedUpdater].automaticallyChecksForUpdates;
    }
    if (menuItem.action == @selector(toggleAutomaticallyDownloadsUpdates:)) {
        menuItem.state = [SUUpdater sharedUpdater].automaticallyDownloadsUpdates;
        return [SUUpdater sharedUpdater].automaticallyChecksForUpdates;
    }
    return YES;
}

- (void)setUpMenu {
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    
    [self.statusItem setImage:[NSImage imageNamed:@"statusBarIconActiveTemplate"]];
    [self.statusItem setAlternateImage:[NSImage imageNamed:@"statusBarIconHighlightedTemplate"]];
    
    [self.statusItem setMenu:self.statusMenu];
    
    [self.statusItem setHighlightMode:YES];
}

#pragma mark -
#pragma SpotifyControllerDelegate
- (void)activeStateShouldGetUpdated:(SFSpotifyState)state {
    if (!self.statusItem)
        return;

	NSString *label;
	NSImage *icon;

	switch (state) {
		case kSFSpotifyStateActive:
			label = @"Active";
			icon = [NSImage imageNamed:@"statusBarIconActiveTemplate"];
			break;
		case kSFSpotifyStateInactive:
			label = @"Inactive";
			icon = [NSImage imageNamed:@"statusBarIconInactiveTemplate"];
			break;
		case kSFSpotifyStateBlockingAd:
			label = @"Blocking Ad";
			icon = [NSImage imageNamed:@"statusBarIconBlockingAdTemplate"];
			break;

		default:
			break;
	}

	[self.statusMenuItem setTitle:label];
	[self.statusItem setImage:icon];
}

#pragma mark -
#pragma mark NSAlertModalDelegate
- (void) alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    if (returnCode == 1) {
        if (strcmp(contextInfo, "firstRunAlert") == 0) {
            [self.appData toggleLoginItem];
        }
        
        if (strcmp(contextInfo, "hideIconAlert") == 0) {
            [self.appData setIsInLoginItems:alert.suppressionButton.state];
            
            [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItem];
            self.statusItem = nil;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hideMenuBarIcon"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark -
#pragma mark IBActions
- (IBAction)aboutItemPushed:(NSMenuItem *)sender {
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [[NSApplication sharedApplication] orderFrontStandardAboutPanel:self];
}

- (IBAction)toggleLoginItem:(NSMenuItem *)sender {
    self.appData.isInLoginItems = !self.appData.isInLoginItems;
}

- (IBAction)hideMenuBarIconClicked:(NSMenuItem *)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"To show the icon again, simply launch Spotifree from Dock or Finder" defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    
    alert.suppressionButton.state = self.appData.isInLoginItems;
    if (!self.appData.isInLoginItems) {
        alert.messageText = [alert.messageText stringByAppendingString:@"\n\nIf you want to make the app truly invisible, we suggest also allowing it to launch at login"];
        alert.suppressionButton.title = @"Run at login";
        [alert setShowsSuppressionButton:YES];
    }
    
    [alert beginSheetModalForWindow:nil modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:"hideIconAlert"];
}

- (IBAction)toggleAutomaticallyChecksForUpdates:(NSMenuItem *)sender {
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:![SUUpdater sharedUpdater].automaticallyChecksForUpdates];
    [[SUUpdater sharedUpdater] setAutomaticallyDownloadsUpdates:NO];
}

- (IBAction)toggleAutomaticallyDownloadsUpdates:(NSMenuItem *)sender {
    [[SUUpdater sharedUpdater] setAutomaticallyDownloadsUpdates:![SUUpdater sharedUpdater].automaticallyDownloadsUpdates];
}

- (IBAction)toggleShowNotificationsOnAdBlock:(id)sender {
	BOOL tickStatus = [self.appData toggleShowNotifications];
	[(NSMenuItem*)sender setState:(tickStatus ? NSOnState : NSOffState)];
}

#pragma mark -
#pragma mark Public Methods
- (void)showMenuBarIconIfNeeded {
    if (self.statusItem) {
        return;
    }

    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hideMenuBarIcon"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setUpMenu];
}

@end
