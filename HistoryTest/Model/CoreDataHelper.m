//
// Created by Sergey Pronin on 6/21/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import "CoreDataHelper.h"
#import "AppDelegate.h"


@implementation CoreDataHelper {

}

+ (instancetype)sharedHelper {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [self new];
    });

    return _sharedInstance;
}

- (void)save {
//    [self.context save:nil];
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    }
    return self;
}

@end
