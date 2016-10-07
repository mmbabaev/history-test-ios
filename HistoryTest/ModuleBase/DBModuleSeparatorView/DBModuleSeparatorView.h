//
//  DBModuleSeparatorView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 05/11/15.
//  Copyright © 2015 Empatika. All rights reserved.
//

#import "DBModuleView.h"

@interface DBModuleSeparatorView : DBModuleView
@property (strong, nonatomic) NSString *title;
@property (nonatomic) NSUInteger height;
@property (strong, nonatomic) UIColor *color;

- (instancetype)initWithHeight:(NSUInteger)height;

@end
