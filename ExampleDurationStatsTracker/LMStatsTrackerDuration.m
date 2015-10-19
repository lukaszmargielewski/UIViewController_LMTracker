//
//  LMStatsTrackerDuration.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 18/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "LMStatsTrackerDuration.h"
#import <Foundation/Foundation.h>


static inline double trackerGetTimeNow(){
    
    return [NSDate date].timeIntervalSince1970;
    //return CACurrentMediaTime();
}


@interface LMStatsTrackerDuration()

- (void)setDuration:(double)duration;
@end

@implementation LMStatsTrackerDuration{

    double _referenceTime;
}

@synthesize duration = _duration;
@synthesize paused = _paused;
@synthesize userInfo =_userInfo;

- (void)setDuration:(double)duration{


    _duration = duration;
}

- (void)setUserInfo:(id<NSCopying>)userInfo{
    
    _userInfo = [userInfo copyWithZone:nil];
}

- (instancetype)initStatsForUserInfo:(id<NSCopying>)userInfo{

    NSAssert(userInfo != nil, @"userInfo must NOT be nil.");
    
    self = [super init];
    
    if (self) {
        
        _userInfo = [userInfo copyWithZone:nil];
        [self resetTime];
    }
    return self;
    
}
-(instancetype)init{

    NSAssert(NO, @"Direct init not allowed. Use initStatsForUserInfo: instead...");
    
    return nil;
    
    
}
- (id _Nonnull)copyWithZone:(NSZone * _Nullable)zone{

    LMStatsTrackerDuration *copiedObject = [[LMStatsTrackerDuration alloc] init];
    
    [copiedObject setDuration:self.duration];
    [copiedObject setUserInfo:self.userInfo];
    
    return copiedObject;
}


- (void)pauseTime{

    if (!_paused) {

        [self updateDuration];
        _paused = YES;
        
    }
    
}
- (void)resumeTime{

    if (_paused) {
        _paused = NO;
        _referenceTime = trackerGetTimeNow();
    }
   
}

- (void)resetTime{

    _referenceTime = trackerGetTimeNow();
    _duration = 0;
}
- (void)updateDuration{
    
    if (_paused)return;
    
    double tNow = trackerGetTimeNow();
    double timePassed = tNow - _referenceTime;
    _duration += timePassed;
    _referenceTime = CACurrentMediaTime();

}
@end