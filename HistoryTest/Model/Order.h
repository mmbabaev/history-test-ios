//
//  Order.h
//  DoubleB
//
//  Created by Sergey Pronin on 7/31/14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef NS_ENUM(int16_t, OrderStatus) {
    OrderStatusNew = 0,
    OrderStatusConfirmed = 5,
    OrderStatusOnWay = 6,
    OrderStatusDone = 1,
    OrderStatusCanceled = 2,
    OrderStatusCanceledBarista = 3
};

typedef NS_ENUM(int16_t, DBOrderCancelReason) {
    DBOrderCancelReasonWrongTime = 0,
    DBOrderCancelReasonWrongPlace,
    DBOrderCancelReasonChangeMind,
    DBOrderCancelReasonOther
};

typedef NS_ENUM(int16_t, PaymentType) {
    PaymentTypeNotSet = -1,
    PaymentTypeCash = 0,
    PaymentTypeCard = 1,
    PaymentTypeExtraType = 2,
    PaymentTypePayPal = 4,
    PaymentTypeCourierCard = 5
};

@class Venue;

@interface Order : NSManagedObject

//stored
@property (nonatomic, strong) NSString *orderId;
@property (nonatomic, strong) NSString *orderNumber;

@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSNumber *discount;
@property (nonatomic, strong) NSNumber *walletDiscount;
@property (nonatomic, strong) NSNumber *shippingTotal;

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *timeString;
@property (nonatomic, strong) NSData *dataItems; //array of JSON-encoded positions
@property (nonatomic, strong) NSData *dataBonusItems; //array of JSON-encoded bonus positions
@property (nonatomic, strong) NSData *dataGiftItems; //array of JSON-encoded bonus positions

@property (nonatomic) OrderStatus status;

@property (nonatomic, strong) NSNumber *deliveryType;
@property (nonatomic, strong) NSString *venueId;
@property (nonatomic, strong) NSString *venueName;
@property (nonatomic, strong) NSString *shippingAddress;

@property (nonatomic) PaymentType paymentType;

//not stored
@property (nonatomic, readonly) double actualTotal;
@property (nonatomic, readonly) double actualDiscount;

@property (nonatomic, readonly) NSArray *items;
@property (nonatomic, readonly) NSArray *bonusItems;
@property (nonatomic, readonly) NSArray *giftItems;

@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, readonly) NSString *formattedTimeString;
@property (nonatomic, readonly) NSString *formattedDateString;
@property (nonatomic, readonly) NSString *formattedOnlyTimeString;

@property (nonatomic, strong) NSMutableDictionary *requestObject;

- (instancetype)init:(BOOL)stored;
- (instancetype)initNewOrderWithDict:(NSDictionary *)dict;
- (instancetype)initWithResponseDict:(NSDictionary *)dict;
- (void)synchronizeWithResponseDict:(NSDictionary *)dict;

- (BOOL)isActive;

+ (NSArray *)allOrders;
+ (Order *)orderById:(NSString *)orderId;
+ (Order *)lastOrderForWatch:(BOOL)active;
+ (void)dropAllOrders;


/**
* Fetch statuses for given Order objects
*/
+ (void)synchronizeStatusesForOrders:(NSArray *)orders withCompletionHandler:(void(^)(BOOL success, NSArray *orders))completionHandler;

@end
