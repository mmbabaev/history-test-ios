//
//  IHMenuProductModifierItem.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.11.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuPositionModifierItem.h"
#import "DBMenuPositionModifier.h"
#import "NSDictionary+NSNullRepresentation.h"

@interface DBMenuPositionModifierItem ()
@end

@implementation DBMenuPositionModifierItem

+ (DBMenuPositionModifierItem *)itemFromDictionary:(NSDictionary *)itemDictionary{
    DBMenuPositionModifierItem *item = [[DBMenuPositionModifierItem alloc] init];
    
    [item setValuesForKeysWithDictionary:itemDictionary];
    item.itemDictionary = itemDictionary;
    
    return item;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if([key isEqual:@"id"]){
        self.itemId = value ?: @"";
    }
    if([key isEqual:@"title"] || [key isEqual:@"name"]){
        self.itemName = value ?: @"";
    }
    if([key isEqual:@"price"]){
        self.itemPrice = value ? [value doubleValue] : 0;
    }
    if([key isEqualToString:@"order"]){
        self.order = value ? [value integerValue] : 0;
    }
}

- (double)itemPrice {
//    NSString *venueId = [OrderCoordinator sharedInstance].orderManager.venue.venueId;
//    NSArray *prices = [self.itemDictionary getValueForKey:@"prices"] ?: @[];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venue == %@", venueId];
//    NSDictionary *priceDict = [[prices filteredArrayUsingPredicate:predicate] firstObject];
    
    double price = _itemPrice;
//    if (priceDict) {
//        price = [[priceDict getValueForKey:@"price"] doubleValue];
//    }
    
    return price;
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [[DBMenuPositionModifierItem alloc] init];
    if(self != nil){
        self.itemId = [aDecoder decodeObjectForKey:@"itemId"];
        self.itemName = [aDecoder decodeObjectForKey:@"itemName"];
        self.itemPrice = [[aDecoder decodeObjectForKey:@"itemPrice"] doubleValue];
        self.order = [[aDecoder decodeObjectForKey:@"order"] integerValue];
        self.itemDictionary = [aDecoder decodeObjectForKey:@"itemDictionary"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_itemId forKey:@"itemId"];
    [aCoder encodeObject:_itemName forKey:@"itemName"];
    [aCoder encodeObject:@(_itemPrice) forKey:@"itemPrice"];
    [aCoder encodeObject:@(_order) forKey:@"order"];
    [aCoder encodeObject:_itemDictionary forKey:@"itemDictionary"];
}

- (BOOL)isEqual:(DBMenuPositionModifierItem *)object{
    if(![object isKindOfClass:[DBMenuPositionModifierItem class]]){
        return NO;
    }
    
    return [self.itemDictionary isEqualToDictionary:object.itemDictionary];
}

- (NSUInteger)hash{
    return [self.itemDictionary hash];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuPositionModifierItem *copyItem = [[[self class] allocWithZone:zone] init];
    copyItem.itemId = [_itemId copy];
    copyItem.itemName = [_itemName copy];
    copyItem.itemPrice = _itemPrice;
    copyItem.itemDictionary = [_itemDictionary copy];
    
    return copyItem;
}


#pragma mark - WatchAppModelProtocol

- (NSDictionary *)plistRepresentation {
    NSMutableDictionary *plist = [NSMutableDictionary new];
    
    plist[@"itemId"] = _itemId ?: @"";
    plist[@"itemName"] = _itemName ?: @"";
    plist[@"itemsPrice"] = @(_itemPrice);
    
    return plist;
}

+ (id)createWithPlistRepresentation:(NSDictionary *)plistDict {
    DBMenuPositionModifierItem *item = [DBMenuPositionModifierItem new];
    
    item.itemId = plistDict[@"itemId"];
    item.itemName = plistDict[@"itemName"];
    item.itemPrice = [plistDict[@"itemPrice"] doubleValue];
    
    return item;
}

@end
