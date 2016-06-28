//
//  IHKeyboardAvoiding.m
//  IHKeyboardAvoiding
//
//  Created by Fraser Scott-Morrison on 29/03/13.
//  Copyright (c) 2013 Idle Hands Apps. All rights reserved.
//

#import "IHKeyboardAvoiding.h"

#ifndef SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#endif

#ifndef IS_PHONE
#define IS_PHONE (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
#endif

@implementation IHKeyboardAvoiding

static NSMutableArray *_triggerViews;
static UIView *_avoidingView;
static NSMutableArray *_updatedConstraints;
static NSMutableArray *_updatedConstraintConstants;

static BOOL _isKeyboardVisible;
static BOOL _avoidingViewUsesAutoLayout;
static int _buffer = 0;
static int _padding = 0;
static int _paddingCurrent = 0;
static KeyboardAvoidingMode _keyboardAvoidingMode = KeyboardAvoidingModeMinimum;
static float _minimumAnimationDuration;
static NSNotification *_lastNotification;
static IHKeyboardAvoidingBlock _avoidingBlock;

+ (void)didChange:(NSNotification *)notification
{
    BOOL isKeyBoardShowing = NO; // isKeyBoardShowing and is it merged and docked.
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    
    // get the keyboard & window frames
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self getOrientedRect:keyboardFrame];
    // keyboardHeightDiff used when user is switching between different keyboards that have different heights
    CGRect keyboardFrameBegin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    int keyboardHeightDiff = 0;
    if (keyboardFrameBegin.size.height > 0) {
        keyboardHeightDiff = [self getOrientedRect:keyboardFrameBegin].size.height - keyboardFrame.size.height;
    }
    
    CGSize screenSize = [self screenSize];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    UIViewAnimationOptions animationOptions = animationCurve << 16;
    
    // if split keyboard is being dragged, then skip notification
    if (keyboardFrame.size.height == 0 && !IS_PHONE) {
        if (isPortrait && keyboardFrameBegin.origin.y + keyboardFrameBegin.size.height == screenSize.height) {
            return;
        } else if (!isPortrait && keyboardFrameBegin.origin.x + keyboardFrameBegin.size.width == screenSize.width) {
            return;
        }
    }
    
    // calculate if we are to move up the avoiding view
    if (!CGRectIsEmpty(keyboardFrame) && (keyboardFrame.origin.y == 0 || (keyboardFrame.origin.y + keyboardFrame.size.height == screenSize.height))) {
        isKeyBoardShowing = YES;
        _lastNotification = notification;
    }
    
    // get animation duration
    float animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (animationDuration == 0){
        // custom keyboards often dont animate, its too clanky so have to manually set this
        animationDuration = 0.1;
    }
    
    if (isKeyBoardShowing) {
        for (int i = 0; i < _triggerViews.count; i++) {
            UIView *triggerView = [_triggerViews objectAtIndex:i];
            //showing and docked
            if (triggerView) {
                float diff = 0;
                if (keyboardHeightDiff != 0) {
                    // if keyboard height is changing and avoidingView is currently moved
                    diff = keyboardHeightDiff;
                }
                else {
                    CGPoint originInWindow = [triggerView convertPoint:[self getOrientedRect:triggerView.bounds].origin toView:nil];
                    
                    switch ([[UIApplication sharedApplication] statusBarOrientation]) {
                        case UIInterfaceOrientationPortrait:
                        case UIInterfaceOrientationLandscapeLeft:
                            diff = keyboardFrame.origin.y;
                            diff = diff - (originInWindow.y + triggerView.frame.size.height);
                            break;
                        case UIInterfaceOrientationPortraitUpsideDown:
                        case UIInterfaceOrientationLandscapeRight:
                            diff = screenSize.height - keyboardFrame.size.height;
                            diff = diff - (originInWindow.y + triggerView.frame.size.height);
                            break;
                        default:
                            break;
                    }
                }
                
                if (diff < _buffer || keyboardHeightDiff != 0 || _avoidingBlock) {
                    
                    float displacement = ( isPortrait ? -keyboardFrame.size.height : -keyboardFrame.size.width);
                    float delay = 0;
                    
                    switch (_keyboardAvoidingMode) {
                        case KeyboardAvoidingModeMaximum:
                        {
                            _minimumAnimationDuration = animationDuration;
                            break;
                        }
                        case KeyboardAvoidingModeMinimumDelayed:
                        {
                            float minimumDisplacement = fmaxf(displacement, diff);
                            _minimumAnimationDuration = animationDuration * (minimumDisplacement / displacement);
                            displacement = minimumDisplacement - _paddingCurrent;
                            delay = (animationDuration - _minimumAnimationDuration);
                            animationDuration = _minimumAnimationDuration;
                            break;
                        }
                        case KeyboardAvoidingModeMinimum:
                        default:
                        {
                            float minimumDisplacement = fmaxf(displacement, diff);
                            displacement = minimumDisplacement - (keyboardHeightDiff == 0 ? _paddingCurrent : 0);
                            break;
                        }
                    }
                    
                    if (_avoidingViewUsesAutoLayout) { // if view uses constraints
                        BOOL hasFoundFirstConstraint = NO;
                        for (NSLayoutConstraint *constraint in _avoidingView.superview.constraints) {
                            if (constraint.secondItem == _avoidingView && (constraint.secondAttribute == NSLayoutAttributeCenterY || constraint.secondAttribute == NSLayoutAttributeTop || constraint.secondAttribute == NSLayoutAttributeBottom)) {
                                if (![_updatedConstraints containsObject:constraint]) {
                                    [_updatedConstraints addObject:constraint];
                                    [_updatedConstraintConstants addObject:[NSNumber numberWithFloat:constraint.constant]];
                                }
                                constraint.constant -= displacement;
                                hasFoundFirstConstraint = YES;
                                break;
                            }
                        }
                        if (!hasFoundFirstConstraint) {
                            // if the constraint.secondItem wasn't found, sometimes its the constraint.firstItem that needs to be updated
                            for (NSLayoutConstraint *constraint in _avoidingView.superview.constraints) {
                                if (constraint.firstItem == _avoidingView && (constraint.firstAttribute == NSLayoutAttributeCenterY || constraint.firstAttribute == NSLayoutAttributeTop || constraint.firstAttribute == NSLayoutAttributeBottom)) {
                                    if (![_updatedConstraints containsObject:constraint]) {
                                        [_updatedConstraints addObject:constraint];
                                        [_updatedConstraintConstants addObject:[NSNumber numberWithFloat:constraint.constant]];
                                    }
                                    constraint.constant += displacement;
                                    break;
                                }
                            }
                        }
                        [_avoidingView.superview setNeedsUpdateConstraints];
                    }
                    
                    [UIView animateWithDuration:animationDuration
                                          delay:delay
                                        options:animationOptions
                                     animations:^{
                                         if (_avoidingViewUsesAutoLayout) {
                                             [_avoidingView.superview layoutIfNeeded]; // to animate constraint changes
                                         }
                                         else {
                                             CGAffineTransform transform = _avoidingView.transform;
                                             transform = CGAffineTransformTranslate(transform, 0, displacement);
                                             _avoidingView.transform = transform;
                                         }
                                     }
                                     completion:nil];
                    
                    if (_avoidingBlock) {
                        _avoidingBlock(isKeyBoardShowing, animationDuration, keyboardFrame.size.height, animationOptions);
                    }
                    
                }
            }
        }
        
    }
    else if (_isKeyboardVisible) {
        // hiding, undocking or splitting
        
        switch (_keyboardAvoidingMode) {
            case KeyboardAvoidingModeMaximum:
                break;
            case KeyboardAvoidingModeMinimumDelayed:
                animationDuration = _minimumAnimationDuration;
                break;
            case KeyboardAvoidingModeMinimum:
            default:
                break;
        }
        
        // restore state
        if (_avoidingViewUsesAutoLayout) { // if view uses constrains
            for (int i = 0; i < _updatedConstraints.count; i++) {
                NSLayoutConstraint *updatedConstraint = [_updatedConstraints objectAtIndex:i];
                float updatedConstraintConstant = [[_updatedConstraintConstants objectAtIndex:i] floatValue];
                updatedConstraint.constant = updatedConstraintConstant;
                
            }
            [_avoidingView.superview setNeedsUpdateConstraints];
        }
        
        [UIView animateWithDuration:animationDuration + 0.075
                              delay:0
                            options:animationOptions
                         animations:^{
                             if (_avoidingViewUsesAutoLayout) {
                                 [_avoidingView.superview layoutIfNeeded];
                             }
                             else {
                                 _avoidingView.transform = CGAffineTransformIdentity;
                             }
                         } completion:^(BOOL finished){
                             [_updatedConstraints removeAllObjects];
                             [_updatedConstraintConstants removeAllObjects];
                         }];
        if (_avoidingBlock) {
            _avoidingBlock(isKeyBoardShowing, animationDuration + 0.075, 0, animationOptions);
        }
    }
    _isKeyboardVisible = CGRectContainsRect(CGRectMake(0, 0, screenSize.width, screenSize.height), keyboardFrame);
}

