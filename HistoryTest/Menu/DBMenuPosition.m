//
//  IHMenuProduct.m
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 18.08.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import "DBMenuPosition.h"
#import "DBMenuPositionModifier.h"
#import "DBMenuPositionModifierItem.h"
#import "NSDictionary+NSNullRepresentation.h"
#import "UIColor+Hex.h"
#import "Venue.h"

@interface DBMenuPosition ()
@property(strong, nonatomic) NSString *positionId;
@property(strong, nonatomic) NSString *name;
@property(nonatomic) NSInteger order;
@property(strong, nonatomic) NSString *imageUrl;
@property(strong, nonatomic) NSString *positionDescription;
@property(nonatomic) double energyAmount;
@property(nonatomic) double weight;
@property(nonatomic) double volume;
@property(nonatomic) double fiber;
@property(nonatomic) double fat;
@property(nonatomic) double carbohydrate;

@property(strong, nonatomic) NSMutableArray *groupModifiers;
@property(strong, nonatomic) NSMutableArray *singleModifiers;

@property(strong, nonatomic) NSDictionary *productDictionary;

@property(strong, nonatomic) NSArray *venuesRestrictions;
@end

@implementation DBMenuPosition

- (instancetype)initWithResponseDictionary:(NSDictionary *)positionDictionary{
    self = [super init];
    
    [self copyFromResponseDictionary:positionDictionary];
    
    self.groupModifiers = [NSMutableArray new];
    for(NSDictionary *modifierDictionary in positionDictionary[@"group_modifiers"]) {
        DBMenuPositionModifier *modifier = [DBMenuPositionModifier groupModifierFromDictionary:modifierDictionary];
        if(modifier)
            [self.groupModifiers addObject:modifier];
    }
    [self sortModifiers:_groupModifiers];
    
    return self;
}


- (void)synchronizeWithResponseDictionary:(NSDictionary *)positionDictionary{
    [self copyFromResponseDictionary:positionDictionary];
    
    NSArray *remoteModifiers = positionDictionary[@"group_modifiers"];
    NSMutableArray *newModifiers = [NSMutableArray new];
    
    // Synchronize cached modifiers with remoteModifiers
    for (NSDictionary *remoteModifier in remoteModifiers) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modifierId == %@", remoteModifier[@"modifier_id"]];
        DBMenuPositionModifier *modifier = [[_groupModifiers filteredArrayUsingPredicate:predicate] firstObject];
        if(modifier) {
            if(![modifier synchronizeGroupModifierWithDictionary:remoteModifier])
                modifier = nil;
        } else {
            modifier = [DBMenuPositionModifier groupModifierFromDictionary:remoteModifier];
        }
        
        if(modifier)
            [newModifiers addObject:modifier];
    }
    
    _groupModifiers = newModifiers;
    [self sortModifiers:_groupModifiers];
}

- (void)syncWithPosition:(DBMenuPosition *)position {
    if([self isSamePosition:position]){
        for (DBMenuPositionModifier *modifier in position.groupModifiers){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modifierId == %@", modifier.modifierId];
            DBMenuPositionModifier *storedModifier = [[self.groupModifiers filteredArrayUsingPredicate:predicate] firstObject];
            if(storedModifier && [storedModifier isSameModifier:modifier] && !storedModifier.itemSelectedByUser && modifier.itemSelectedByUser){
                [storedModifier selectItemById:modifier.selectedItem.itemId];
            }
        }
    }
}

- (void)copyFromResponseDictionary:(NSDictionary *)positionDictionary{
    _positionId = [positionDictionary getValueForKey:@"id"] ?: @"";
    _name = [positionDictionary getValueForKey:@"title"] ?: @"0";
    _order = [[positionDictionary getValueForKey:@"order"] integerValue];
    _price = [[positionDictionary getValueForKey:@"price"] doubleValue];
    _imageUrl = [positionDictionary getValueForKey:@"pic"];
    if(!_imageUrl){
        _imageUrl = [positionDictionary getValueForKey:@"image"];
    }
    _positionDescription = [positionDictionary getValueForKey:@"description"];
    _energyAmount = [[positionDictionary getValueForKey:@"kal"] doubleValue];
    _weight = [[positionDictionary getValueForKey:@"weight"] doubleValue];
    _volume = [[positionDictionary getValueForKey:@"volume"] doubleValue];
    _fiber = [[positionDictionary getValueForKey:@"fiber"] doubleValue];
    _fat = [[positionDictionary getValueForKey:@"fat"] doubleValue];
    _carbohydrate = [[positionDictionary getValueForKey:@"carbohydrate"] doubleValue];
    _venuesRestrictions = [positionDictionary[@"restrictions"] getValueForKey:@"venues"] ?: @[];
    
    _productDictionary = positionDictionary;
    
    _singleModifiers = [NSMutableArray new];
    for(NSDictionary *modifierDictionary in positionDictionary[@"single_modifiers"]){
        [self.singleModifiers addObject:[DBMenuPositionModifier singleModifierFromDictionary:modifierDictionary]];
    }
    [self sortModifiers:_singleModifiers];
}

