//
//  OrderItem.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 06.12.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPosition;
@interface OrderItem : NSObject <NSCoding, NSCopying>

@property (strong, nonatomic) DBMenuPosition *position;
@property (nonatomic, readonly) double totalPrice;
@property (nonatomic) NSInteger count;

// Valid only if position currently available in menu
@property (nonatomic, readonly) BOOL valid;

- (instancetype)initWithPosition:(DBMenuPosition *)position;

+ (instancetype)orderItemFromResponceDict:(NSDictionary *)dict;

- (NSDictionary *)requestJson;

@end


@interface OrderItemGift : OrderItem
@property (nonatomic) BOOL enabled;
@end