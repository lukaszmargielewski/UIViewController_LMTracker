//
//  LMStatsPersistense.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 19/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "LMStatsPersistense.h"
#import "NSDictionary+UrlEncoding.h"

#ifdef DEBUG
#define DLog NSLog
#else
#define DLog //
#endif

@interface LMStatsPersistense()

@property (nonatomic, readonly) NSString *directory;

@end
@implementation LMStatsPersistense
@synthesize directory = _directory;

- (BOOL)LMStatsTracker:(LMStatsTracker *)statsTracker persistStatistics:(NSArray *)statistics{


    if (!statistics || !statistics.count) {
        return NO;
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%f.stats", [NSDate date].timeIntervalSince1970];
    NSString *filePath = [self.directory stringByAppendingPathComponent:fileName];
    
    BOOL archived = [NSKeyedArchiver archiveRootObject:statistics toFile:filePath];
    
    if (archived) {
    
        [_observer LMStatsPersistense:self didSaveNewStats:statistics toFile:filePath];
    }
    
    return archived;
}

- (NSString *)directory{

    if (!_directory) {
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = paths[0];
        _directory = [documentsDirectory stringByAppendingPathComponent:@"LM_Stats"];
    }
    
    NSError *error = nil;
    BOOL dirExists = [[NSFileManager defaultManager] createDirectoryAtPath:_directory withIntermediateDirectories:YES attributes:nil error:&error];
    
    if (!dirExists) {
        
        _directory = nil;
        
    }
    
    return _directory;
}

- (NSArray *)allSavedStats{

    NSError *error = nil;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directory error:&error];
    
    
    int i = 0;
    int c = files.count;
    
    NSMutableArray *allParts = [[NSMutableArray alloc] init];
    
    //DLog(@"");
    //DLog(@"====================== SAVED %i FILES", c);
    for (NSString *fileName in files) {
        NSString *filePath = [self.directory stringByAppendingPathComponent:fileName];
        NSArray *partStats = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        [allParts addObjectsFromArray:partStats];
        
        i++;
        //DLog(@"%i/%i. file: %@ => %i stats", i, c, fileName, partStats.count);
    
        
        
    }
    
    return allParts;
}

- (BOOL)deleteAllSavedStats{


    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *files = [fm contentsOfDirectoryAtPath:self.directory error:&error];

        for (NSString *fileName in files) {
        
            NSString *filePath = [self.directory stringByAppendingPathComponent:fileName];
            [fm removeItemAtPath:filePath error:&error];
            if (error) {
                return NO;
            }
    }
    
    return YES;
}
- (void)debugLogAllSavedStats{

    NSArray *allParts = [self allSavedStats];
    
    int j = 1;
    
    NSLog(@"Merged %lu parts:", (unsigned long)allParts.count);
    for (LMStats *ds in allParts) {
        
        NSString *iString = [(NSDictionary *)ds.userInfo stringWithKeyValueSeparator:@": " valuesSeparator:@", " urlEncode:NO];
        
        NSLog(@"%i. [%@] => %.2f sec (count: %i)", j, iString, ds.duration, ds.resumeCount);
        j++;
    }
    
    
    if (allParts.count) {
    
        //DLog(@"======================");
        //DLog(@"");
    }
    
}
@end
