//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import <UIKit/UIKit.h>

@interface LMUIVCTracker : NSObject

-(instancetype)initWithViewController:(UIViewController *)viewController;

@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *IDString;
@property (nonatomic, assign, readonly) UIViewController *viewController;

@property (nonatomic, strong, readonly) Class viewControllerClass;

@end

@protocol UIViewControllerStatsTracker<NSObject>

- (void)UIViewControllerInit:(UIViewController *)viewController;

- (void)UIViewController:(UIViewController *)viewController didDealocWithTracker:(LMUIVCTracker *)tracker;
- (void)UIViewController:(UIViewController *)viewController viewDidLoadWithTracker:(LMUIVCTracker *)tracker;

- (void)UIViewController:(UIViewController *)viewController viewWillAppear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;
- (void)UIViewController:(UIViewController *)viewController viewDidAppear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;

- (void)UIViewController:(UIViewController *)viewController viewWillDisappear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;
- (void)UIViewController:(UIViewController *)viewController viewDidDisappear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;

@end

@interface UIViewController(LMStatsTracker)

@property (nonatomic, readonly) LMUIVCTracker *tracker;

+ (void)setStatisticsTracker:(id<UIViewControllerStatsTracker>)startsTracer;

@end