//
//  DBOrderListViewController.m
//  HistoryTest
//
//  Created by Михаил on 07.10.16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBOrderListViewController.h"
#import "DBOrderViewController.h"

@interface DBOrderListViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation DBOrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.orders = [[NSMutableArray alloc] init];
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"orders"
                                                     ofType:@"txt"];
    NSString *jsonString = [NSString stringWithContentsOfFile:path
                                                     encoding:NSUTF8StringEncoding
                                                        error:nil];
    NSError *jsonError;
    NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *ordersDict = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&jsonError];
    
    for (NSDictionary *orderDict in ordersDict[@"orders"]) {
        Order *order = [[Order alloc] initWithResponseDict:orderDict];
        [self.orders addObject: order];
    }
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell" forIndexPath:indexPath];
    Order *order = (Order *)self.orders[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"Заказ #%@", order.orderNumber];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [self performSegueWithIdentifier:@"showOrder" sender: self.orders[indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DBOrderViewController *vc = (DBOrderViewController *)segue.destinationViewController;
    vc.order = (Order *)sender;
}

@end











