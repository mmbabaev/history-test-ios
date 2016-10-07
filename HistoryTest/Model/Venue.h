//
//  Venue.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface Venue : NSManagedObject

@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *address;
@property (nonatomic) double_t latitude;
@property (nonatomic) double_t longitude;
@property (strong, nonatomic) NSString *workingTime;
@property (nonatomic, strong) NSString *phone;

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic) double distance;

@property (nonatomic, strong) NSDictionary *venueDictionary;

+ (NSArray *)storedVenues;
+ (Venue *)venueById:(NSString *)venueId;
+ (NSArray *)venuesByDistance:(CLLocation *)location;

+ (void)dropAllVenues;
+ (void)saveVenues:(NSArray *)venues;
+ (NSArray *)venuesFromDict:(NSArray *)responseVenues;

@end

@interface Venue(API)
+ (void)fetchVenuesForLocation:(CLLocation *)location withCompletionHandler:(void(^)(NSArray *venues))completionHandler;
@end