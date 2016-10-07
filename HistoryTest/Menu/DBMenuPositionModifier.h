//
//  IHMenuProductModifier.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBMenuPositionModifierItem;

typedef NS_ENUM(NSInteger, ModifierType) {
    ModifierTypeGroup = 0,
    ModifierTypeSingle = 1
};

@interface DBMenuPositionModifier : NSObject<NSCopying>
@property (nonatomic, readonly) double actualPrice;

@property (nonatomic, readonly) ModifierType modifierType;
@property (strong, nonatomic, readonly) NSString *modifierId;
@property (strong, nonatomic, readonly) NSString *modifierName;
@property (strong, nonatomic, readonly) NSDictionary *modifierDictionary;

// Only for Single modifier
@property (nonatomic, readonly) double modifierPrice;
@property (nonatomic, readonly) NSInteger maxAmount;
@property (nonatomic, readonly) NSInteger minAmount;
@property (nonatomic, readonly) NSInteger order;
@property (nonatomic) int selectedCount;

//Only for Group modifiers
@property (nonatomic) BOOL required;
@property (strong, nonatomic, readonly) NSMutableArray *items;

@property (strong, nonatomic, readonly) DBMenuPositionModifierItem *selectedItem;
@property (nonatomic, readonly) BOOL itemSelectedByUser;

// Single
+ (DBMenuPositionModifier *)singleModifierFromDictionary:(NSDictionary *)modifierDictionary;

// Group
+ (DBMenuPositionModifier *)groupModifierFromDictionary:(NSDictionary *)modifierDictionary;

- (BOOL)synchronizeGroupModifierWithDictionary:(NSDictionary *)modifierDictionary;

- (void)selectItemAtIndex:(NSInteger)index;
- (void)selectItemById:(NSString *)itemId;
- (void)selectDefaultItem;
- (void)selectNothing;

// Both

// Returns equality of initial data
// For full equality use isEqual:
- (BOOL)isSameModifier:(DBMenuPositionModifier *)object;

@end
