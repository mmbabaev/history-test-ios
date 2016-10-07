//
// Created by Sergey Pronin on 8/26/14.
// Copyright (c) 2014 Empatika. All rights reserved.
//

#import "UIColor+Hex.h"


@implementation UIColor (Hex)

+ (UIColor *)fromHex:(uint)hex {
    CGFloat red = ((hex & 0x00ff0000) >> 16) / 255.0;
    CGFloat green = ((hex & 0x0000ff00) >> 8) / 255.0;
    CGFloat blue = (hex & 0x000000ff) / 255.0;
    CGFloat alpha = ((hex & 0xff000000) >> 24) / 255.0;
    return [[UIColor alloc] initWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)fromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner scanHexInt:&rgbValue];
    return [UIColor fromHex:rgbValue];
}

- (CGFloat)getBrightness {
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    [self getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return brightness;
}

@end