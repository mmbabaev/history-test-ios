//
//  DBHeaderView.h
//  HistoryTest
//
//  Created by Михаил on 07.10.16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBModuleView.h"
#import "Order.h"

@interface DBModuleHeaderView : DBModuleView

@property (nonatomic) Order *order;

- (instancetype) initWithOrder:(Order *)order;

@end
