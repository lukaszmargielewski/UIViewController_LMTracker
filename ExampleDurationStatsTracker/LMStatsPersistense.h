//
//  LMStatsPersistense.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 19/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMStatsTracker.h"

@interface LMStatsPersistense : NSObject<LMStatsTrackerPersistance>

- (void)debugLogAllSavedStats;

@end