+ (void)setAvoidingView:(UIView *)avoidingView {
    [self setAvoidingView:avoidingView withTriggerView:avoidingView];
}

+ (void)setAvoidingView:(UIView *)avoidingView withTriggerView:(UIView *)triggerView;
{
    [self init];
    
    [_triggerViews removeAllObjects];
    [_triggerViews addObject:triggerView];
    _avoidingView = avoidingView;
    _avoidingViewUsesAutoLayout = _avoidingView.superview.constraints.count > 0;
    _paddingCurrent = _padding;
    _avoidingBlock = nil;
    
    
    if (_isKeyboardVisible) { // perform avoiding immediately
        [self didChange:_lastNotification];
    }
}

+ (void)addTriggerView:(UIView *)triggerView;
{
    [_triggerViews addObject:triggerView];
}

+ (void)removeTriggerView:(UIView *)triggerView;
{
    [_triggerViews removeObject:triggerView];
}

+ (void)removeAll {
    [_triggerViews removeAllObjects];
    _avoidingView = nil;
    _avoidingBlock = nil;
}

+ (void)setAvoidingBlock:(IHKeyboardAvoidingBlock)avoidingBlock {
    [self init];
    _avoidingBlock = avoidingBlock;
    if (_triggerViews.count == 0) {
        [_triggerViews addObject:[[UIView alloc] init]];
    }
}

