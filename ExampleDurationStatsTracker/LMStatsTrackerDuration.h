//
//  LMStatsTrackerDuration.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 18/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LMStatsTrackerDuration : NSObject<NSCopying>

@property (nonatomic, readonly) double duration;
@property (nonatomic, readonly, getter=isPaused) BOOL paused;

@property (nonatomic, readonly) id<NSCopying>userInfo;

- (instancetype)initStatsForUserInfo:(id<NSCopying>)userInfo;


- (void)pauseTime;
- (void)resumeTime;
- (void)updateDuration;

- (void)resetTime;

@end
