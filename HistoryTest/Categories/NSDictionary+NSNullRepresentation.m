//
//  NSDictionary+NSNullRepresentation.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 25.07.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "NSDictionary+NSNullRepresentation.h"

@implementation NSDictionary (DBExtension)

- (id)getValueForKey:(NSString *)key{
    id value = [self valueForKey:key];
    if([[value class] isSubclassOfClass:[NSNull class]])
        value = nil;
    
    return value;
}

- (int)getIntForKey:(NSString *)key{
    int result;
    id value = [self valueForKey:key];
    if(![[value class] isSubclassOfClass:[NSNumber class]])
        result = 0;
    else
        result = [(NSNumber *)value intValue];
    
    return result;
}

+ (int)getIntValue:(NSNumber *)number{
    NSNumber *resultNumber = number;
    if(!resultNumber)
        resultNumber = @(0);
    
    return [resultNumber intValue];
}

@end
