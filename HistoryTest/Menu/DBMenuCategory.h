//
//  IHMenuCategory.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class Venue;
@class DBMenuPosition;
@class DBMenuPositionSearchResult;

typedef NS_ENUM(NSInteger, DBMenuCategoryType) {
    DBMenuCategoryTypeParent = 0,
    DBMenuCategoryTypeStandart = 1
};

@interface DBMenuCategory : NSObject
@property(strong, nonatomic, readonly) NSString *categoryId;
@property(strong, nonatomic, readonly) NSString *name;
@property(nonatomic, readonly) NSInteger order;
@property(strong, nonatomic, readonly) NSString *imageUrl;

@property(strong, nonatomic) NSMutableArray *categories;
@property(strong, nonatomic) NSMutableArray *positions;

@property(strong, nonatomic, readonly) NSArray *venuesRestrictions;

@property(strong, nonatomic, readonly) NSDictionary *categoryDictionary;

// Not stored data
@property(nonatomic) DBMenuCategoryType type;
@property(nonatomic, readonly) BOOL hasImage;
@property(nonatomic, readonly) BOOL categoryWithImages;

// Layout settings
@property(strong, nonatomic) UIColor *backgroundColor;
@property(nonatomic) UIViewContentMode contentMode;

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary;
- (void)synchronizeWithResponseDictionary:(NSDictionary *)categoryDictionary;

/**
 * Check if category is available for specified venue
 */
- (BOOL)availableInVenue:(Venue *)venue;

/**
 * Get all positions from category and subcategories
 */
- (NSArray *)getAllPositions;

/**
 * return all positions that are available for specified venue
 */
- (NSMutableArray *)filterPositionsForVenue:(Venue *)venue;

/**
 * Filter nested categories for venue
 */
- (NSMutableArray *)filterCategoriesForVenue:(Venue *)venue excludeCategories:(BOOL)excludeCategories;

/**
 * Find DBMenuPosition object for specified id
 */
- (DBMenuPosition *)findPositionWithId:(NSString *)positionId;

/**
 * Return trace of DBMenuCategory object for specified position, that starts from current category
 */
- (NSArray *)traceForPosition:(DBMenuPosition *)position;

/**
 * Filter category by text (search in categories and positions names) and return [DBMenuPositionSearchResult]
 */
- (NSArray *)filterPositions:(NSString *)text venue:(Venue *)venue currentResult:(DBMenuPositionSearchResult *)searchResult;

@end
