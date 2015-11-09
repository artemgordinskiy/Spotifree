//
//  SpotifyController.m
//  SpotiFree
//
//  Created by Eneas on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import "SpotifyController.h"
#import "Spotify.h"
#import "AppData.h"
#import "AppDelegate.h"

#define SPOTIFY_BUNDLE_IDENTIFIER @"com.spotify.client"

#define IDLE_TIME 0.5
#define TIMER [NSTimer scheduledTimerWithTimeInterval:IDLE_TIME target:self selector:@selector(checkCurrentTrack) userInfo:nil repeats:YES]

@interface SpotifyController () {
    NSInteger _currentVolume;
}

@property (strong) SpotifyApplication *spotify;
@property (strong) AppData *appData;
@property (strong) NSTimer *timer;

@property (assign) BOOL shouldRun;
@property (assign) BOOL isMuted;
@property (assign) BOOL isInTheProcessOfMuting;

@end

@implementation SpotifyController

#pragma mark -
#pragma mark Initialisation
+ (id)spotifyController {
    return [[self alloc] init];
}

- (id)init
{
    self = [super init];

    if (self) {
        self.spotify = [SBApplication applicationWithBundleIdentifier:SPOTIFY_BUNDLE_IDENTIFIER];
        self.appData = [AppData sharedData];
        
        self.shouldRun = YES;
        self.isMuted = NO;
        [self addObserver:self forKeyPath:@"shouldRun" options:NSKeyValueObservingOptionOld context:nil];
        
        
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateChanged) name:@"com.spotify.client.PlaybackStateChanged" object:nil];
    }

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"shouldRun"]) {
        [self.timer invalidate];
        
        if (self.shouldRun) {
            self.timer = TIMER;
        }
        
        if ([self.delegate respondsToSelector:@selector(activeStateShouldGetUpdated:)]) {
            [self.delegate activeStateShouldGetUpdated:(self.shouldRun ? kSFSpotifyStateActive : kSFSpotifyStateInactive)];
        }
    }
}

- (void)playbackStateChanged {
    if (self.isInTheProcessOfMuting) {
        return;
    }
    
    self.shouldRun = [self isPlaying];
    [self checkCurrentTrack];
}

#pragma mark -
#pragma mark Public Methods
- (void)startService {
    [self playbackStateChanged];
    
    if (self.shouldRun) {
        self.timer = TIMER;
    } else {
        [self.timer invalidate];
    }
}

#pragma mark -
#pragma mark Timer Methods
- (void)checkCurrentTrack {
    // prevent relaunching Spotify on quit and muting it when it's not playing anything
    if (![self isPlaying]) {
        self.shouldRun = NO;
        return;
    }
    
    if ([self isAnAd]) {
        if (!self.isMuted) {
            [self mute];
        }
        
        if ([self.delegate respondsToSelector:@selector(activeStateShouldGetUpdated:)]) {
            [self.delegate activeStateShouldGetUpdated:kSFSpotifyStateBlockingAd];
        }
    } else {
        if (self.isMuted) {
            [self unmute];
        }
        
        if ([self.delegate respondsToSelector:@selector(activeStateShouldGetUpdated:)]) {
            [self.delegate activeStateShouldGetUpdated:(self.shouldRun ? kSFSpotifyStateActive : kSFSpotifyStateInactive)];
        }
    }
}

#pragma mark -
#pragma mark Player Control Methods

- (void)mute {
    self.isInTheProcessOfMuting = YES;
    _currentVolume = self.spotify.soundVolume;
    [self.spotify pause];
    [self.spotify setSoundVolume: 0];
    [self.spotify play];

	if (self.appData.shouldShowNotifications) {
        [self displayNotification: [NSString stringWithFormat:@"A Spotify ad was detected! Music will be back in about %ld seconds…", (long)self.spotify.currentTrack.duration/1000]];
	}
    
    self.isMuted = YES;
    self.isInTheProcessOfMuting = NO;
}

- (void)unmute {
    [self.spotify setSoundVolume:_currentVolume];
    self.isMuted = NO;
}

- (BOOL)isAnAd {
    BOOL isAnAd;
    NSInteger currentTrackNumber = self.spotify.currentTrack.trackNumber;
    NSString * currentTrackUrl = self.spotify.currentTrack.spotifyUrl;

    @try {
        isAnAd = ([currentTrackUrl hasPrefix:@"spotify:ad"] || (currentTrackNumber == 0 && ![currentTrackUrl hasPrefix:@"spotify:local"]));
    }
    @catch (NSException *exception) {
        isAnAd = NO;
        NSLog(@"Cannot check if current Spotify track is an ad: %@", exception.reason);
    }
    
    return isAnAd;
}

- (BOOL)isPlaying {
    BOOL isPlaying;
    
    @try {
        isPlaying = ([self isRunning] && self.spotify.playerState == SpotifyEPlSPlaying);
    }
    @catch (NSException *exception) {
        isPlaying = NO;
        NSLog(@"Cannot check if Spotify is playing: %@", exception.reason);
    }
    
    return isPlaying;
}

- (BOOL)isRunning {
    BOOL isRunning;
    
    @try {
        isRunning = self.spotify.isRunning;
    }
    @catch (NSException *exception) {
        isRunning = NO;
        NSLog(@"Cannot check if Spotify is running: %@", exception.reason);
    }
    
    return isRunning;
}

- (void)displayNotification:(NSString*)content {
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    [notification setTitle:@"Spotifree"];
    [notification setInformativeText:content];
    [notification setSoundName:nil];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)dealloc {
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"shouldRun"];
}

@end
