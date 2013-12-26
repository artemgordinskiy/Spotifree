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

#define SPOTIFY_BUNDLE_IDENTIFIER @"com.spotify.client"

#define IDLE_TIME 0.3
#define TIMER_CHECK_AD [NSTimer scheduledTimerWithTimeInterval:IDLE_TIME target:self selector:@selector(checkForAd) userInfo:nil repeats:YES]
#define TIMER_CHECK_MUSIC [NSTimer scheduledTimerWithTimeInterval:IDLE_TIME target:self selector:@selector(checkForMusic) userInfo:nil repeats:YES]

@interface SpotifyController () {
    NSInteger _currentVolume;
    id _observer;
}

@property (strong) SpotifyApplication *spotify;
@property (strong) AppData *appData;
@property (strong) NSTimer *timer;
@property (strong) NSTask *task;

@property (assign) BOOL shouldRun;

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
        __unsafe_unretained typeof(self) weakSelf = self;
        _observer = [[[NSWorkspace sharedWorkspace] notificationCenter] addObserverForName:NSWorkspaceDidLaunchApplicationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            if (!weakSelf.shouldRun && weakSelf.spotify.isRunning)
                weakSelf.shouldRun = YES;
        }];
        weakSelf = nil;
        
        [self addObserver:self forKeyPath:@"shouldRun" options:NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"shouldRun"]) {
        if (self.shouldRun != [change[NSKeyValueChangeOldKey] boolValue]) {
            if (self.shouldRun) {
                if (self.timer)
                    [self.timer invalidate];
                self.timer = TIMER_CHECK_AD;
            } else {
                if (self.timer)
                    [self.timer invalidate];
            }
            if ([self.delegate respondsToSelector:@selector(activeStateShouldGetUpdated:)])
                [self.delegate activeStateShouldGetUpdated:self.shouldRun];
        }
    }
}

#pragma mark -
#pragma mark Public Methods
- (void)startService {
    if (self.shouldRun)
        self.timer = TIMER_CHECK_AD;
}

#pragma mark -
#pragma mark Timer Methods
- (void)checkForAd {
    if (![self isRunning]) {
        self.shouldRun = NO;
    }
    if ([self isAnAdPlaying]) {
        [self.timer invalidate];
        [self mute];
        self.timer = TIMER_CHECK_MUSIC;
    }
}

- (void)checkForMusic {
    if ([self isMusicPlaying]) {
        [self.timer invalidate];
        [self unmute];
        if (self.shouldRun)
            self.timer = TIMER_CHECK_AD;
    }
}

#pragma mark -
#pragma mark Player Control Methods
- (void)mute {
    _currentVolume = self.spotify.soundVolume;
    [self.spotify pause];
    [self.spotify setSoundVolume:0];
    [self.spotify play];
}

- (void)unmute {
    double delayInSeconds = 0.8;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.spotify setSoundVolume:_currentVolume];
    });
}

- (BOOL)isAnAd {
    NSInteger currentTrackPopularity, currentTrackDuration;
    
    currentTrackPopularity = self.spotify.currentTrack.popularity;
    currentTrackDuration = self.spotify.currentTrack.duration;
    
    if (currentTrackPopularity == 0 && currentTrackDuration <= 40) {
        return YES;
    }
    return NO;
}

- (BOOL)isPlaying {
    return self.spotify.playerState == SpotifyEPlSPlaying;
}

- (BOOL)isRunning {
    return self.spotify.isRunning;
}

- (BOOL)isAnAdPlaying {
    return [self isRunning] && [self isPlaying] && [self isAnAd];
}

- (BOOL)isMusicPlaying {
    return [self isRunning] && [self isPlaying] && ![self isAnAd];
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:_observer];
    [self removeObserver:self forKeyPath:@"shouldRun"];
}

@end
