//
//  UIViewController+LMStatsTracker.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 20/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "UIViewController+LMStatsTracker.h"
#import <objc/runtime.h>
static LMStatsTracker *_defaultStatsTracker;

@implementation UIViewController(LMStatsTracker)
@dynamic statsTracker;


static char UIB_PROPERTY_KEY_STATS_TRACKER;

- (void)setStatsTracker:(LMStatsTracker *)statsTracker
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY_STATS_TRACKER, statsTracker, OBJC_ASSOCIATION_ASSIGN);
}

- (LMStatsTracker *)statsTracker{
    
    LMStatsTracker *statsTracker = objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_STATS_TRACKER);
    
    if (!statsTracker && _defaultStatsTracker) {
        self.statsTracker = _defaultStatsTracker;
        statsTracker = objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_STATS_TRACKER);
    }
    
    return statsTracker;
}

+ (void)setDefaultStatsTracker:(LMStatsTracker *)defaultStatsTracker{

    _defaultStatsTracker = defaultStatsTracker;
}
@end
