//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import <UIKit/UIKit.h>

@interface LMUIVCTracker : NSObject

-(instancetype)initWithViewController:(UIViewController *)viewController;

@property (nonatomic, assign, readonly) UIViewController *viewController;
@property (nonatomic, strong) id<NSCopying>userInfo;
@end

@protocol LMUIVCTrackerDelegate<NSObject>

// ALL OF THIS METHODS ARE OPTIONAL:
@optional
- (void)UIViewControllerInit:(UIViewController *)viewController;

- (void)UIViewController:(UIViewController *)viewController didDealocWithTracker:(LMUIVCTracker *)tracker;
- (void)UIViewController:(UIViewController *)viewController viewDidLoadWithTracker:(LMUIVCTracker *)tracker;

- (void)UIViewController:(UIViewController *)viewController viewWillAppear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;
- (void)UIViewController:(UIViewController *)viewController viewDidAppear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;

- (void)UIViewController:(UIViewController *)viewController viewWillDisappear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;
- (void)UIViewController:(UIViewController *)viewController viewDidDisappear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker;

@end

@interface UIViewController(LMUIVCTracker)

@property (nonatomic, readonly) LMUIVCTracker *tracker;

+ (void)setTrackerDelegate:(id<LMUIVCTrackerDelegate>)startsTracer;

@end