//
//  AppData.h
//  SpotiFree
//
//  Created by Eneas on 21.12.13.
//  Copyright (c) 2013 Eneas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppData : NSObject

+ (instancetype)sharedData;

- (void)firstRunExecuted;
- (void)toggleLoginItem;

@property (assign) BOOL isInLoginItems;
@property (assign, readonly) BOOL isFirstRun;

@end
