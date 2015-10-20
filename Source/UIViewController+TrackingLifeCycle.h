//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import <UIKit/UIKit.h>

@protocol UIViewControllerTrackingLifeCycleDelegate<NSObject>

- (void)addStatsWithUserInfo:(NSDictionary *)userInfo;

// ALL OF THIS METHODS ARE OPTIONAL:
@optional
- (void)UIViewControllerInit:(UIViewController *)viewController;

- (void)UIViewControllerDidDealloc:(UIViewController *)viewController;
- (void)UIViewControllerViewDidLoad:(UIViewController *)viewController;

- (void)UIViewController:(UIViewController *)viewController viewWillAppear:(BOOL)animated;
- (void)UIViewController:(UIViewController *)viewController viewDidAppear:(BOOL)animated;

- (void)UIViewController:(UIViewController *)viewController viewWillDisappear:(BOOL)animated;
- (void)UIViewController:(UIViewController *)viewController viewDidDisappear:(BOOL)animated;

@end

@interface UIViewController(TrackingLifeCycle)

@property (nonatomic, strong) NSDictionary *trackedInfo;

@property (nonatomic, readonly) id<UIViewControllerTrackingLifeCycleDelegate>trackerDelegate;

+ (void)setTrackerDelegate:(id<UIViewControllerTrackingLifeCycleDelegate>)startsTracer;

@end