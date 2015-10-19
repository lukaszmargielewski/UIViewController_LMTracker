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
- (NSString *)keyForTrackedObject:(id)trackedObject{

    uintptr_t pointer_as_integer = (uintptr_t)trackedObject;
    NSString *pointerKey = [NSString stringWithFormat:@"pointer_%li", pointer_as_integer];
    return pointerKey;
    
}


#pragma mark - Delegate Metods:

- (void)UIViewController:(UIViewController *)viewController
    didDealocWithTracker:(LMUIVCTracker *)tracker{

    NSString *iString = [(NSDictionary *)tracker.userInfo stringWithKeyValueSeparator:@"=" valuesSeparator:@", " urlEncode:NO];
    
    NSLog(@"%@ will dealloc with user info: %@", NSStringFromClass(viewController.class), iString);
    
    [self debugLogAllDurations];
    

}

- (LMStatsTrackerDuration *)statsForViewController:(UIViewController *)viewController
                                           tracker:(LMUIVCTracker *)tracker
                                    createIfNeeded:(BOOL)createIfNeeded{

    NSString *pointerKey = [self keyForTrackedObject:viewController];
    LMStatsTrackerDuration *stats = self.trackingDictionary[pointerKey];
    
    if (!stats && createIfNeeded && tracker.userInfo) {
        
        stats = [[LMStatsTrackerDuration alloc] initStatsForUserInfo:tracker.userInfo];
        self.trackingDictionary[pointerKey] = stats;
    }
    
    return stats;
}


- (void)UIViewController:(UIViewController *)viewController
          viewDidAppear:(BOOL)animated
             withTracker:(LMUIVCTracker *)tracker{
    
    
    LMStatsTrackerDuration *stats = [self statsForViewController:viewController tracker:tracker createIfNeeded:YES];
    [stats resumeTime];
    
}

- (void)UIViewController:(UIViewController *)viewController
       viewWillDisappear:(BOOL)animated
             withTracker:(LMUIVCTracker *)tracker{
    
    NSDictionary *statsInfo = (NSDictionary *)tracker.userInfo;
    
    if(!statsInfo){
        return;
    }
    
    NSString *iString = [(NSDictionary *)tracker.userInfo stringWithKeyValueSeparator:@"=" valuesSeparator:@", " urlEncode:NO];
    
    
    NSLog(@"MIHStatsTracker %@ viewWillDisappear: %@", NSStringFromClass(viewController.class), iString);
    
    LMStatsTrackerDuration *stats = [self statsForViewController:viewController tracker:tracker createIfNeeded:NO];
    [stats pauseTime];
}


#pragma mark - App Notifications:

- (void)appDidEnterBackground:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self reportAll];

}
- (void)appWillEnterForegound:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
}

- (void)appDidBecomeActive:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self resumeAll];
}
- (void)appWillResignActive:(NSNotification *)notification{

    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self pauseAll];

}

- (void)appWillTerminate:(NSNotification *)notification{
    
    NSLog(@"%@" , NSStringFromSelector(_cmd));
    [self reportAll];
    
}


#pragma mark - Time:

- (void)debugLogAllDurations{

    int i = 1;
    
    NSLog(@"");
    NSLog(@"++++++++++++++ Debug stats START ++++++++++++++++");
    
    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsTrackerDuration *durationStats = self.trackingDictionary[key];
        NSString *iString = [(NSDictionary *)durationStats.userInfo stringWithKeyValueSeparator:@"=" valuesSeparator:@", " urlEncode:NO];
        
        NSLog(@"%i. %@ => %.2f sec", i, iString, durationStats.duration);
        i++;
    }
    
    
    NSLog(@"++++++++++++++ Debug stats START ++++++++++++++++");
    NSLog(@"");
    
}
- (void)pauseAll{

    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsTrackerDuration *durationStats = self.trackingDictionary[key];

        [durationStats pauseTime];
    }
    
}
- (void)resumeAll{

    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsTrackerDuration *durationStats = self.trackingDictionary[key];
        
        [durationStats resumeTime];
    }
}
- (void)resetAll{
    
    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsTrackerDuration *durationStats = self.trackingDictionary[key];
        
        [durationStats resetTime];
    }
    
}



#pragma mark - Reporting:

- (NSSet *)getAllStartsAsSet{

    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:self.trackingDictionary.allKeys.count];
    
    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsTrackerDuration *durationStats = self.trackingDictionary[key];
        [durationStats updateDuration];
        [set addObject:[durationStats copy]];
    }
    
    return set;
}
- (void)reportAll{


    [self debugLogAllDurations];
    
    if (_reporter) {
        BOOL shouldResetDurations = [_reporter LMStatsTracker:self
                                            reportsStatistics:[self getAllStartsAsSet]];
        if (shouldResetDurations) {
            [self resetAll];
        }
    }
    
}

@end
