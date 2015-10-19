//
//  NSDictionary+UrlEncoding.m
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 19/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import "NSDictionary+UrlEncoding.h"

// helper function: get the string form of any object
static NSString *toString(id object) {
    return [NSString stringWithFormat: @"%@", object];
}

// helper function: get the url encoded string form of any object
static NSString *urlEncodedString(id object) {
    NSString *string = toString(object);
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

@implementation NSDictionary (UrlEncoding)

- (NSString *)getUrlEncodedString{

    return [self stringWithKeyValueSeparator:@"=" valuesSeparator:@"&" urlEncode:YES];
}

- (NSString *)stringWithKeyValueSeparator:(NSString *)keyValueSeparator
                        valuesSeparator:(NSString *)valuesSeparator
                              urlEncode:(BOOL)urlEncode{
    
    NSAssert(keyValueSeparator != nil, @"keyValueSeparator must NOT be nil.");
    NSAssert(valuesSeparator != nil, @"valuesSeparator must NOT be nil.");
    
    NSMutableArray *parts = [NSMutableArray array];
    
    for (id key in self) {
        id value = [self objectForKey: key];
        
        NSString *part = [NSString stringWithFormat: @"%@%@%@", urlEncode ? urlEncodedString(key) : key, keyValueSeparator, urlEncode ? urlEncodedString(value) : toString(value)];
        [parts addObject: part];
    }
    return [parts componentsJoinedByString:valuesSeparator];
}

@end
