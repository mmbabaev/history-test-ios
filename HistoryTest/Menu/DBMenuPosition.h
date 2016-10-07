//
//  IHMenuProduct.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Venue;

typedef NS_ENUM(NSInteger, DBMenuPositionMode){
    DBMenuPositionModeRegular = 0,
    DBMenuPositionModeBonus,
    DBMenuPositionModeGift
};

@interface DBMenuPosition : NSObject<NSCopying, NSCoding>

// mutable data(stored)
@property(nonatomic) DBMenuPositionMode mode;

// immutable(stored) data
@property(strong, nonatomic, readonly) NSString *positionId;
@property(strong, nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSInteger order;
@property(nonatomic) double price;
@property(nonatomic, readonly) double actualPrice;
@property(strong, nonatomic, readonly) NSString *imageUrl;
@property(strong, nonatomic, readonly) NSString *positionDescription;
@property(nonatomic, readonly) double energyAmount;
@property(nonatomic, readonly) double weight;
@property(nonatomic, readonly) double volume;
@property(nonatomic, readonly) double fiber;
@property(nonatomic, readonly) double fat;
@property(nonatomic, readonly) double carbohydrate;

@property(strong, nonatomic, readonly) NSMutableArray *groupModifiers;
@property(strong, nonatomic, readonly) NSMutableArray *singleModifiers;

@property(strong, nonatomic, readonly) NSDictionary *productDictionary;

// Layout settings
@property(strong, nonatomic) UIColor *backgroundColor;
@property(nonatomic) UIViewContentMode contentMode;


- (instancetype)initWithResponseDictionary:(NSDictionary *)positionDictionary;
- (void)synchronizeWithResponseDictionary:(NSDictionary *)positionDictionary;

- (void)syncWithPosition:(DBMenuPosition *)position;

// dynamic data(not stored)
@property(nonatomic, readonly) BOOL hasImage;
@property(nonatomic, readonly) BOOL hasEmptyRequiredModifiers;
- (BOOL)availableInVenue:(Venue *)venue;

// User actions
- (void)selectItem:(NSString *)itemId forGroupModifier:(NSString *)modifierId;
- (void)selectAllRequiredModifiers;

- (void)addSingleModifier:(NSString *)modifierId count:(NSInteger)count;

// Returns equality of initial data
// For full equality use isEqual:
- (BOOL)isSamePosition:(DBMenuPosition *)object;

@end

@interface DBMenuPosition (HistoryResponse)
- (instancetype)initWithHistoryDict:(NSDictionary *)positionDictionary;
@end
