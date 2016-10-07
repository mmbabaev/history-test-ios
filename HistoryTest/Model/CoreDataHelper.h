//
// Created by Sergey Pronin on 6/21/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@interface CoreDataHelper : NSObject

@property (nonatomic, readonly) NSManagedObjectContext *context;

+ (instancetype)sharedHelper;

- (void)save;

@end