//
//  DBModulesViewController.m
//  DoubleB
//
//  Created by Ivan Oschepkov on 17.08.15.
//  Copyright (c) 2015 Empatika. All rights reserved.
//

@import FLKAutoLayout;
#import "DBModulesViewController.h"

@interface DBModulesViewController () <DBOwnerViewControllerProtocol>
@property (weak, nonatomic) NSLayoutConstraint *constraintBottomScrollViewAlignment;

@end

@interface DBModulesViewController (AutoLayout)
- (NSLayoutConstraint *)topConstraintForModule:(DBModuleView *)moduleView;
- (NSLayoutConstraint *)bottomConstraintForModule:(DBModuleView *)moduleView;
@end

@implementation DBModulesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.modules = [NSMutableArray new];
    [self configLayout];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (DBModuleView *submodule in self.modules) {
        [submodule viewWillAppearOnVC];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (DBModuleView *submodule in self.modules) {
        [submodule viewDidAppearOnVC];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    for (DBModuleView *submodule in self.modules) {
        [submodule viewWillDissapearFromVC];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configLayout {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.scrollEnabled = YES;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_scrollView];
    _scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [_scrollView alignTop:@"0" leading:@"0" toView:self.view];
    [_scrollView alignTrailingEdgeWithView:self.view predicate:@"0"];
    self.constraintBottomScrollViewAlignment = [[_scrollView alignBottomEdgeWithView:self.view predicate:@"0"] firstObject];
}

- (void)setAnalyticsCategory:(NSString *)analyticsCategory {
    _analyticsCategory = analyticsCategory;
    
    for (DBModuleView *moduleView in self.modules) {
        moduleView.analyticsCategory = _analyticsCategory;
    }
}

- (void)setTopInset:(CGFloat)topInset {
    _topInset = topInset;
    self.scrollView.contentInset = UIEdgeInsetsMake(_topInset, 0, _bottomInset, 0);
}

- (void)setBottomInset:(CGFloat)bottomInset {
    _bottomInset = bottomInset;
    self.scrollView.contentInset = UIEdgeInsetsMake(_topInset, 0, _bottomInset, 0);
}

#pragma mark - Modules

- (void)addModule:(DBModuleView *)moduleView {
    moduleView.analyticsCategory = self.analyticsCategory;
    moduleView.ownerViewController = self;
    moduleView.delegate = self;
    
    [self.modules addObject:moduleView];
    
    [moduleView viewAddedOnVC];
}

- (void)addModule:(DBModuleView *)moduleView topOffset:(CGFloat)topOffset {
    moduleView.topOffset = topOffset;
    [self addModule:moduleView];
}

- (void)addModule:(DBModuleView *)moduleView bottomOffset:(CGFloat)bottomOffset {
    moduleView.bottomOffset = bottomOffset;
    [self addModule:moduleView];
}

- (void)addModule:(DBModuleView *)moduleView topOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset {
    moduleView.topOffset = topOffset;
    moduleView.bottomOffset = bottomOffset;
    [self addModule:moduleView];
}

- (DBModuleView *)topModuleForModule:(DBModuleView *)moduleView {
    DBModuleView *topModule;
    NSUInteger index = [self.modules indexOfObject:moduleView];
    if (index > 0)
        topModule = [self.modules objectAtIndex:index - 1];
    
    return topModule;
}

- (DBModuleView *)bottomModuleForModule:(DBModuleView *)moduleView {
    DBModuleView *bottomModule;
    NSUInteger index = [self.modules indexOfObject:moduleView];
    if (index < self.modules.count - 1)
        bottomModule = [self.modules objectAtIndex:index + 1];
    
    return bottomModule;
}

- (void)layoutModules {
    for (int i = 0; i < self.modules.count; i++){
        DBModuleView *moduleView = self.modules[i];
        
        [_scrollView addSubview:moduleView];
        moduleView.translatesAutoresizingMaskIntoConstraints = NO;
        [moduleView alignLeadingEdgeWithView:_scrollView predicate:@"0"];
        [moduleView alignTrailingEdgeWithView:_scrollView predicate:@"0"];
        
        if(i == 0){
            [moduleView alignTopEdgeWithView:_scrollView predicate:[NSString stringWithFormat:@"%.0f", moduleView.topOffset]];
            
            [moduleView alignLeadingEdgeWithView:self.view predicate:@"0"];
            [moduleView alignTrailingEdgeWithView:self.view predicate:@"0"];
        } else {
            DBModuleView *topView = self.modules[i-1];
            [moduleView constrainTopSpaceToView:topView predicate:[NSString stringWithFormat:@"%.0f", topView.bottomOffset + moduleView.topOffset]];
            
            if (i == self.modules.count - 1) {
                [moduleView alignBottomEdgeWithView:_scrollView predicate:[NSString stringWithFormat:@">=%.0f", moduleView.bottomOffset]];
                [moduleView alignBottomEdgeWithView:_scrollView predicate:[NSString stringWithFormat:@"%.0f@900", moduleView.bottomOffset]];
            }
        }
    }
    
}

- (void)reloadModules:(BOOL)animated {
    for (DBModuleView *module in self.modules){
        [module reload:animated];
    }
}

- (UIView *)containerForModuleModalComponent:(DBModuleView *)view {
    return self.view;
}

#pragma mark - DBModuleViewDelegate

- (UIView *)db_moduleViewModalComponentContainer:(DBModuleView *)view {
    return [self containerForModuleModalComponent:view];
}

- (void (^)())db_additonalAnimationFroModuleAnimation:(DBModuleView *)view {
    void (^offsetBlock)() = ^void(){
        NSLayoutConstraint *topConstraint = [self topConstraintForModule:view];
        DBModuleView *topModule = [self topModuleForModule:view];
        if (topModule) {
            topConstraint.constant = view.actualTopOffset + topModule.actualBottomOffset;
        } else {
            topConstraint.constant = view.actualTopOffset;
        }
        
        NSLayoutConstraint *bottomConstraint = [self bottomConstraintForModule:view];
        DBModuleView *bottomModule = [self bottomModuleForModule:view];
        if (bottomModule) {
            bottomConstraint.constant = view.actualBottomOffset + bottomModule.actualTopOffset;
        } else {
            bottomConstraint.constant = view.actualBottomOffset;
        }
        
        [self.scrollView layoutIfNeeded];
    };
    
    return offsetBlock;
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification{
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintBottomScrollViewAlignment.constant = -keyboardRect.size.height;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.constraintBottomScrollViewAlignment.constant = 0;
                         [self.view layoutIfNeeded];
                     }
                     completion:nil];
}

@end


@implementation DBModulesViewController (AutoLayout)

- (NSLayoutConstraint *)verticalConstraint:(DBModuleView *)firstModule second:(DBModuleView *)secondModule {
    NSArray *constraints = self.scrollView.constraints;
    for (NSLayoutConstraint *constr in constraints) {
        id topModule, bottomModule;
        if (constr.firstAttribute == NSLayoutAttributeTop)
            topModule = constr.firstItem;
        if (constr.firstAttribute == NSLayoutAttributeBottom)
            bottomModule = constr.firstItem;
        if (constr.secondAttribute == NSLayoutAttributeTop)
            topModule = constr.secondItem;
        if (constr.secondAttribute == NSLayoutAttributeBottom)
            bottomModule = constr.secondItem;
        
        if ((topModule == firstModule && bottomModule == secondModule) ||
            (topModule == secondModule && bottomModule == firstModule)){
            return constr;
        }
    }
    
    return nil;
}

- (NSLayoutConstraint *)topConstraintForModule:(DBModuleView *)moduleView {
    DBModuleView *topItem = [self topModuleForModule:moduleView];
    
    if (topItem) { // Constraint between two modules
        return [self verticalConstraint:topItem second:moduleView];
    } else { // Constraint between top and module
        NSArray *constraints = self.scrollView.constraints;
        for (NSLayoutConstraint *constr in constraints) {
            if (constr.firstAttribute == NSLayoutAttributeTop && constr.secondAttribute == NSLayoutAttributeTop) {
                if ((constr.firstItem == moduleView && constr.secondItem == self.scrollView) || (constr.firstItem == self.scrollView && constr.secondItem == moduleView)) {
                    return constr;
                }
            }
            
        }
    }
    
    return nil;
}

- (NSLayoutConstraint *)bottomConstraintForModule:(DBModuleView *)moduleView {
    DBModuleView *bottomItem = [self bottomModuleForModule:moduleView];
    if (bottomItem) { // Constraint between two modules
        return [self verticalConstraint:bottomItem second:moduleView];
    }
    
    return nil;
}

@end
