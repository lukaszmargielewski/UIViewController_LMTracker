//
//  Created by Lukasz Margielewski on 08/09/15.
//

#import <Foundation/Foundation.h>

#import "UIViewController_LMUIVCTracker.h"
#import "LMStats.h"


@class LMStatsTracker;

@protocol LMStatsTrackerPersistance<NSObject>

- (BOOL)LMStatsTracker:(LMStatsTracker *)statsTracker
     persistStatistics:(NSArray *)statistics;

@end


@interface LMStatsTracker : NSObject<LMUIVCTrackerDelegate>

@property (nonatomic, assign) id<LMStatsTrackerPersistance>persistance;

- (void)addStatsWithUserInfo:(NSDictionary *)userInfo;

@end
