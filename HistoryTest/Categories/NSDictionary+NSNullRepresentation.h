//
//  NSDictionary+NSNullRepresentation.h
//  IIko Hackathon
//
//  Created by Ivan Oschepkov on 25.07.14.
//  Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NSNullRepresentation)

- (id)getValueForKey:(NSString *)key;

- (int)getIntForKey:(NSString *)key;

+ (int)getIntValue:(NSNumber *)number;

@end
