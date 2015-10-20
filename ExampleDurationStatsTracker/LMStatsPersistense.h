//
//  LMStatsPersistense.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 19/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LMStatsTracker.h"

@class LMStatsPersistense;

@protocol LMStatsPersistenseObserver <NSObject>

- (void)LMStatsPersistense:(LMStatsPersistense *)statsPersistence
                         didSaveNewStats:(NSArray<LMStats *> *)stats
                                  toFile:(NSString *)filePath;

@end


@interface LMStatsPersistense : NSObject<LMStatsTrackerPersistanceProtocol>

@property (nonatomic, assign) id<LMStatsPersistenseObserver>observer;

- (NSArray *)allSavedStats;
- (BOOL)deleteAllSavedStats;

- (void)debugLogAllSavedStats;


@end
