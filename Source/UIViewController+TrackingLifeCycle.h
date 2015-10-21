//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import <UIKit/UIKit.h>

@protocol UIViewControllerTrackingLifeCycleUserInfo<NSObject>

@property (nonatomic, strong) id trackedInfo;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;

@end

@protocol UIViewControllerTrackingLifeCycleDelegate<NSObject>

- (void)addStatsWithUserInfo:(NSDictionary *)userInfo;

// ALL OF THIS METHODS ARE OPTIONAL:
@optional
- (void)UIViewControllerInit:(UIViewController *)viewController;

- (void)UIViewController:(UIViewController *)viewController willDeallocWithTrackedInfo:(NSDictionary *)trackedInfo;
- (void)UIViewControllerViewDidLoad:(UIViewController *)viewController;

- (void)UIViewController:(UIViewController *)viewController viewWillAppear:(BOOL)animated;
- (void)UIViewController:(UIViewController *)viewController viewDidAppear:(BOOL)animated;

- (void)UIViewController:(UIViewController *)viewController viewWillDisappear:(BOOL)animated;
- (void)UIViewController:(UIViewController *)viewController viewDidDisappear:(BOOL)animated;

@end

@interface UIViewController(TrackingLifeCycle)

@property (nonatomic, readonly) id<UIViewControllerTrackingLifeCycleUserInfo>tracker;
@property (nonatomic, readonly) id<UIViewControllerTrackingLifeCycleDelegate>trackerDelegate;

+ (void)setTrackerDelegate:(id<UIViewControllerTrackingLifeCycleDelegate>)startsTracer;

@end