//
//  DBDeliveryType.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 25.05.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBTimeSlot;

typedef NS_ENUM(NSUInteger, DeliveryTypeId) {
    DeliveryTypeIdShipping = 2,
    DeliveryTypeIdInRestaurant = 1,
    DeliveryTypeIdTakeaway = 0
};

typedef NS_ENUM(NSUInteger, TimeMode) {
    TimeModeTime = 1 << 0,
    TimeModeDateTime = 1 << 1,
    TimeModeSlots = 1 << 2,
    TimeModeDateSlots = 1 << 3,
    TimeModeDual = 1 << 4,
};


@interface DBDeliveryType : NSObject<NSCoding>
@property (nonatomic) DeliveryTypeId typeId;
@property (strong, nonatomic) NSString *typeName;
@property (nonatomic) BOOL defaultType;

@property (nonatomic) double minOrderSum;

@property (nonatomic) TimeMode timeMode;

@property (nonatomic) int minTimeInterval;
@property (nonatomic) int maxTimeInterval;

@property (strong, nonatomic, readonly) NSDate *minDate;
@property (strong, nonatomic, readonly) NSDate *maxDate;

@property (strong, nonatomic) NSArray *timeSlots;
@property (strong, nonatomic) NSArray *timeSlotsNames;

@property (nonatomic) TimeMode dualCurrentMode;

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict;

- (DBTimeSlot *)timeSlotWithName:(NSString *)name;
@end


@interface DBTimeSlot : NSObject<NSCoding>
@property (strong, nonatomic) NSString *slotId;
@property (strong, nonatomic) NSString *slotTitle;
@property (strong, nonatomic) NSDictionary *slotDict;
@property (nonatomic) BOOL isDefaultSlot;

- (instancetype)initWithResponseDict:(NSDictionary *)responseDict;
@end
