//
//  DBModulesViewController.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBModuleView.h"

@interface DBModulesViewController : UIViewController<DBModuleViewDelegate>
@property (strong, nonatomic) NSString *analyticsCategory;

/**
 * Array of modules
 * Use addModule method to automaticaly set all settings for module
 */
@property (strong, nonatomic) NSMutableArray *modules;

- (void)addModule:(DBModuleView *)moduleView;
- (void)addModule:(DBModuleView *)moduleView topOffset:(CGFloat)topOffset;
- (void)addModule:(DBModuleView *)moduleView bottomOffset:(CGFloat)bottomOffset;
- (void)addModule:(DBModuleView *)moduleView topOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset;

- (void)layoutModules;
- (void)reloadModules:(BOOL)animated;

@property (strong, nonatomic) UIScrollView *scrollView;
/**
 * Offsets
 */
@property (nonatomic) CGFloat topInset;
@property (nonatomic) CGFloat bottomInset;

/**
 * return view where moduleView will display modal component
 * Override this method to customize appearance
 */
- (UIView *)containerForModuleModalComponent:(DBModuleView *)view;

@end
