//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import "UIViewController+LMUIVCTracker.h"
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>

#define DLog //DLog

@interface LMUIVCTracker()
- (void)setVisible:(BOOL)visible;

@end

@interface UIViewController()

//- (id)stats_initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle;

@end

@implementation UIViewController(LMUIVCTracker)

static id<LMUIVCTrackerDelegate> _trackerDelegate;

static char UIB_PROPERTY_KEY_DEALLOC_OBSERVER;

- (void)setTracker:(LMUIVCTracker *)tracker
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY_DEALLOC_OBSERVER, tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LMUIVCTracker *)tracker{
    
    return objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_DEALLOC_OBSERVER);
}


+ (void)setTrackerDelegate:(id<LMUIVCTrackerDelegate>)startsTracer{

    @synchronized(self) { _trackerDelegate = startsTracer; }
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        DLog(@"loading class: %@", NSStringFromClass([self class]));
        //[self swizzleInstanceSelector:@selector(dealloc) withSelector:@selector(stats_dealloc)];
        [self swizzleInstanceSelector:@selector(viewDidLoad) withSelector:@selector(stats_viewDidLoad)];
        [self swizzleInstanceSelector:@selector(init) withSelector:@selector(stats_init)];
        [self swizzleInstanceSelector:@selector(initWithName:bundle:) withSelector:@selector(stats_initWithName:bundle:)];
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
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewDidLoadWithTracker:)]) {
        
        [_trackerDelegate UIViewController:self viewDidLoadWithTracker:self.tracker];
    }
    
    
}
- (void)stats_viewWillAppear:(BOOL)animated{
    
    //DLog(@"stats_viewWillAppear: %@", NSStringFromClass(self.class));
    [self stats_viewWillAppear:animated];
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewWillAppear:withTracker:)]) {
        
        [_trackerDelegate UIViewController:self viewWillAppear:animated withTracker:self.tracker];
    }
    
}
- (void)stats_viewDidAppear:(BOOL)animated{
    
    //DLog(@"stats_viewDidAppear: %@", NSStringFromClass(self.class));
    [self stats_viewDidAppear:animated];
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewDidAppear:withTracker:)]) {
     
        [_trackerDelegate UIViewController:self viewDidAppear:animated withTracker:self.tracker];
    }
    
}
- (void)stats_viewWillDisappear:(BOOL)animated{
    
    [self.tracker setVisible:YES];
    //DLog(@"stats_viewWillDisappear: %@", NSStringFromClass(self.class));
    [self stats_viewWillDisappear:animated];
    
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewWillDisappear:withTracker:)]) {
        
        [_trackerDelegate UIViewController:self viewWillDisappear:animated withTracker:self.tracker];
    }
    
    
}
- (void)stats_viewDidDisappear:(BOOL)animated{
    
    //DLog(@"stats_viewDidDisappear: %@", NSStringFromClass(self.class));
    
    [self.tracker setVisible:NO];
    [self stats_viewDidDisappear:animated];
    
    
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:viewDidDisappear:withTracker:)]) {
        
        [_trackerDelegate UIViewController:self viewDidDisappear:animated withTracker:self.tracker];
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
    
    
    if (_trackerDelegate && [_trackerDelegate respondsToSelector:@selector(UIViewController:didDealocWithTracker:)]) {
        
        [_trackerDelegate UIViewController:self.viewController didDealocWithTracker:self];
    }
    
    
    
}
@end

