//
//  Created by Lukasz Margielewski on 08/09/15.
//

#import "LMStatsTracker.h"
#import "NSDictionary+UrlEncoding.h"

#ifdef DEBUG
    #define DLog NSLog
#else
    #define DLog //
#endif

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

- (void)UIViewController:(UIViewController *)viewController willDeallocWithTrackedInfo:(NSDictionary *)trackedInfo{
    
    
    // When UIViewController dealocates, its .trackedInfo property will be alraedy deallocated.
    // Therefore, use trackedInfo passed as method parameter instead....
    
    NSString *iString = [(NSDictionary *)trackedInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    //DLog(@"%@ will dealloc: %@ - start", NSStringFromClass(viewController.class), iString);

    
    [self pauseStatsForViewController:viewController trackedInfo:trackedInfo];

    iString = [(NSDictionary *)trackedInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    //DLog(@"%@ will dealloc: %@ - end", NSStringFromClass(viewController.class), iString);

    
    [self debugLogAllDurations];
    
}
- (void)UIViewController:(UIViewController *)viewController viewDidAppear:(BOOL)animated{
    
    LMStats *stats = [self statsForViewController:viewController createIfNeeded:YES];
    stats.visible = YES;
    [stats resumeTime];
    
}
- (void)UIViewController:(UIViewController *)viewController viewWillDisappear:(BOOL)animated{
    
    NSString *iString = [(NSDictionary *)viewController.tracker.trackedInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    //DLog(@"%@ viewWillDisappear - start: %@", NSStringFromClass(viewController.class), iString);
    
    [self pauseStatsForViewController:viewController trackedInfo:viewController.tracker.trackedInfo];
    
    iString = [(NSDictionary *)viewController.tracker.trackedInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    //DLog(@"%@ viewWillDisappear - end: %@", NSStringFromClass(viewController.class), iString);
}


#pragma mark - Stats Adding / Removing:

- (NSString *)keyForViewController:(UIViewController *)viewController{
    
    uintptr_t pointer_as_integer = (uintptr_t)viewController;
    NSString *pointerKey = [NSString stringWithFormat:@"pointer_%li", pointer_as_integer];
    NSString *key = pointerKey;
    
    return key;
    
}

- (void)pauseStatsForViewController:(UIViewController *)viewController
                        trackedInfo:(NSDictionary *)trackedInfo{

    NSDictionary *statsInfo = trackedInfo;
    
    if (!statsInfo) {
        
        [self removeStatsForViewController:viewController];
        
    }else{
        
        LMStats *stats = [self statsForViewController:viewController createIfNeeded:NO];
        stats.visible = NO;
        [stats pauseTime];
        
        // Update tracked info (just in case it changed in the meantime.
        stats.userInfo = trackedInfo;
        
    }
    
}
- (void)removeStatsForViewController:(UIViewController *)viewController{

    NSString *key = [self keyForViewController:viewController];
    [_trackingDictionary removeObjectForKey:key];
    
}

- (LMStats *)statsForViewController:(UIViewController *)viewController createIfNeeded:(BOOL)createIfNeeded{

    
    NSString *key = [self keyForViewController:viewController];
    
    LMStats *stats = self.trackingDictionary[key];
    
    if (!stats && createIfNeeded && viewController.tracker.trackedInfo) {
        
        stats = [[LMStats alloc] init];
        stats.userInfo = viewController.tracker.trackedInfo;
        stats.supportsDuration = YES;
        self.trackingDictionary[key] = stats;
    }

    return stats;
}


#pragma mark - Public API:

- (void)addStatsWithUserInfo:(NSDictionary *)userInfo{

    NSString *iString = [(NSDictionary *)userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    LMStats *stats = [[LMStats alloc] init];
    stats.userInfo = userInfo;
    NSString *key = [NSString stringWithFormat:@"manual_%@", iString];
    self.trackingDictionary[key] = stats;
    
}


#pragma mark - App Notifications:

- (void)appDidEnterBackground:(NSNotification *)notification{

    //DLog(@"%@" , NSStringFromSelector(_cmd));
    [self persistAllContainingUserInfo];

}
- (void)appWillEnterForegound:(NSNotification *)notification{

    //DLog(@"%@" , NSStringFromSelector(_cmd));
}

- (void)appDidBecomeActive:(NSNotification *)notification{

    //DLog(@"%@" , NSStringFromSelector(_cmd));
    [self resumeAllVisible];
    [self debugLogAllDurations];
    
}
- (void)appWillResignActive:(NSNotification *)notification{

    //DLog(@"%@" , NSStringFromSelector(_cmd));
    [self pauseAll];

}

- (void)appWillTerminate:(NSNotification *)notification{
    
    //DLog(@"%@" , NSStringFromSelector(_cmd));
    [self persistAllContainingUserInfo];
    
}


#pragma mark - Time:

- (void)debugLogAllDurations{

    
    
    NSArray *allKeys = self.trackingDictionary.allKeys;
    
    if (allKeys.count) {
       
        int i = 1;
        //DLog(@"");
        //DLog(@"++++++++++++++++++++++++++++++");
        
        for (NSString *key in allKeys) {
            
            LMStats *ds = self.trackingDictionary[key];
            NSString *iString = [(NSDictionary *)ds.userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
            
            //DLog(@"%i. %@ => %.2f count: %i (v: %i, p: %i)", i, iString, ds.duration, ds.resumeCount, ds.visible, ds.paused);
            i++;
        }
        
        
        //DLog(@"++++++++++++++++++++++++++++++");
        //DLog(@"");
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
