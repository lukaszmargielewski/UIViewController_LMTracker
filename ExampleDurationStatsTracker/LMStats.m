//
//  LMStatsTrackerDuration.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 18/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "LMStats.h"
#import <Foundation/Foundation.h>

static inline double trackerGetTimeNow(){
    
    return [NSDate date].timeIntervalSince1970;
    //return CACurrentMediaTime();
}


@interface LMStats()

- (void)setDuration:(double)duration;

@end

@implementation LMStats{

    double _referenceTime;
}

@synthesize duration = _duration;
@synthesize paused = _paused;
@synthesize resumeCount = _resumeCount;

- (void)setDuration:(double)duration{

    _duration = duration;
}


- (void)setResumeCount:(NSUInteger)resumeCount{

    _resumeCount = resumeCount;
}
- (void)setTEnd:(double)tEnd{

    _tEnd = tEnd;
}
- (void)setTStart:(double)tStart{

    _tStart = tStart;
}

- (instancetype)init{
    
    self = [super init];
    
    if (self) {
        
        [self resetDurationAndResumeCount];
        _tEnd = _tStart = _referenceTime;
    }
    return self;
    
}

/*
-(instancetype)init{

    //NSAssert(NO, @"Direct init not allowed. Use initStatsForUserInfo: instead...");
    
    return nil;
    
    
}

*/
- (id _Nonnull)copyWithZone:(NSZone * _Nullable)zone{

    LMStats *copiedObject = [[LMStats alloc] init];
    
    [copiedObject setDuration:self.duration];
    [copiedObject setUserInfo:self.userInfo];
    [copiedObject setResumeCount:self.resumeCount];
    [copiedObject setTStart:self.tStart];
    [copiedObject setTEnd:self.tEnd];
    
    return copiedObject;
}

- (void)encodeWithCoder:(NSCoder *)enCoder{
    
    [enCoder encodeObject:_userInfo forKey:@"ui"];
    
    [enCoder encodeDouble:_duration forKey:@"du"];
    [enCoder encodeInteger:_resumeCount forKey:@"rc"];
    
    [enCoder encodeDouble:_tStart forKey:@"ts"];
    [enCoder encodeDouble:_tEnd forKey:@"te"];
    
    // Similarly for the other instance variables.
    // ....
}
//And in the initWithCoder method initialize as follows:

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if(self = [super init]) {
        
        NSDictionary *ui = [aDecoder decodeObjectForKey:@"ui"];
        _userInfo = ui;
        
        _duration = [aDecoder decodeDoubleForKey:@"du"];
        _resumeCount = [aDecoder decodeIntegerForKey:@"rc"];
        _tStart = [aDecoder decodeDoubleForKey:@"ts"];
        _tEnd = [aDecoder decodeDoubleForKey:@"te"];
        
    }
    
    return self;
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
        _resumeCount++;
        _referenceTime = trackerGetTimeNow();
        if (_tStart == 0) {
            _tStart = _referenceTime;
        }
    }else{
    
        if (_resumeCount == 0) {
            _resumeCount++;
        }
    }
   
}

- (void)resetDurationAndResumeCount{

    _tEnd = _tStart = 0;
    _referenceTime = trackerGetTimeNow();
    _duration = 0;
    _resumeCount = 0;
}
- (void)updateDuration{
    
    if (_paused || !_supportsDuration)return;
    
    _tEnd = trackerGetTimeNow();
    double timePassed = _tEnd - _referenceTime;
    _duration += timePassed;
    _referenceTime = trackerGetTimeNow();

}
@end