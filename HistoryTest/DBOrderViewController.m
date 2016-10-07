//
//  DBOrderViewController.m
//  HistoryTest
//
//  Created by Ivan Oschepkov on 23/08/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBOrderViewController.h"
#import "DBModuleHeaderView.h"

@interface DBOrderViewController ()

@end

@implementation DBOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.order.orderNumber;
    
    DBModuleHeaderView *header = [[DBModuleHeaderView alloc] initWithOrder:self.order];
    
    [self addModule:header topOffset:0.0];
    
    [self layoutModules];
    
    [self reloadModules:YES];
    
    CGPoint origin = ((DBModuleView *)self.modules[0]).frame.origin;
    CGSize size = ((DBModuleView *)self.modules[0]).frame.size;
    
    NSLog(@"x: %f, y: %f, width: %f, height: %f", origin.x, origin.y, size.width, size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
