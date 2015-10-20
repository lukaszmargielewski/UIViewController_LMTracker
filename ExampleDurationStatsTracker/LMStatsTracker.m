//
//  Created by Lukasz Margielewski on 08/09/15.
//

#import "LMStatsTracker.h"
#import "NSDictionary+UrlEncoding.h"

@interface LMStatsTracker()
@property (nonatomic, strong) NSMutableDictionary *trackingDictionary;
@end

@implementation LMStatsTracker

- (instancetype)init{

    self = [super init];
    
    if (self) {
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        UIApplication *app = [UIApplication sharedApplication];
        
        [nc addObserver:self selector:@selector(appDidEnterBackground:)
                   name:UIApplicationDidEnterBackgroundNotification object:app];
        
        [nc addObserver:self selector:@selector(appWillEnterForegound:)
                   name:UIApplicationWillEnterForegroundNotification object:app];
        
        [nc addObserver:self selector:@selector(appDidBecomeActive:)
                   name:UIApplicationDidBecomeActiveNotification object:app];
        
        [nc addObserver:self selector:@selector(appWillResignActive:)
                   name:UIApplicationWillResignActiveNotification object:app];
        
        [nc addObserver:self selector:@selector(appWillTerminate:)
                   name:UIApplicationWillTerminateNotification object:app];
        
        
    }
    return self;
}
- (NSMutableDictionary *)trackingDictionary{

    if (!_trackingDictionary) {
        _trackingDictionary = [[NSMutableDictionary alloc] initWithCapacity:100];
    }
    
    return _trackingDictionary;
}



#pragma mark - Delegate Metods:

- (void)UIViewControllerDidDealloc:(UIViewController *)viewController{
    
    LMStats *stats = [self statsForViewController:viewController createIfNeeded:NO];
    
    if (stats) {

        if (viewController.trackedInfo) {
            
            [self removeStatsForViewController:viewController];
        }else{
        
            stats.visible = NO;
            [stats pauseTime];
            
        }
        
        NSString *iString = [(NSDictionary *)stats.userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
        
        NSLog(@"%@ will dealloc with user info: %@", NSStringFromClass(viewController.class), iString);
        [self debugLogAllDurations];
    }
}
- (NSString *)keyForViewController:(UIViewController *)viewController{

    uintptr_t pointer_as_integer = (uintptr_t)viewController;
    NSString *pointerKey = [NSString stringWithFormat:@"pointer_%li", pointer_as_integer];
    NSString *key = pointerKey;

    return key;
    
}

- (void)removeStatsForViewController:(UIViewController *)viewController{

    NSString *key = [self keyForViewController:viewController];
    [_trackingDictionary removeObjectForKey:key];
    
}
- (LMStats *)statsForViewController:(UIViewController *)viewController createIfNeeded:(BOOL)createIfNeeded{

    
    NSString *key = [self keyForViewController:viewController];
    
    LMStats *stats = self.trackingDictionary[key];
    
    if (!stats && createIfNeeded && viewController.trackedInfo) {
        
        stats = [[LMStats alloc] init];
        stats.userInfo = viewController.trackedInfo;
        stats.supportsDuration = YES;
        self.trackingDictionary[key] = stats;
    }

    return stats;
}
- (void)addStatsWithUserInfo:(NSDictionary *)userInfo{

    NSString *iString = [(NSDictionary *)userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    LMStats *stats = [[LMStats alloc] init];
    stats.userInfo = userInfo;
    NSString *key = [NSString stringWithFormat:@"manual_%@", iString];
    self.trackingDictionary[key] = stats;
    
}


- (void)UIViewController:(UIViewController *)viewController
          viewDidAppear:(BOOL)animated
            {
    
    LMStats *stats = [self statsForViewController:viewController createIfNeeded:YES];
    stats.visible = YES;
    [stats resumeTime];
    
}

- (void)UIViewController:(UIViewController *)viewController
       viewWillDisappear:(BOOL)animated
            {
    
    NSDictionary *statsInfo = viewController.trackedInfo;
    
    LMStats *stats = [self statsForViewController:viewController createIfNeeded:NO];
                
    if (!statsInfo) {
                    
            [self removeStatsForViewController:viewController];
        
    }else{
                    
        stats.visible = NO;
        [stats pauseTime];
        stats.userInfo = viewController.trackedInfo;
        
    }
                
    NSString *iString = [(NSDictionary *)stats.userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    NSLog(@"MIHStatsTracker %@ viewWillDisappear: %@", NSStringFromClass(viewController.class), iString);
    
    [stats pauseTime];
}


#pragma mark - App Notifications:

- (void)appDidEnterBackground:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self persistAllContainingUserInfo];

}
- (void)appWillEnterForegound:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
}

- (void)appDidBecomeActive:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self resumeAllVisible];
    [self debugLogAllDurations];
    
}
- (void)appWillResignActive:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self pauseAll];

}

- (void)appWillTerminate:(NSNotification *)notification{
    
    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self persistAllContainingUserInfo];
    
}


#pragma mark - Time:

- (void)debugLogAllDurations{

    
    
    NSArray *allKeys = self.trackingDictionary.allKeys;
    
    if (allKeys.count) {
       
        int i = 1;
        NSLog(@"");
        NSLog(@"++++++++++++++++++++++++++++++");
        
        for (NSString *key in allKeys) {
            
            LMStats *ds = self.trackingDictionary[key];
            NSString *iString = [(NSDictionary *)ds.userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
            
            NSLog(@"%i. %@ => %.2f count: %i (v: %i, p: %i)", i, iString, ds.duration, ds.resumeCount, ds.visible, ds.paused);
            i++;
        }
        
        
        NSLog(@"++++++++++++++++++++++++++++++");
        NSLog(@"");
    }
    
    
}
- (void)pauseAll{

    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStats *ds = self.trackingDictionary[key];

        [ds pauseTime];
    }
    
}
- (void)resumeAllVisible{

    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStats *ds = self.trackingDictionary[key];
        
        if (ds.visible) {
        
            [ds resumeTime];
        }
    }
}

- (void)resetAll{
    
    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStats *ds = self.trackingDictionary[key];
        
        if (ds.visible) {
        
            [ds resetDurationAndResumeCount];
            
        }else{
        
            [self.trackingDictionary removeObjectForKey:key];
        }
        
    }
    
}


#pragma mark - Reporting:

- (NSArray *)getAllStarts{

    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:self.trackingDictionary.allKeys.count];
    
    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStats *ds = self.trackingDictionary[key];
        if (ds.userInfo) {
        
            if(ds.visible){
                [ds updateDuration];
            }
            
            [set addObject:[ds copy]];
        }
        
    }
    
    return [set allObjects];
}
- (void)persistAllContainingUserInfo{


    [self debugLogAllDurations];
    
    if (_persistance) {
        BOOL shouldResetDurations = [_persistance LMStatsTracker:self
                                            persistStatistics:[self getAllStarts]];
        if (shouldResetDurations) {
            [self resetAll];
        }
    }
    
}

@end
