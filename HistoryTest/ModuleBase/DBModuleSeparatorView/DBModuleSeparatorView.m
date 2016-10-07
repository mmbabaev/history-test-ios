//
//  DBModuleSeparatorView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 05/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleSeparatorView.h"

@interface DBModuleSeparatorView ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation DBModuleSeparatorView

- (instancetype)initWithHeight:(NSUInteger)height {
    self = [super init];
    
    _height = height;
    [self reload:NO];
    
    return self;
}

- (void)commonInit {
    [super commonInit];
    
    self.backgroundColor = [UIColor clearColor];
    self.titleLabel.hidden = YES;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = _title;
    self.titleLabel.hidden = NO;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    self.backgroundColor = _color;
}

- (void)setHeight:(NSUInteger)height {
    _height = height;
    [self reload:YES];
}

- (CGFloat)moduleViewContentHeight {
    return self.height > 0 ? self.height : 40.f;
}

@end
