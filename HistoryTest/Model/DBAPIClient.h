//
// Created by Sergey Pronin on 9/23/13.
// Copyright (c) 2013 Empatika. All rights reserved.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface DBAPIClient : AFHTTPRequestOperationManager

+ (nullable instancetype)sharedClient;

+ (nullable NSString *)baseUrl;
// Dirty way to change base url
+ (void)changeBaseUrl;

- (void)setValue:(nonnull NSString *)value forHeader:(nonnull NSString *)header;
- (void)disableHeader:(nonnull NSString *)header;

@property(nonatomic) BOOL cityHeaderEnabled;
@property(nonatomic) BOOL companyHeaderEnabled;
@property(nonatomic) BOOL clientHeaderEnabled;

@end