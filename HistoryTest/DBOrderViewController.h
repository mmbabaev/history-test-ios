//
//  DBOrderViewController.h
//  HistoryTest
//
//  Created by Ivan Oschepkov on 23/08/16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModulesViewController.h"
#import "Order.h"

@interface DBOrderViewController : DBModulesViewController

@property (strong, nonatomic) Order *order;

@end

