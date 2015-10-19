//
//  NSDictionary+UrlEncoding.h
//  UIVCTrackingExample
//
//  Created by Lukasz Margielewski on 19/10/15.
//  Copyright © 2015 Lukasz Margielewski. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (UrlEncoding)

- (NSString *)stringWithKeyValueSeparator:(NSString *)keyValueSeparator
                        valuesSeparator:(NSString *)valuesSeparator
                              urlEncode:(BOOL)urlEncode;

- (NSString *)getUrlEncodedString;

@end