- (void)sortModifiers:(NSMutableArray *)modifiers{
    [modifiers sortUsingComparator:^NSComparisonResult(DBMenuPositionModifier *obj1, DBMenuPositionModifier *obj2) {
        return [@(obj1.order) compare:@(obj2.order)];
    }];
}

#pragma mark - User actions

- (void)selectItem:(NSString *)itemId forGroupModifier:(NSString *)modifierId{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modifierId == %@", modifierId];
    DBMenuPositionModifier *modifier = [[self.groupModifiers filteredArrayUsingPredicate:predicate] firstObject];
    if(modifier){
        [modifier selectItemById:itemId];
    }
}

- (void)selectAllRequiredModifiers {
    for (DBMenuPositionModifier *modifier in self.groupModifiers){
        if(modifier.required && !modifier.itemSelectedByUser)
            [modifier selectDefaultItem];
    }
}

- (void)addSingleModifier:(NSString *)modifierId count:(NSInteger)count{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"modifierId == %@", modifierId];
    DBMenuPositionModifier *modifier = [[self.singleModifiers filteredArrayUsingPredicate:predicate] firstObject];
    if(modifier){
        modifier.selectedCount = (int)count;
    }
}


#pragma mark - Dynamic properties

- (double)price{
//    if (self.mode == DBMenuPositionModeRegular) {
//        NSString *venueId = [OrderCoordinator sharedInstance].orderManager.venue.venueId;
//        NSArray *prices = [self.productDictionary getValueForKey:@"prices"] ?: @[];
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"venue == %@", venueId];
//        NSDictionary *priceDict = [[prices filteredArrayUsingPredicate:predicate] firstObject];
//        
//        double price = _price;
//        if (priceDict) {
//            price = [[priceDict getValueForKey:@"price"] doubleValue];
//        }
//        
//        return price;
//    } else {
        return _price;
//    }
}

- (double)actualPrice {
    double price = self.price;
    for(DBMenuPositionModifier *modifier in self.groupModifiers){
        price += modifier.actualPrice;
    }
    
    for(DBMenuPositionModifier *modifier in self.singleModifiers){
        price += modifier.actualPrice;
    }
    
    return price;
}

- (BOOL)hasImage{
    BOOL result = self.imageUrl != nil;
    if(result){
        result = result && self.imageUrl.length > 0;
    }
    return result;
}

- (BOOL)availableInVenue:(Venue *)venue{
    return (venue && ![_venuesRestrictions containsObject:venue.venueId]) || !venue;
}

- (BOOL)hasEmptyRequiredModifiers {
    BOOL result = NO;
    
    for (DBMenuPositionModifier *modifier in self.groupModifiers){
        result = result || (modifier.required && !modifier.itemSelectedByUser);
    }
    
    return result;
}

#pragma mark - Layout settings

- (UIColor *)backgroundColor {
    NSString *hexString = [self.productDictionary getValueForKey:@"pic_background"];
    if (hexString.length < 8) {
        hexString = [NSString stringWithFormat:@"FF%@", hexString];
    }
    return [UIColor fromHexString:hexString];
}

- (UIViewContentMode)contentMode {
    NSInteger mode = [[self.productDictionary getValueForKey:@"pic_resize"] integerValue];
    return mode == 0 ? UIViewContentModeScaleAspectFill : UIViewContentModeScaleAspectFit;
}

#pragma mark - Equality

- (BOOL)isSamePosition:(DBMenuPosition *)object{
    if(![object isKindOfClass:[DBMenuPosition class]]){
        return NO;
    }
    
    return [self.productDictionary isEqualToDictionary:object.productDictionary];
}

- (BOOL)isEqual:(DBMenuPosition *)object{
    BOOL result = [self isSamePosition:object];
    
    result = result && ([object.groupModifiers count] == [self.groupModifiers count]);
    if(result){
        for(int i = 0; i < [self.groupModifiers count]; i++){
            result = result && [self.groupModifiers[i] isEqual:object.groupModifiers[i]];
        }
    }
    
    result = result && ([object.singleModifiers count] == [self.singleModifiers count]);
    if(result){
        for(int i = 0; i < [self.singleModifiers count]; i++){
            result = result && [self.singleModifiers[i] isEqual:object.singleModifiers[i]];
        }
    }
    
    return result;
}

