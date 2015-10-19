//
//  LMStatsTrackerDuration.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 18/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "LMStatsDuration.h"
#import <Foundation/Foundation.h>

static inline double trackerGetTimeNow(){
    
    return [NSDate date].timeIntervalSince1970;
    //return CACurrentMediaTime();
}


@interface LMStatsDuration()

- (void)setDuration:(double)duration;

@end

@implementation LMStatsDuration{

    double _referenceTime;
}

@synthesize duration = _duration;
@synthesize paused = _paused;
@synthesize userInfo =_userInfo;
@synthesize identifierString = _identifierString;
@synthesize resumeCount = _resumeCount;

- (void)setDuration:(double)duration{

    _duration = duration;
}

- (void)setUserInfo:(id<NSCopying>)userInfo{
    
    _userInfo = [userInfo copyWithZone:nil];
}
- (void)setResumeCount:(NSUInteger)resumeCount{

    _resumeCount = resumeCount;
}
- (void)setIdentifierString:(NSString *)identifierString{

    _identifierString = [identifierString copy];
}
- (void)setTEnd:(double)tEnd{

    _tEnd = tEnd;
}
- (void)setTStart:(double)tStart{

    _tStart = tStart;
}

- (instancetype)initStatsForUserInfo:(nonnull id<NSCopying>)userInfo
                    identifierString:(nonnull NSString *)idString{

    NSAssert(userInfo != nil, @"userInfo must NOT be nil.");
    NSAssert(userInfo != nil, @"identifierString must NOT be nil.");
    
    self = [super init];
    
    if (self) {
        
        _userInfo = [userInfo copyWithZone:nil];
        _identifierString = [idString copy];
        _tEnd = _tStart = 0;
        [self resetDurationAndResumeCount];
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

    LMStatsDuration *copiedObject = [[LMStatsDuration alloc] init];
    
    [copiedObject setDuration:self.duration];
    [copiedObject setUserInfo:self.userInfo];
    [copiedObject setIdentifierString:self.identifierString];
    [copiedObject setResumeCount:self.resumeCount];
    [copiedObject setTStart:self.tStart];
    [copiedObject setTEnd:self.tEnd];
    
    return copiedObject;
}

- (void)encodeWithCoder:(NSCoder *)enCoder{
    
    
    [enCoder encodeObject:_identifierString forKey:@"is"];
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
        
        NSString *idString = [aDecoder decodeObjectForKey:@"is"];
        NSDictionary *ui = [aDecoder decodeObjectForKey:@"ui"];
        
        _userInfo = ui;
        _identifierString = idString;
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
    }
   
}

- (void)resetDurationAndResumeCount{

    _referenceTime = trackerGetTimeNow();
    _duration = 0;
    _resumeCount = 0;
}
- (void)updateDuration{
    
    if (_paused)return;
    
    _tEnd = trackerGetTimeNow();
    double timePassed = _tEnd - _referenceTime;
    _duration += timePassed;
    _referenceTime = trackerGetTimeNow();

}
@end