//
//  DBModulePriceView.m
//  HistoryTest
//
//  Created by Михаил on 07.10.16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBModulePriceView.h"

@interface DBModulePriceView()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DBModulePriceView

- (instancetype)initWithOrder:(Order *)order {
    self = [DBModulePriceView create];
    self.order = order;
    return self;
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.order.items.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderItemCell" forIndexPath:<#(nonnull NSIndexPath *)#>]
    return nil;
}

@end
