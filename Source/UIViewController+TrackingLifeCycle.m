//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import "UIViewController+TrackingLifeCycle.h"
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

#define DLog //DLog


#pragma mark - Internal Tracking Object Class:

@interface LMUIVCTracker : NSObject

-(instancetype)initWithViewController:(UIViewController *)viewController;

@property (nonatomic, assign, readonly) UIViewController *viewController;
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@end

@interface LMUIVCTracker()
- (void)setVisible:(BOOL)visible;
@end


#pragma mark - Main Implementation:

@interface UIViewController()
@property (nonatomic, readonly) LMUIVCTracker *tracker;

@end

@implementation UIViewController(TrackingLifeCycle)

@dynamic trackerDelegate;
@dynamic trackedInfo;

static id<UIViewControllerTrackingLifeCycleDelegate> _trackerDelegate = nil;

static char UIB_PROPERTY_KEY_DEALLOC_OBSERVER;

- (void)setTracker:(LMUIVCTracker *)tracker
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY_DEALLOC_OBSERVER, tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSDictionary *)trackedInfo{

   return self.tracker.userInfo;
}
- (void)setTrackedInfo:(id)trackedInfo{

    self.tracker.userInfo = trackedInfo;
    
}
- (LMUIVCTracker *)tracker{
    
    return objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_DEALLOC_OBSERVER);
}
- (id<UIViewControllerTrackingLifeCycleDelegate>)trackerDelegate{

    @synchronized(self) {
        return _trackerDelegate;
    }
}

+ (void)setTrackerDelegate:(id<UIViewControllerTrackingLifeCycleDelegate>)startsTracer{

    @synchronized(self) {
        _trackerDelegate = startsTracer;
    
        if (_trackerDelegate) {
            [self swizzleWhenTrackingEnabled];
        }
    }
}

+ (void)swizzleWhenTrackingEnabled {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [self swizzleInstanceSelector:@selector(viewDidLoad) withSelector:@selector(stats_viewDidLoad)];
        [self swizzleInstanceSelector:@selector(init) withSelector:@selector(stats_init)];
        [self swizzleInstanceSelector:@selector(initWithName:bundle:) withSelector:@selector(stats_initWithNibName:bundle:)];
        [self swizzleInstanceSelector:@selector(viewWillAppear:) withSelector:@selector(stats_viewWillAppear:)];
        [self swizzleInstanceSelector:@selector(viewDidAppear:) withSelector:@selector(stats_viewDidAppear:)];
        [self swizzleInstanceSelector:@selector(viewWillDisappear:) withSelector:@selector(stats_viewWillDisappear:)];
        [self swizzleInstanceSelector:@selector(viewDidDisappear:) withSelector:@selector(stats_viewDidDisappear:)];
    });
}


- (id)stats_initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle{
    
    [self stats_initWithNibName:nibName bundle:bundle];
    self.tracker = [[LMUIVCTracker alloc] initWithViewController:self];
    
    [_trackerDelegate UIViewControllerInit:self];
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewControllerInit:)]) {
        
        [_trackerDelegate UIViewControllerInit:self];
    }
    
    return self;
}
- (id)stats_init{

    [self stats_init];
    self.tracker = [[LMUIVCTracker alloc] initWithViewController:self];
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewControllerInit:)]) {
        
    
        [_trackerDelegate UIViewControllerInit:self];
    }
    
    
    return self;
}
- (void)stats_viewDidLoad {
    
    //DLog(@"stats_viewDidLoad: %@", NSStringFromClass(self.class));
    [self stats_viewDidLoad];
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewControllerViewDidLoad:)]) {
        
        [_trackerDelegate UIViewControllerViewDidLoad:self];
    }
    
    
}
- (void)stats_viewWillAppear:(BOOL)animated{
    
    //DLog(@"stats_viewWillAppear: %@", NSStringFromClass(self.class));
    [self stats_viewWillAppear:animated];
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewWillAppear:)]) {
        
        [_trackerDelegate UIViewController:self viewWillAppear:animated];
    }
    
}
- (void)stats_viewDidAppear:(BOOL)animated{
    
    //DLog(@"stats_viewDidAppear: %@", NSStringFromClass(self.class));
    [self stats_viewDidAppear:animated];
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewDidAppear:)]) {
     
        [_trackerDelegate UIViewController:self viewDidAppear:animated];
    }
    
}
- (void)stats_viewWillDisappear:(BOOL)animated{
    
    [self.tracker setVisible:YES];
    //DLog(@"stats_viewWillDisappear: %@", NSStringFromClass(self.class));
    [self stats_viewWillDisappear:animated];
    
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewWillDisappear:)]) {
        
        [_trackerDelegate UIViewController:self viewWillDisappear:animated];
    }
    
    
}
- (void)stats_viewDidDisappear:(BOOL)animated{
    
    //DLog(@"stats_viewDidDisappear: %@", NSStringFromClass(self.class));
    
    [self.tracker setVisible:NO];
    [self stats_viewDidDisappear:animated];
    
    
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewDidDisappear:)]) {
        
        [_trackerDelegate UIViewController:self viewDidDisappear:animated];
    }
}

@end

@implementation LMUIVCTracker

@synthesize viewController = _viewController;
@synthesize visible = _visible;

- (void)setVisible:(BOOL)visible{

    _visible = visible;
    
}
-(instancetype)initWithViewController:(UIViewController *)viewController{
    
    self = [super init];
    _viewController = viewController;
    
    return self;
}
- (void)dealloc{
    
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewControllerDidDealloc:)]) {
        
        [_trackerDelegate UIViewControllerDidDealloc:self.viewController];
    }
    
    
    
}
@end

