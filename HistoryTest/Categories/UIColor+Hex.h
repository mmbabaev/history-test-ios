//
// Created by Sergey Pronin on 8/26/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)fromHex:(uint)hex;
+ (UIColor *)fromHexString:(NSString *)hexString;
- (CGFloat)getBrightness;

@end