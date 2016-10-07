//
//  IHMenu.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenu.h"
#import "DBMenuCategory.h"
#import "DBMenuPosition.h"
#import "Venue.h"
#import "DBAPIClient.h"
#import "NSDictionary+NSNullRepresentation.h"


@interface DBMenu ()
@property(strong, nonatomic) NSArray *categories;

@property(nonatomic) BOOL hasModifiers;
@end

@interface DBMenuPositionBalance ()
+ (DBMenuPositionBalance *)fromResponseDict:(NSDictionary *)dict;
@end

@implementation DBMenu

+ (instancetype)sharedInstance{
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });
    
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    [self loadMenuFromDeviceMemory];
    
    return self;
}

- (void)dealloc {
    [self saveMenuToDeviceMemory];
}

+ (DBMenuType)type {
    return DBMenuTypeSimple;
}

- (BOOL)hasNestedCategories{
    BOOL result = NO;
    for(DBMenuCategory *category in self.categories){
        result = result || category.type == DBMenuCategoryTypeParent;
    }
    
    return result;
}

- (BOOL)hasImages{
    BOOL result = NO;
    for(DBMenuCategory *category in self.categories){
        result = result || category.hasImage;
    }
    
    return result;
}

- (NSArray *)getMenu{
    if(!self.categories){
        [self loadMenuFromDeviceMemory];
    }
    
    return self.categories;
}

- (NSArray *)getMenuForVenue:(Venue *)venue{
    if(!self.categories){
        [self loadMenuFromDeviceMemory];
    }
    
    if (venue) {
        return [self filterMenuForVenue:venue];
    } else {
        return [self getMenu];
    }
}

- (void)updateMenu:(void (^)(BOOL success, NSArray *categories))callback{
    NSMutableDictionary *params = [NSMutableDictionary new];
//    [params addEntriesFromDictionary:[[DBSubscriptionManager sharedInstance] menuRequest]];
    
    if ([DBMenu type] == DBMenuTypeSkeleton) {
        params[@"request_menu_frame"] = @"true";
    }
    
    
        NSDate *startTime = [NSDate date];
        [[DBAPIClient sharedClient] GET:@"menu"
                             parameters:params
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    double interval = [[NSDate date] timeIntervalSinceDate:startTime];
                                    
                                    
//                                    NSDictionary *menu = [[DBSubscriptionManager sharedInstance] cutSubscriptionCategory:responseObject];
                                    [self synchronizeWithResponseMenu:responseObject[@"menu"]];
                                    
                                    if(callback)
                                        callback(YES, self.categories);
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                    NSLog(@"%@", error);
                                    
                                    
                                    if(callback)
                                        callback(NO, nil);
                                }];

}

- (void)updateCategory:(DBMenuCategory *)category callback:(void(^)(BOOL success))callback {
    NSDate *startTime = [NSDate date];
    [[DBAPIClient sharedClient] GET:@"category"
                         parameters:@{@"category_id": category.categoryId}
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                NSDate *endTime = [NSDate date];
                                int interval = [endTime timeIntervalSince1970] - [startTime timeIntervalSince1970];
                                
                                
                                DBMenuCategory *remoteCategory = [DBMenuCategory categoryFromResponseDictionary:responseObject[@"category"]];
                                category.positions = remoteCategory.positions;
                                
                                if(callback)
                                    callback(YES);
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                NSLog(@"%@", error);
                                
                                
                                if(callback)
                                    callback(NO);
                            }];
}

- (void)updatePositionBalance:(DBMenuPosition *)position callback:(void (^)(BOOL, NSArray *))callback {
    [[DBAPIClient sharedClient] GET:@"remainders"
                         parameters:@{@"item_id": position.positionId}
                            success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
                                NSMutableArray *balances = [NSMutableArray new];
                                
                                for (NSDictionary *balanceDict in responseObject[@"remainders"]) {
                                    DBMenuPositionBalance *balance = [DBMenuPositionBalance fromResponseDict:balanceDict];
                                    if (balance) {
                                        [balances addObject:balance];
                                    }
                                }
                                
//                                for (int i = 0; i < 10; i++) {
//                                    DBMenuPositionBalance *balance = [DBMenuPositionBalance new];
//                                    balance.venue = [Venue storedVenues].firstObject;
//                                    balance.balance = i;
//                                    
//                                    [balances addObject:balance];
//                                }
                                
                                if (callback) {
                                    callback(YES, balances);
                                }
                            }
                            failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
                                NSLog(@"%@", error);
                                
                                if (callback) {
                                    callback(NO, nil);
                                }
                            }];
}

