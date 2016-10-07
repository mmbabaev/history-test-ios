//
//  IHMenuCategory.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "Venue.h"
#import "NSDictionary+NSNullRepresentation.h"
#import "UIColor+Hex.h"

@interface DBMenuCategory ()<NSCoding, NSCopying>
@property(strong, nonatomic) NSString *categoryId;
@property(strong, nonatomic) NSString *name;
@property(nonatomic) NSInteger order;
@property(strong, nonatomic) NSString *imageUrl;
@property(strong, nonatomic) NSDictionary *categoryDictionary;
@end

@implementation DBMenuCategory

+ (instancetype)categoryFromResponseDictionary:(NSDictionary *)categoryDictionary{
    DBMenuCategory *category = [DBMenuCategory new];
    
    [category copyFromResponseDictionary:categoryDictionary[@"info"]];
    
    category.positions = [[NSMutableArray alloc] init];
    for(NSDictionary *position in categoryDictionary[@"items"])
        [category.positions addObject:[[DBMenuPosition alloc] initWithResponseDictionary:position]];
    [category sortPositions];
 
    category.categories = [[NSMutableArray alloc] init];
    for(NSDictionary *nestedCategory in categoryDictionary[@"categories"])
        [category.categories addObject:[DBMenuCategory categoryFromResponseDictionary:nestedCategory]];
    [category sortCategories];
    
    [category checkImage];
    
    return category;
}

- (void)synchronizeWithResponseDictionary:(NSDictionary *)categoryDictionary{
    [self copyFromResponseDictionary:categoryDictionary[@"info"]];
    
    NSMutableArray *positions = [[NSMutableArray alloc] init];
    for(NSDictionary *remotePosition in categoryDictionary[@"items"]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", remotePosition[@"id"]];
        DBMenuPosition *samePosition = [[_positions filteredArrayUsingPredicate:predicate] firstObject];
        if(samePosition){
            [samePosition synchronizeWithResponseDictionary:remotePosition];
            [positions addObject:samePosition];
        } else {
            [positions addObject:[[DBMenuPosition alloc] initWithResponseDictionary:remotePosition]];
        }
    }
    _positions = positions;
    [self sortPositions];
 
    NSMutableArray *nestedCategories = [[NSMutableArray alloc] init];
    for(NSDictionary *remoteCategory in categoryDictionary[@"categories"]){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", remoteCategory[@"info"][@"category_id"]];
        DBMenuCategory *sameCategory = [[_categories filteredArrayUsingPredicate:predicate] firstObject];
        if(sameCategory){
            [sameCategory synchronizeWithResponseDictionary:remoteCategory];
            [nestedCategories addObject:sameCategory];
        } else {
            [nestedCategories addObject:[DBMenuCategory categoryFromResponseDictionary:remoteCategory]];
        }
    }
    _categories = nestedCategories;
    [self sortCategories];
    
    [self checkImage];
}

- (void)copyFromResponseDictionary:(NSDictionary *)categoryDictionary{
    _categoryId = [categoryDictionary getValueForKey:@"category_id"] ?: @"";
    _name = [categoryDictionary getValueForKey:@"title"] ?: @"";
    _order = [[categoryDictionary getValueForKey:@"order"] integerValue];
    _imageUrl = [categoryDictionary getValueForKey:@"pic"] ?: @"";
    _venuesRestrictions = [categoryDictionary[@"restrictions"] getValueForKey:@"venues"] ?: @[];
    _categoryDictionary = categoryDictionary;
}

- (void)checkImage {
    if(self.imageUrl.length == 0){
        if(self.type == DBMenuCategoryTypeParent)
            self.imageUrl = ((DBMenuCategory *)self.categories.firstObject).imageUrl;
        else
            self.imageUrl = ((DBMenuPosition *)self.positions.firstObject).imageUrl;
    }
}

