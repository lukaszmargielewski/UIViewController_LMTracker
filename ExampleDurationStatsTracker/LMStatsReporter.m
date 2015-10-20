//
//  LMStatsReporter.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 20/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "LMStatsReporter.h"

@implementation LMStatsReporter
@synthesize persistence = _persistence;

- (instancetype)init{

    NSAssert(NO, @"Raw init not allowed. Use initWithLMStatsPersistense instead.");
    return nil;
}
- (instancetype)initWithLMStatsPersistense:(nonnull LMStatsPersistense *)persistence{

    self = [super init];
    
    if (self) {
        _persistence = persistence;
        _persistence.observer = self;
    }
    
    return self;
}

- (void)LMStatsPersistense:(LMStatsPersistense *)statsPersistence
           didSaveNewStats:(NSArray<LMStats *> *)stats
                    toFile:(NSString *)filePath{
    
    [self reportAllUnreportedStats];
}

- (void)reportAllUnreportedStats{

    [self.persistence debugLogAllSavedStats];
}
@end
