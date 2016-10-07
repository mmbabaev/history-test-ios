//
//  NSDate+Extension.m
//  DoubleB
//
//  Created by Balaban Alexander on 16/09/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

+ (NSDate *)dateFromString:(NSString *)stringDate format:(NSString *)format {
    static NSDateFormatter *formatter;
    
    if (!formatter) {
        formatter = [NSDateFormatter new];
    }
    
    formatter.dateFormat = format;
    return [formatter dateFromString:stringDate];
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    static NSDateFormatter *formatter;
    
    if (!formatter) {
        formatter = [NSDateFormatter new];
    }
    
    formatter.dateFormat = format;
    return [formatter stringFromDate:date];
}

- (NSDateComponents *)getComponents:(NSDate *)another {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:another toDate:self options:NSCalendarWrapComponents];
    return components;
    
}

- (NSInteger)numberOfDaysUntil:(NSDate *)another {
    return [[another getComponents:self] day];
}

- (NSInteger)numberOfSecondsUntil:(NSDate *)another {
    return [[another getComponents:self] second];
}

@end