- (void)sortCategories{
    [self.categories sortUsingComparator:^NSComparisonResult(DBMenuCategory *obj1, DBMenuCategory *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
}

- (void)sortPositions{
    [self.positions sortUsingComparator:^NSComparisonResult(DBMenuPosition *obj1, DBMenuPosition *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
}

- (DBMenuCategoryType)type{
    return [self.categories count] > 0 ? DBMenuCategoryTypeParent : DBMenuCategoryTypeStandart;
}

- (BOOL)hasImage{
    BOOL result = self.imageUrl != nil;
    if(result){
        result = result && self.imageUrl.length > 0;
    }
    return result;
}

- (BOOL)categoryWithImages{
    BOOL result = NO;
    
    if (self.type == DBMenuCategoryTypeStandart){
        for(DBMenuPosition *position in self.positions){
            result = result || position.hasImage;
        }
    } else {
        for(DBMenuCategory *category in self.categories){
            result = result || category.hasImage;
        }
    }
    
    return result;
}

#pragma mark - Layout settings

- (UIColor *)backgroundColor {
    NSString *hexString = [self.categoryDictionary getValueForKey:@"pic_background"];
    if (hexString.length < 8) {
        hexString = [NSString stringWithFormat:@"FF%@", hexString];
    }
    return [UIColor fromHexString:hexString];
}

- (UIViewContentMode)contentMode {
    NSInteger mode = [[self.categoryDictionary getValueForKey:@"pic_resize"] integerValue];
    return mode == 0 ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
}

- (void)sortArray:(NSMutableArray *)array byField:(NSString *)field{
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:field ascending:YES];
    [array sortUsingDescriptors:@[sortDescriptor]];
}


- (BOOL)availableInVenue:(Venue *)venue{
    return (venue && ![_venuesRestrictions containsObject:venue.venueId]) || !venue;
}

- (NSArray *)getAllPositions {
    if (self.type == DBMenuCategoryTypeStandart) {
        return _positions;
    } else {
        NSMutableArray *positions = [NSMutableArray new];
        for (DBMenuCategory *cat in _categories) {
            [positions addObjectsFromArray:[cat getAllPositions]];
        }
        return positions;
    }
}

- (NSMutableArray *)filterPositionsForVenue:(Venue *)venue{
    NSMutableArray *venuePositions = [NSMutableArray new];
    
    for(DBMenuPosition *position in _positions){
        if([position availableInVenue:venue])
            [venuePositions addObject:position];
    }
    
    return venuePositions;
}

- (NSMutableArray *)filterCategoriesForVenue:(Venue *)venue excludeCategories:(BOOL)excludeCategories{
    NSMutableArray *venueCategories = [NSMutableArray new];
    
    for(DBMenuCategory *category in _categories){
        if([category availableInVenue:venue]) {
            category.positions = [category filterPositionsForVenue:venue];
            category.categories = [category filterCategoriesForVenue:venue excludeCategories:excludeCategories];
            if([category.categories count] > 0 || [category.positions count] > 0 || !excludeCategories){
                [venueCategories addObject:category];
            }
        }
    }
    
    return venueCategories;
}

- (DBMenuPosition *)findPositionWithId:(NSString *)positionId{
    DBMenuPosition *resultPosition;
    for(DBMenuCategory *category in self.categories){
        DBMenuPosition *position = [category findPositionWithId:positionId];
        if(position){
            resultPosition = position;
            break;
        }
    }
    
    if(!resultPosition){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", positionId];
        resultPosition = [[_positions filteredArrayUsingPredicate:predicate] firstObject];
    }
    
    return resultPosition;
}

- (NSArray *)traceForPosition:(DBMenuPosition *)position {
    NSArray *result;
    if (self.type == DBMenuCategoryTypeParent) {
        for(DBMenuCategory *category in self.categories){
            NSArray *trace = [category traceForPosition:position];
            if (trace.count > 0) {
                result = [@[self] arrayByAddingObjectsFromArray:trace];
            }
        }
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"positionId == %@", position.positionId];
        DBMenuPosition *filteredPosition = [[_positions filteredArrayUsingPredicate:predicate] firstObject];
        if (filteredPosition) {
            result = @[self];
        }
    }
    
    return result;
}
//
//- (NSArray *)filterPositions:(NSString *)text venue:(Venue *)venue currentResult:(DBMenuPositionSearchResult *)searchResult {
//    NSMutableArray *result = [NSMutableArray new];
//    
//    DBMenuPositionSearchResult *newSearchResult = [DBMenuPositionSearchResult new];
//    newSearchResult.pathCategories = [NSMutableArray arrayWithArray:searchResult.pathCategories];
//    [newSearchResult.pathCategories addObject:self.name];
//    
//    if (self.type == DBMenuCategoryTypeStandart){
//        NSArray *filtered;
//        if ([self.name containsString:text]) { // Get all positions from category
//            filtered = [NSArray arrayWithArray:self.positions];
//        } else { // Get only positions that contains search string
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name CONTAINS[cd] %@", text];
//            filtered = [self.positions filteredArrayUsingPredicate:predicate];
//        }
//        
//        for (DBMenuPosition *position in filtered) {
//            if ([position availableInVenue:venue]) {
//                [newSearchResult.positions addObject:position];
//            }
//        }
//        
//        if (newSearchResult.positions.count > 0) {
//            [result addObject:newSearchResult];
//        }
//    } else {
//        for(DBMenuCategory *category in self.categories){
//            if ([category availableInVenue:venue]) {
//                [result addObjectsFromArray:[category filterPositions:text venue:venue currentResult:newSearchResult]];
//            }
//        }
//    }
//    
//    return result;
//}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuCategory alloc] init];
    if(self != nil){
        _categoryId = [aDecoder decodeObjectForKey:@"categoryId"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _order = [[aDecoder decodeObjectForKey:@"order"] integerValue];
        _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        _categories = [aDecoder decodeObjectForKey:@"categories"];
        _positions = [aDecoder decodeObjectForKey:@"positions"];
        _categoryDictionary = [aDecoder decodeObjectForKey:@"categoryDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_categoryId forKey:@"categoryId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:@(_order) forKey:@"order"];
    [aCoder encodeObject:_imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:_categories forKey:@"categories"];
    [aCoder encodeObject:_positions forKey:@"positions"];
    [aCoder encodeObject:self.categoryDictionary forKey:@"categoryDictionary"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuCategory *copyCategory = [[[self class] allocWithZone:zone] init];
    copyCategory.categoryId = [self.categoryId copy];
    copyCategory.name = [self.name copy];
    copyCategory.order = self.order;
    copyCategory.imageUrl = [self.imageUrl copy];
    
    copyCategory.categories = [NSMutableArray new];
    for(DBMenuCategory *category in self.categories)
        [copyCategory.categories addObject:[category copyWithZone:zone]];
    
    copyCategory.positions = [NSMutableArray new];
    for(DBMenuPosition *position in self.positions)
        [copyCategory.positions addObject:[position copyWithZone:zone]];
    
    copyCategory.categoryDictionary = [self.categoryDictionary copy];
    
    return copyCategory;
}

@end
