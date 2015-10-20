//
//  LMStatsReporter.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 20/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMStatsPersistense.h"

@interface LMStatsReporter : NSObject<LMStatsPersistenseObserver>
@property (nonatomic, readonly) LMStatsPersistense *persistence;

- (instancetype)initWithLMStatsPersistense:(nonnull LMStatsPersistense *)persistence;
- (void)reportAllUnreportedStats;

@end
