//
//  IHMenuProductModifierItem.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPositionModifier;

@interface DBMenuPositionModifierItem : NSObject<NSCopying, NSCoding>

@property (strong, nonatomic) NSString *itemId;
@property (strong, nonatomic) NSString *itemName;
@property (nonatomic) double itemPrice;
@property (nonatomic) NSInteger order;
@property (nonatomic) NSArray *prices;
@property (strong, nonatomic) NSDictionary *itemDictionary;

+ (DBMenuPositionModifierItem *)itemFromDictionary:(NSDictionary *)itemDictionary;
@end
