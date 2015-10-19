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

- (void)UIViewController:(UIViewController *)viewController
    didDealocWithTracker:(LMUIVCTracker *)tracker{
    
    LMStatsDuration *stats = [self statsForViewController:viewController tracker:tracker createIfNeeded:NO];
    
    if (stats) {

        stats.visible = NO;
        [stats pauseTime];
        
        NSLog(@"%@ will dealloc with user info: %@", NSStringFromClass(viewController.class), stats.identifierString);
        [self debugLogAllDurations];
    }
}

- (LMStatsDuration *)statsForViewController:(UIViewController *)viewController
                                           tracker:(LMUIVCTracker *)tracker
                                    createIfNeeded:(BOOL)createIfNeeded{

    NSDictionary *userInfo = (NSDictionary *)tracker.userInfo;
    
    if(!userInfo){
        return nil;
    }
    
    
    uintptr_t pointer_as_integer = (uintptr_t)viewController;
    NSString *pointerKey = [NSString stringWithFormat:@"pointer_%li", pointer_as_integer];
    NSString *key = pointerKey;
    
    
    // DISCUSSION:
    // In this tracking mechanism, userInfo decides about identity (not the object pointer):
    NSString *iString = [userInfo stringWithKeyValueSeparator:@"_" valuesSeparator:@"," urlEncode:NO];
    //NSString *key = iString;
    
    LMStatsDuration *stats = self.trackingDictionary[key];
    
    if (!stats && createIfNeeded && tracker.userInfo) {
        
        stats = [[LMStatsDuration alloc] initStatsForUserInfo:tracker.userInfo identifierString:iString];
        self.trackingDictionary[key] = stats;
    }

    return stats;
}


- (void)UIViewController:(UIViewController *)viewController
          viewDidAppear:(BOOL)animated
             withTracker:(LMUIVCTracker *)tracker{
    
    
    LMStatsDuration *stats = [self statsForViewController:viewController tracker:tracker createIfNeeded:YES];
    stats.visible = YES;
    [stats resumeTime];
    
}

- (void)UIViewController:(UIViewController *)viewController
       viewWillDisappear:(BOOL)animated
             withTracker:(LMUIVCTracker *)tracker{
    
    NSDictionary *statsInfo = (NSDictionary *)tracker.userInfo;
    
    if(!statsInfo){
        return;
    }
    
    
    LMStatsDuration *stats = [self statsForViewController:viewController tracker:tracker createIfNeeded:NO];
    stats.visible = NO;
    NSLog(@"MIHStatsTracker %@ viewWillDisappear: %@", NSStringFromClass(viewController.class), stats.identifierString);
    
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
    [self resumeAllVisible];
    [self debugLogAllDurations];
    
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

    
    
    NSArray *allKeys = self.trackingDictionary.allKeys;
    
    if (allKeys.count) {
       
        int i = 1;
        NSLog(@"");
        NSLog(@"++++++++++++++++++++++++++++++");
        
        for (NSString *key in allKeys) {
            
            LMStatsDuration *ds = self.trackingDictionary[key];
            NSLog(@"%i. %@ => %.2f count: %i (v: %i, p: %i)", i, ds.identifierString, ds.duration, ds.resumeCount, ds.visible, ds.paused);
            i++;
        }
        
        
        NSLog(@"++++++++++++++++++++++++++++++");
        NSLog(@"");
    }
    
    
}
- (void)pauseAll{

    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsDuration *ds = self.trackingDictionary[key];

        [ds pauseTime];
    }
    
}
- (void)resumeAllVisible{

    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsDuration *ds = self.trackingDictionary[key];
        
        if (ds.visible) {
        
            [ds resumeTime];
        }
    }
}

- (void)resetAll{
    
    for (NSString *key in self.trackingDictionary.allKeys) {
        
        LMStatsDuration *ds = self.trackingDictionary[key];
        
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
        
        LMStatsDuration *ds = self.trackingDictionary[key];
        [ds updateDuration];
        [set addObject:[ds copy]];
    }
    
    return [set allObjects];
}
- (void)reportAll{


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
