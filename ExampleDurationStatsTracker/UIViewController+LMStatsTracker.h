//
//  UIViewController+LMStatsTracker.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 20/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMStatsTracker.h"

@interface UIViewController(LMStatsTracker)

@property (nonatomic, assign) LMStatsTracker *statsTracker;

+ (void)setDefaultStatsTracker:(LMStatsTracker *)defaultStatsTracker;

@end
