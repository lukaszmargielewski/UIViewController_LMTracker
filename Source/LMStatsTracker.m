//
//  Created by Lukasz Margielewski on 08/09/15.
//

#import "LMStatsTracker.h"

@interface LMStatsTracker()
@property (nonatomic, strong) NSMutableDictionary *trackingDictionary;
@end

@implementation LMStatsTracker

- (NSMutableDictionary *)trackingDictionary{

    if (!_trackingDictionary) {
        _trackingDictionary = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    
    return _trackingDictionary;
}
- (NSString *)keyForTrackedObject:(id)trackedObject{

    uintptr_t pointer_as_integer = (uintptr_t)trackedObject;
    NSString *pointerKey = [NSString stringWithFormat:@"pointer_%li", pointer_as_integer];
    return pointerKey;
    
}
- (void)UIViewControllerInit:(UIViewController *)viewController{
    
    NSString *pointerKey = [self keyForTrackedObject:viewController];
    
    
    //NSLog(@"MIHStatsTracker %@ Init with pointer: %@ | memento: %@", NSStringFromClass(viewController.class), pointerKey, mementoPointerKey);
}
- (void)UIViewController:(UIViewController *)viewController didDealocWithTracker:(LMUIVCTracker *)tracker{

    NSLog(@"%@ (%@) will dealloc with user info: %@",  NSStringFromClass(viewController.class), NSStringFromClass(tracker.viewControllerClass), tracker.userInfo);

}
- (void)UIViewController:(UIViewController *)viewController viewDidLoadWithTracker:(LMUIVCTracker *)tracker{

    //NSLog(@"MIHStatsTracker %@ viewDidLoadWithUserInfo: %@", NSStringFromClass(viewController.class), userInfo);
    
}

- (void)UIViewController:(UIViewController *)viewController viewWillAppear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker{

    //NSLog(@"MIHStatsTracker %@ viewWillAppear: %@", NSStringFromClass(viewController.class), userInfo);
}
- (void)UIViewController:(UIViewController *)viewController viewDidAppear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker{

    //NSString *pointerKey = [self keyForTrackedObject:viewController];
    
    double tNow = CACurrentMediaTime();
    NSString *pointerKey = [self keyForTrackedObject:viewController];
    self.trackingDictionary[pointerKey] = @(tNow);
    
    
}

- (void)UIViewController:(UIViewController *)viewController viewWillDisappear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker{
    
    NSDictionary *statsInfo = tracker.userInfo;
    
    if(!statsInfo){
        return;
    }
    
    NSString *statsID = tracker.IDString;
    
    NSLog(@"MIHStatsTracker %@ viewWillDisappear: id: %@ => %@", NSStringFromClass(viewController.class), statsID, statsInfo);
    double tNow = CACurrentMediaTime();
    NSString *pointerKey = [self keyForTrackedObject:viewController];
    NSNumber *tStartNumber = self.trackingDictionary[pointerKey];
    
    if (tStartNumber) {
        
        double tStart = [tStartNumber doubleValue];
        double duration = tNow - tStart;
        //NSLog(@"+ %@ VISIBLE BY: %fsec)", NSStringFromClass(viewController.class), duration);
        
    }else{
        
        //NSLog(@"+ %@ NO DURATION AVAILABLE!!!", NSStringFromClass(viewController.class));
    }
    
    [self.trackingDictionary removeObjectForKey:pointerKey];
    
}
- (void)UIViewController:(UIViewController *)viewController viewDidDisappear:(BOOL)animated withTracker:(LMUIVCTracker *)tracker{

    
}

@end
