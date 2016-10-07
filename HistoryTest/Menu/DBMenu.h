//
//  IHMenu.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Venue;
@class DBMenuCategory;
@class DBMenuPosition;
@class DBMenuPositionBalance;

typedef NS_ENUM(NSInteger, DBMenuType) {
    DBMenuTypeSimple = 0,
    DBMenuTypeSkeleton
};


@interface DBMenu : NSObject

@property(nonatomic, readonly) BOOL hasNestedCategories;
@property(nonatomic, readonly) BOOL hasImages;
@property(nonatomic, readonly) BOOL hasModifiers;

+ (instancetype)sharedInstance;
+ (DBMenuType)type;

- (NSArray *)getMenu;
- (NSArray *)getMenuForVenue:(Venue *)venue;

/**
 * Update, synchronize and cache whole menu
 */
- (void)updateMenu:(void (^)(BOOL success, NSArray *categories))сallback;

/**
 * Update all positions for specified category
 */
- (void)updateCategory:(DBMenuCategory *)category callback:(void(^)(BOOL success))callback;

/**
 * Update balance of position in all venues
 */
- (void)updatePositionBalance:(DBMenuPosition *)position callback:(void(^)(BOOL success, NSArray *balance))callback;



/**
 * Synchronize menu position with position(all user actions)
 */
- (void)syncWithPosition:(DBMenuPosition *)position;



/**
 * Find DBMenuPosition object for specified id
 */
- (DBMenuPosition *)findPositionWithId:(NSString *)positionId;

/**
 * Return trace of DBMenuCategory object for specified position
 */
- (NSArray *)traceForPosition:(DBMenuPosition *)position;

/**
 * Filter menu by text (search in categories and positions names) and return [DBMenuPositionSearchResult]
 */
- (NSArray *)filterPositions:(NSString *)text venue:(Venue *)venue;



- (void)saveMenuToDeviceMemory;
- (void)clearMenu;

@end

@interface DBMenuPositionBalance: NSObject
@property (strong, nonatomic) Venue *venue;
@property (nonatomic) NSInteger balance;
@end

@interface DBMenuPositionSearchResult: NSObject
@property (strong, nonatomic) NSMutableArray *pathCategories;
@property (strong, nonatomic) NSMutableArray *positions;
@end
