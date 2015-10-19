//
//  Created by Lukasz Margielewski on 08/09/15.
//

#import <Foundation/Foundation.h>

#import "UIViewController_LMUIVCTracker.h"
#import "LMStatsTrackerDuration.h"


@class LMStatsTracker;

@protocol LMStatsTrackerReporter<NSObject>

- (BOOL)LMStatsTracker:(LMStatsTracker *)statsTracker
     reportsStatistics:(NSSet *)statistics;

@end


@interface LMStatsTracker : NSObject<LMUIVCTrackerDelegate>

@property (nonatomic, assign) id<LMStatsTrackerReporter>reporter;

@end
