//
//  Created by Lukasz Margielewski on 05/06/15.
//

#import "UIViewController_LMStatsTracker.h"
#import "NSObject+Swizzle.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonDigest.h>

#define DLogLevel1 //DLogLevel1



@interface UIViewController(Private)

- (id)stats_initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle;

@end

@implementation UIViewController(LMStatsTracker)

static id<UIViewControllerStatsTracker> _statsTracker;

static char UIB_PROPERTY_KEY_DEALLOC_OBSERVER;

- (void)setTracker:(LMUIVCTracker *)tracker
{
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY_DEALLOC_OBSERVER, tracker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (LMUIVCTracker *)tracker{
    
    return objc_getAssociatedObject(self, &UIB_PROPERTY_KEY_DEALLOC_OBSERVER);
}


+ (void)setStatisticsTracker:(id<UIViewControllerStatsTracker>)startsTracer{

    @synchronized(self) { _statsTracker = startsTracer; }
}

+ (void)load {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        DLogLevel1(@"loading class: %@", NSStringFromClass([self class]));
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
    
    [_statsTracker UIViewControllerInit:self];
    return self;
}
- (id)stats_init{

    [self stats_init];
    self.tracker = [[LMUIVCTracker alloc] initWithViewController:self];
    [_statsTracker UIViewControllerInit:self];
    
    return self;
}
- (void)stats_viewDidLoad {
    
    //DLogLevel1(@"stats_viewDidLoad: %@", NSStringFromClass(self.class));
    [self stats_viewDidLoad];
    
    [_statsTracker UIViewController:self viewDidLoadWithTracker:self.tracker];
}
- (void)stats_viewWillAppear:(BOOL)animated{
    
    //DLogLevel1(@"stats_viewWillAppear: %@", NSStringFromClass(self.class));
    [self stats_viewWillAppear:animated];
    [_statsTracker UIViewController:self viewWillAppear:animated withTracker:self.tracker];
}
- (void)stats_viewDidAppear:(BOOL)animated{
    
    //DLogLevel1(@"stats_viewDidAppear: %@", NSStringFromClass(self.class));
    [self stats_viewDidAppear:animated];
     [_statsTracker UIViewController:self viewDidAppear:animated withTracker:self.tracker];
}
- (void)stats_viewWillDisappear:(BOOL)animated{
    
    //DLogLevel1(@"stats_viewWillDisappear: %@", NSStringFromClass(self.class));
    [self stats_viewWillDisappear:animated];
     [_statsTracker UIViewController:self viewWillDisappear:animated withTracker:self.tracker];
}
- (void)stats_viewDidDisappear:(BOOL)animated{
    
    //DLogLevel1(@"stats_viewDidDisappear: %@", NSStringFromClass(self.class));
    [self stats_viewDidDisappear:animated];
     [_statsTracker UIViewController:self viewDidDisappear:animated withTracker:self.tracker];
}

@end

@implementation LMUIVCTracker

@synthesize viewController = _viewController;
@synthesize viewControllerClass = _viewControllerClass;

-(instancetype)initWithViewController:(UIViewController *)viewController{
    
    self = [super init];
    _viewController = viewController;
    _viewControllerClass = viewController.class;
    
    return self;
}
- (void)dealloc{
    
    [_statsTracker UIViewController:self.viewController didDealocWithTracker:self];
    
}
- (NSString *)IDString{
    
    NSString *ids = _IDString;
    
    if (!ids) {
        NSDictionary *userInfo = self.userInfo;
        if (userInfo) {
            
            NSError *error;
            NSData *data = [NSJSONSerialization dataWithJSONObject:userInfo
                                                           options:0
                                                             error:&error];
            
            if (data && data.length) {
                
                
                unsigned char hash[CC_SHA1_DIGEST_LENGTH];
                if ( CC_SHA1([data bytes], (uint32_t)[data length], hash) ) {
                    
                    NSData *sha1 = [NSData dataWithBytes:hash length:CC_SHA1_DIGEST_LENGTH];
                    NSString* newStr = [sha1 base64EncodedStringWithOptions:0];
                    ids = newStr;//[NSString stringWithUTF8String:hash];
                    self.IDString = ids;
                }
                
                
                
            }
            
        }
    }
    return ids;
}
@end