- (NSArray *)filterMenuForVenue:(Venue *)venue{
    BOOL excludeCategories = [DBMenu type] == DBMenuTypeSimple;
    NSMutableArray *categories = [NSMutableArray new];
    
    for(DBMenuCategory *category in self.categories){
        if([category availableInVenue:venue]){
            DBMenuCategory *newCategory = [category copy];
            newCategory.positions = [newCategory filterPositionsForVenue:venue];
            newCategory.categories = [newCategory filterCategoriesForVenue:venue excludeCategories:excludeCategories];
            if([newCategory.positions count] > 0 || [newCategory.categories count] > 0 || !excludeCategories){
                [categories addObject:newCategory];
            }
        }
    }
    
    return categories;
}

- (void)synchronizeWithResponseMenu:(NSArray *)responseMenu{
    NSMutableArray *newCategories = [[NSMutableArray alloc] init];
    
//    if ([ApplicationConfig db_appType] == ApplicationTypeAggregator) {
//        [newCategories addObject:[DBMenuCategory categoryFromResponseDictionary:[responseMenu firstObject]]];
//    } else {
        for(NSDictionary *categoryDictionary in responseMenu){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"categoryId == %@", categoryDictionary[@"info"][@"category_id"]];
            DBMenuCategory *sameCategory = [[self.categories filteredArrayUsingPredicate:predicate] firstObject];
            if(sameCategory){
                [sameCategory synchronizeWithResponseDictionary:categoryDictionary];
                [newCategories addObject:sameCategory];
            } else {
                [newCategories addObject:[DBMenuCategory categoryFromResponseDictionary:categoryDictionary]];
            }
        }
//    }
    
    
    self.categories = [self sortCategories:newCategories];
    [self checkForModifiers];
    
    [self saveMenuToDeviceMemory];
}

- (void)checkForModifiers {
    BOOL result = YES;
    
    for (DBMenuCategory *category in self.categories) {
        NSArray *positions = [category getAllPositions];
        for (DBMenuPosition *position in positions) {
            result = result && (position.groupModifiers.count == 0 && position.singleModifiers.count == 0);
        }
    }
    
    result = result && ([DBMenu type] == DBMenuTypeSimple);
    
    _hasModifiers = !result;
}

- (void)syncWithPosition:(DBMenuPosition *)position {
    DBMenuPosition *cachedPosition = [self findPositionWithId:position.positionId];
    if(cachedPosition){
        [cachedPosition syncWithPosition:position];
    }
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
    
    return resultPosition;
}

- (NSArray *)traceForPosition:(DBMenuPosition *)position {
    NSArray *result;
    for(DBMenuCategory *category in self.categories){
        NSArray *trace = [category traceForPosition:position];
        if (trace.count > 0) {
            result = trace;
        }
    }
    
    return result;
}

- (NSArray *)filterPositions:(NSString *)text venue:(Venue *)venue {
    NSMutableArray *result = [NSMutableArray new];
    
    DBMenuPositionSearchResult *searchResult = [DBMenuPositionSearchResult new];
    for(DBMenuCategory *category in self.categories){
        if([category availableInVenue:venue]){
            [result addObjectsFromArray:[category filterPositions:text venue:venue currentResult:searchResult]];
        }
    }
    
    return result;
}

- (NSArray *)sortCategories:(NSArray *)categories{
    NSMutableArray *mutableCategories = [[NSMutableArray alloc] initWithArray:categories];
    [mutableCategories sortUsingComparator:^NSComparisonResult(DBMenuCategory *obj1, DBMenuCategory *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
    
    return mutableCategories;
}


- (void)saveMenuToDeviceMemory{
    if(self.categories){
        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/menu.txt"];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.categories];
        NSError *error;
        [data writeToFile:path options:NSDataWritingAtomic error:&error];
        if(error != nil){
            NSLog(@"%@", error);
        }
    }
}

- (void)clearMenu {
    self.categories = @[];
    
    [self saveMenuToDeviceMemory];
}

- (void)loadMenuFromDeviceMemory{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:@"/menu.txt"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    self.categories = [self sortCategories:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
    [self checkForModifiers];
}

@end


@implementation DBMenuPositionBalance

+ (DBMenuPositionBalance *)fromResponseDict:(NSDictionary *)dict {
    DBMenuPositionBalance *positionBalance;
    
    NSString *venueId = [dict getValueForKey:@"venue_id"] ?: @"";
    Venue *venue = [Venue venueById:venueId];
    if (venue) {
        NSInteger count = [dict getValueForKey:@"value"] ? [[dict getValueForKey:@"value"] integerValue] : -1;
        if (count != 0) {
            positionBalance = [DBMenuPositionBalance new];
            positionBalance.venue = venue;
            positionBalance.balance = count;
        }
    }
    
    return positionBalance;
}

@end

@implementation DBMenuPositionSearchResult

- (instancetype)init {
    self = [super init];
    
    self.pathCategories = [NSMutableArray new];
    self.positions = [NSMutableArray new];
    
    return self;
}

@end