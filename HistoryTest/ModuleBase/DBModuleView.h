//
//  DBPaymentModuleView.h
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBModuleViewDelegate;
@protocol DBOwnerViewControllerProtocol;

@interface DBModuleView : UIView
// Category for analytics
@property (strong, nonatomic) NSString *analyticsCategory;

// Controller which hold module
@property (weak, nonatomic) UIViewController<DBOwnerViewControllerProtocol> *ownerViewController;

@property (weak, nonatomic) id<DBModuleViewDelegate> delegate;

// Array of submodules
@property (strong, nonatomic) NSMutableArray *submodules;

// Use only if you set modules from code;
- (void)layoutModules;

#pragma mark - Lifecicle

/**
 * Invokes when module added to VC or module
 */
- (void)viewAddedOnVC;

/**
 * Invokes viewWillAppear method of owner ViewController
 */
- (void)viewWillAppearOnVC;

/**
 * Invokes viewDidAppear method of owner ViewController
 */
- (void)viewDidAppearOnVC;

/**
 * Invokes viewWillDissapear method of owner ViewController
 */
- (void)viewWillDissapearFromVC;


#pragma mark - Content
/**
 * Reload content of module and all submodules. Recalculate size
 */
- (void)reload:(BOOL)animated;

/**
 * Animated reload
 * Not override this method. Use it only for react on notifications
 */
- (void)reload;

#pragma mark - Appearance
@property (nonatomic) CGFloat topOffset;
@property (nonatomic) CGFloat bottomOffset;

@property (nonatomic, readonly) BOOL moduleHidden; // Show if module currently hidden
@property (nonatomic, readonly) CGFloat actualTopOffset; // top offset according to moduleHidden property
@property (nonatomic, readonly) CGFloat actualBottomOffset; // bottom offset according to moduleHidden property

/**
 * initializer from xib
 */
+ (instancetype)create;

/**
 * Override it for initialixation from xib
 * By default it use [[alloc] init]
 */
+ (NSString *)xibName;


/**
 * Common initializer for module
 * Override it to customize initialization
 */
- (void)commonInit;

/**
 * Returns content size of current module. By default returns frame size
 * Override it to customize module size
 */
- (CGSize)moduleViewContentSize;

/**
 * Returns content height of current module. By default returns frame height
 * Override it to customize module height
 */
- (CGFloat)moduleViewContentHeight;

#pragma mark - Actions
/**
 * Invokes when get touch on self
 * Override to customize touch actions
 */
- (void)touchAtLocation:(CGPoint)location;
@end

@protocol DBOwnerViewControllerProtocol <NSObject>

@optional
- (void)reloadAllModules;

@end

@protocol DBModuleViewDelegate <NSObject>
@optional
- (UIView *)db_moduleViewModalComponentContainer:(DBModuleView *)view;

- (void(^)())db_additonalAnimationFroModuleAnimation:(DBModuleView *)view;

- (void)db_moduleViewStartEditing:(DBModuleView *)view;
@end
