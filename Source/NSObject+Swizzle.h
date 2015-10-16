//
//  Created by Lukasz Margielewski on 02/06/15.
//

#import <Foundation/Foundation.h>

@interface NSObject(Swizzle)

+ (void)swizzleClassSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;
+ (void)swizzleInstanceSelector:(SEL)originalSelector withSelector:(SEL)swizzledSelector;

@end