- (NSUInteger)hash{
    return [self.productDictionary hash];
}

#pragma mark - NSCoding methods

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self != nil){
        _positionId = [aDecoder decodeObjectForKey:@"positionId"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _order = [[aDecoder decodeObjectForKey:@"order"] integerValue];
        _price = [[aDecoder decodeObjectForKey:@"price"] doubleValue];
        _imageUrl = [aDecoder decodeObjectForKey:@"imageUrl"];
        _positionDescription = [aDecoder decodeObjectForKey:@"positionDescription"];
        _energyAmount = [[aDecoder decodeObjectForKey:@"energyAmount"] doubleValue];
        _weight = [[aDecoder decodeObjectForKey:@"weight"] doubleValue];
        _volume = [[aDecoder decodeObjectForKey:@"volume"] doubleValue];
        _fiber = [[aDecoder decodeObjectForKey:@"_fiber"] doubleValue];
        _fat = [[aDecoder decodeObjectForKey:@"_fat"] doubleValue];
        _carbohydrate = [[aDecoder decodeObjectForKey:@"_carbohydrate"] doubleValue];
        _groupModifiers = [aDecoder decodeObjectForKey:@"groupModifiers"];
        _singleModifiers = [aDecoder decodeObjectForKey:@"singleModifiers"];
        _venuesRestrictions = [aDecoder decodeObjectForKey:@"venuesRestrictions"];
        _productDictionary = [aDecoder decodeObjectForKey:@"productDictionary"];
        
        _mode = [[aDecoder decodeObjectForKey:@"positionMode"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_positionId forKey:@"positionId"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:@(_order) forKey:@"order"];
    [aCoder encodeObject:@(_price) forKey:@"price"];
    [aCoder encodeObject:_imageUrl forKey:@"imageUrl"];
    [aCoder encodeObject:_positionDescription forKey:@"positionDescription"];
    [aCoder encodeObject:@(_energyAmount) forKey:@"energyAmount"];
    [aCoder encodeObject:@(_weight) forKey:@"weight"];
    [aCoder encodeObject:@(_volume) forKey:@"volume"];
    [aCoder encodeObject:@(_fiber) forKey:@"_fiber"];
    [aCoder encodeObject:@(_fat) forKey:@"_fat"];
    [aCoder encodeObject:@(_carbohydrate) forKey:@"_carbohydrate"];
    [aCoder encodeObject:_groupModifiers forKey:@"groupModifiers"];
    [aCoder encodeObject:_singleModifiers forKey:@"singleModifiers"];
    [aCoder encodeObject:_venuesRestrictions forKey:@"venuesRestrictions"];
    [aCoder encodeObject:_productDictionary forKey:@"productDictionary"];
    
    [aCoder encodeObject:@(_mode) forKey:@"positionMode"];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone{
    DBMenuPosition *copyPosition = [[[self class] allocWithZone:zone] init];
    copyPosition.positionId = [_positionId copy];
    copyPosition.name = [_name copy];
    copyPosition.order = _order;
    copyPosition.price = _price;
    copyPosition.imageUrl = [_imageUrl copy];
    copyPosition.positionDescription = [_positionDescription copy];
    copyPosition.energyAmount = _energyAmount;
    copyPosition.weight = _weight;
    copyPosition.volume = _volume;
    copyPosition.fiber = _fiber;
    copyPosition.fat = _fat;
    copyPosition.carbohydrate = _carbohydrate;
    
    copyPosition.groupModifiers = [NSMutableArray new];
    for(DBMenuPositionModifier *modifier in _groupModifiers)
        [copyPosition.groupModifiers addObject:[modifier copyWithZone:zone]];
    
    copyPosition.singleModifiers = [NSMutableArray new];
    for(DBMenuPositionModifier *modifier in _singleModifiers)
        [copyPosition.singleModifiers addObject:[modifier copyWithZone:zone]];
    
    copyPosition.productDictionary = [self.productDictionary copy];
    copyPosition.venuesRestrictions = [self.venuesRestrictions copy];
    
    copyPosition.mode = self.mode;
    
    return copyPosition;
}

@end

@implementation DBMenuPosition (HistoryResponse)
- (instancetype)initWithHistoryDict:(NSDictionary *)positionDictionary{
    self = [super init];
    
    self.positionId = [positionDictionary getValueForKey:@"id"] ?: @"";
    self.imageUrl = [positionDictionary getValueForKey:@"pic"];
    if(!self.imageUrl){
        self.imageUrl = [positionDictionary getValueForKey:@"image"];
    }
    self.price = [[positionDictionary getValueForKey:@"price"] doubleValue];
    self.name = [positionDictionary getValueForKey:@"title"] ?: @"";
    
    return self;
}
@end
