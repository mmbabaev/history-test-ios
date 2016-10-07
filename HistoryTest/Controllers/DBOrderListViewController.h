//
//  DBOrderListViewController.h
//  HistoryTest
//
//  Created by Михаил on 07.10.16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Order.h"

@interface DBOrderListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableArray *orders;

@end
