//
//  LMStatsTrackerDuration.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 18/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LMUIVCTracker;

@interface LMStats : NSObject<NSCopying, NSCoding>

@property (nonatomic, readonly) double tStart;
@property (nonatomic, readonly) double tEnd;
@property (nonatomic, readonly) double duration;
@property (nonatomic, readonly) NSUInteger resumeCount;

@property (nonatomic, readonly, getter=isPaused) BOOL paused;
@property (nonatomic) BOOL visible;

@property (nonatomic, readonly, nonnull) id <NSCopying> userInfo;

- (instancetype)initStatsForUserInfo:(nonnull id<NSCopying>)userInfo;


- (void)pauseTime;
- (void)resumeTime;
- (void)updateDuration;

- (void)resetDurationAndResumeCount;

@end
