//
//  Created by Lukasz Margielewski on 08/09/15.
//

#import <Foundation/Foundation.h>

#import "UIViewController+TrackingLifeCycle.h"
#import "LMStats.h"


@class LMStatsTracker;

@protocol LMStatsTrackerPersistance<NSObject>

- (BOOL)LMStatsTracker:(LMStatsTracker *)statsTracker
     persistStatistics:(NSArray *)statistics;

@end


@interface LMStatsTracker : NSObject<UIViewControllerTrackingLifeCycleDelegate>

@property (nonatomic, assign) id<LMStatsTrackerPersistance>persistance;

@end
