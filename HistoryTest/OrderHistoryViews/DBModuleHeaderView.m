//
//  DBHeaderView.m
//  HistoryTest
//
//  Created by Михаил on 07.10.16.
//  Copyright © 2016 Empatika. All rights reserved.
//

#import "DBModuleHeaderView.h"
#import "DBDeliveryType.h"

@interface DBModuleHeaderView()

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *paymentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *paymentImageView;


@end

@implementation DBModuleHeaderView

- (instancetype)initWithOrder:(Order *)order {
    self = [DBModuleHeaderView create];
    
    self.order = order;
    return self;
}

+ (NSString *)xibName {
    return @"DBModuleHeaderView";
}

- (void)reload:(BOOL)animated {
    if (!self.order) {
        NSLog(@"Error: Order is nil");
        return;
    }
    
    // reload status:
    
    switch (self.order.status) {
        case OrderStatusNew:
            self.statusLabel.text = [self.order.deliveryType intValue] == DeliveryTypeIdShipping ? NSLocalizedString(@"Ожидает подтверждения", nil) : NSLocalizedString(@"Готовится", nil);
            break;
        case OrderStatusConfirmed:
            self.statusLabel.text =  NSLocalizedString(@"Подтвержден", nil);
            break;
        case OrderStatusOnWay:
            self.statusLabel.text =  NSLocalizedString(@"В пути", nil);
            break;
        case OrderStatusCanceledBarista:
        case OrderStatusCanceled:
            self.statusLabel.text =  @"";
            break;
        case OrderStatusDone:
            self.statusLabel.text =  NSLocalizedString(@"Выдан", nil);
            break;
            
        default:
            break;
    }
    
    // reload payment:
    
    switch (self.order.status) {
        case OrderStatusCanceled:
        case OrderStatusCanceledBarista:
            self.paymentLabel.text = NSLocalizedString(@"Отменен", nil);
            self.paymentImageView.image = [UIImage imageNamed:@"cancelled"];
            break;
        default:
            [self reloadNotCancelledOrderPayment];
    }
    
    // reload time:
    
    switch (self.order.status) {
        case OrderStatusDone:
        case OrderStatusCanceledBarista:
        case OrderStatusCanceled:
            self.timeLabel.text = self.order.formattedTimeString;
         
        default: {
            NSString *timeText = NSLocalizedString(@"Готов к ", nil);
            if (self.order.timeString) {
                self.timeLabel.text = [timeText stringByAppendingString:self.order.formattedOnlyTimeString];
            }
            break;
        }
    }
}

- (void)reloadNotCancelledOrderPayment {
    if (self.order.paymentType == PaymentTypeCard ||
        self.order.paymentType == PaymentTypePayPal ||
        self.order.paymentType == PaymentTypeExtraType ||
        self.order.status == OrderStatusDone) {
        
        self.paymentLabel.text = NSLocalizedString(@"Оплачен", nil);
        self.paymentImageView.image = [UIImage imageNamed:@"paid"];
    }
    else {
        self.paymentLabel.textColor = [UIColor grayColor];
        self.paymentLabel.text = NSLocalizedString(@"Оплата наличными", nil);
        self.paymentImageView.image = [UIImage imageNamed:@"not_paid"];
    }
}

@end







