+ (BOOL)isKeyboardVisible {
    return _isKeyboardVisible;
}

+ (void)setBuffer:(int)buffer {
    _buffer = buffer;
}

+ (void)setPadding:(int)padding {
    if (_paddingCurrent == _padding) {
        _paddingCurrent = padding; // if paddingCurrent has been set explicitly, dont reset it
    }
    _padding = padding;
}

+ (void)setPaddingForCurrentAvoidingView:(int)padding {
    _paddingCurrent = padding;
}

+ (void)setKeyboardAvoidingMode:(KeyboardAvoidingMode)keyboardAvoidingMode {
    _keyboardAvoidingMode = keyboardAvoidingMode;
}

+ (void)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // make sure we only add this once
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        _triggerViews = [[NSMutableArray alloc] init];
        _updatedConstraints = [[NSMutableArray alloc] init];
        _updatedConstraintConstants = [[NSMutableArray alloc] init];
    });
}

#pragma mark - Helpers

+ (CGSize)screenSize {
    return [self getOrientedRect:[UIScreen mainScreen].bounds].size;
}

+ (CGRect)getOrientedRect:(CGRect)originalRect {
    CGRect orientedRect = originalRect;
    if (!SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        if ([self isLandscape]) {
            orientedRect = CGRectMake(originalRect.origin.y, originalRect.origin.x, originalRect.size.height, originalRect.size.width);
        }
    }
    return orientedRect;
}

+ (BOOL)isLandscape {
    return UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
}

#pragma mark -

+ (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // Autolayout is reset when app goes into background, so we need to dismiss the keyboard too
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window.rootViewController.view endEditing:YES];
}

#pragma mark - deprecated

+ (void)setAvoidingView:(UIView *)avoidingView withTarget:(UIView *)targetView {
    [self setAvoidingView:avoidingView withTriggerView:targetView];
}
+ (void)addTarget:(UIView *)targetView {
    [self addTriggerView:targetView];
}
+ (void)removeTarget:(UIView *)targetView {
    [self removeTriggerView:targetView];
}


@end
