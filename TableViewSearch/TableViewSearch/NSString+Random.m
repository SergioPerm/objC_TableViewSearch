//
//  NSString+Random.m
//  TableViewSearch
//
//  Created by kluv on 24/03/2020.
//  Copyright © 2020 com.kluv.hw24. All rights reserved.
//

#import "NSString+Random.h"

 @implementation NSString (Random)

+ (NSString *)randomAlphanumericString {
    
    int length = arc4random() % 11 + 5;
    
    return [self randomAlphanumericStringWithLength:length];
    
}

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];

    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }

    return randomString;
}

@end
