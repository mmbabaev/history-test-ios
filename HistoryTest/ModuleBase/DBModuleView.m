//
//  DBPaymentModuleView.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 19.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

@import FLKAutoLayout;
#import "DBModuleView.h"

@interface DBModuleView ()<DBModuleViewDelegate>
@property (nonatomic) BOOL moduleHidden;
@end

@implementation DBModuleView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self commonInit];
    
    return self;
}

- (instancetype)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 40)];
    
    [self commonInit];
    
    return self;
}

+ (instancetype)create {
    NSString *xibName = [self xibName];
    
    if (xibName.length > 0) {
        return [[[NSBundle mainBundle] loadNibNamed:xibName owner:self options:nil] firstObject];
    } else {
        return [[self class] new];
    }
}

+ (NSString *)xibName {
    return nil;
}


- (void)commonInit {
    self.submodules = [NSMutableArray new];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizerHandler:)];
    tapRecognizer.cancelsTouchesInView = NO;
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapRecognizer];
}

#pragma mark - Layout & Reload

- (void)layoutModules {
    for (int i = 0; i < self.submodules.count; i++){
        UIView *moduleView = self.submodules[i];
        
        [self addSubview:moduleView];
        moduleView.translatesAutoresizingMaskIntoConstraints = NO;
        [moduleView alignLeadingEdgeWithView:self predicate:@"0"];
        [moduleView alignTrailingEdgeWithView:self predicate:@"0"];
        
        if(i == 0){
            [moduleView alignTopEdgeWithView:self predicate:@"0"];
            
            [moduleView alignLeadingEdgeWithView:self predicate:@"0"];
            [moduleView alignTrailingEdgeWithView:self predicate:@"0"];
        } else {
            UIView *topView = self.submodules[i-1];
            [moduleView constrainTopSpaceToView:topView predicate:@"0"];
        }
    }
    
    [self reload:NO];
}

- (void)reload {
    [self reload:YES];
}

- (void)reload:(BOOL)animated {
    for(DBModuleView *module in _submodules){
        [module reload:animated];
    }
    
    // Define if module needs to be hidden
    self.moduleHidden = [self moduleViewContentHeight] == 0;
    
    if (animated) {
        if (self.hidden != self.moduleHidden) { // If module will change its hidden property
            // Show if module was hidden
            if (self.hidden){
                self.hidden = self.moduleHidden;
            }
            
            [UIView animateWithDuration:0.2 animations:^{
                [self invalidateIntrinsicContentSize];
                
                if ([self.delegate respondsToSelector:@selector(db_additonalAnimationFroModuleAnimation:)]){
                    [self.delegate db_additonalAnimationFroModuleAnimation:self]();
                }
//                [self.superview setNeedsLayout];
            } completion:^(BOOL finished) {
                self.hidden = self.moduleHidden;
            }];
        } else { // If module will not change its hidden property, just reload size
            [UIView animateWithDuration:0.2 animations:^{
                [self invalidateIntrinsicContentSize];
                
                if ([self.delegate respondsToSelector:@selector(db_additonalAnimationFroModuleAnimation:)]){
                    [self.delegate db_additonalAnimationFroModuleAnimation:self]();
                }
//                [self.superview setNeedsLayout];
            }];
        }
    } else {
        self.hidden = self.moduleHidden;
        [self invalidateIntrinsicContentSize];
        
        if ([self.delegate respondsToSelector:@selector(db_additonalAnimationFroModuleAnimation:)]){
            [self.delegate db_additonalAnimationFroModuleAnimation:self]();
        }
    }
}

#pragma mark - Lifecicle

- (void)viewAddedOnVC {
    [self reload:NO];
    
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewAddedOnVC];
    }
}

- (void)viewWillAppearOnVC {
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewWillAppearOnVC];
    }
}

- (void)viewDidAppearOnVC {
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewDidAppearOnVC];
    }
}

- (void)viewWillDissapearFromVC {
    for (DBModuleView *submodule in self.submodules) {
        [submodule viewWillDissapearFromVC];
    }
}

#pragma mark - Setters

- (void)setAnalyticsCategory:(NSString *)analyticsCategory{
    _analyticsCategory = analyticsCategory;
    
    for(DBModuleView *submodule in _submodules){
        submodule.analyticsCategory = analyticsCategory;
    }
}

- (void)setOwnerViewController:(UIViewController<DBOwnerViewControllerProtocol> *)ownerViewController {
    _ownerViewController = ownerViewController;
    
    for (DBModuleView *submodule in _submodules) {
        submodule.ownerViewController = ownerViewController;
    }
}

- (void)setDelegate:(id<DBModuleViewDelegate>)delegate {
    _delegate = delegate;
    for(DBModuleView *submodule in _submodules){
        submodule.delegate = self;
    }
}

#pragma mark - Appearance

- (CGFloat)actualTopOffset {
    return self.moduleHidden ? 0 : self.topOffset;
}

- (CGFloat)actualBottomOffset {
    return self.moduleHidden ? 0 : self.bottomOffset;
}

- (CGSize)intrinsicContentSize {
    return [self moduleViewContentSize];
}


- (CGSize)moduleViewContentSize {
    return CGSizeMake(self.frame.size.width, [self moduleViewContentHeight]);
}

- (CGFloat)moduleViewContentHeight {
    int height = self.frame.size.height;
    
    if(_submodules.count > 0) {
        height = 0;
        for(DBModuleView *module in _submodules)
            height += module.moduleViewContentSize.height;
    }
    
    return height;
}

#pragma mark - Touches

- (void)tapRecognizerHandler:(UITapGestureRecognizer *)recognizer {
    [self touchAtLocation:[recognizer locationInView:self]];
}

- (void)touchAtLocation:(CGPoint)location {
    
}

#pragma mark - DBModuleViewDelegate

- (UIView *)db_moduleViewModalComponentContainer:(DBModuleView *)view {
    if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]) {
        return [self.delegate db_moduleViewModalComponentContainer:self];
    } else {
        return nil;
    }
}

- (void)db_moduleViewStartEditing:(DBModuleView *)view {
    if ([self.delegate respondsToSelector:@selector(db_moduleViewModalComponentContainer:)]) {
        [self.delegate db_moduleViewStartEditing:self];
    }
}

@end
