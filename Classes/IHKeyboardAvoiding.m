//
//  IHKeyboardAvoiding.m
//  IHKeyboardAvoiding
//
//  Created by Fraser Scott-Morrison on 29/03/13.
//  Copyright (c) 2013 Idle Hands Apps. All rights reserved.
//

#import "IHKeyboardAvoiding.h"

@implementation IHKeyboardAvoiding

static NSMutableArray *_targetViews;
static UIView *_avoidingView;
static NSMutableArray *_updatedConstraints;
static NSMutableArray *_updatedConstraintConstants;

static BOOL _isKeyboardVisible;
static BOOL _avoidingViewUsesAutoLayout;
static int _buffer = 0;
static int _padding = 0;
static KeyboardAvoidingMode _keyboardAvoidingMode = KeyboardAvoidingModeMinimum;
static float _minimumAnimationDuration;

+ (void)didChange:(NSNotification *)notification
{
    BOOL isKeyBoardShowing = NO; // isKeyBoardShowing and is it merged and docked.
    BOOL isPortrait = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    
    // get the keyboard & window frames
    CGRect keyboardFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect windowFrame = [UIApplication sharedApplication].keyWindow.frame;
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    // if split keyboard is being dragged, then skip notification
    if (keyboardFrame.size.height == 0) {
        CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        
        if (isPortrait) {
            if (keyboardBeginFrame.origin.y + keyboardBeginFrame.size.height == windowFrame.size.height)
                return;
        } else {
            if (keyboardBeginFrame.origin.x + keyboardBeginFrame.size.width == windowFrame.size.width)
                return;
        }
    }
    
    // calculate if we are to move up the avoiding view
    if (isPortrait) {
        if (keyboardFrame.origin.y == 0 || (keyboardFrame.origin.y + keyboardFrame.size.height == windowFrame.size.height)) {
            isKeyBoardShowing = YES;
        }
    } else {
        if (keyboardFrame.origin.x == 0 || (keyboardFrame.origin.x + keyboardFrame.size.width == windowFrame.size.width)) {
            isKeyBoardShowing = YES;
        }
    }
    
    // get animation duration
    float animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (isKeyBoardShowing) {
        for (int i = 0; i < _targetViews.count; i++) {
            UIView *targetView = [_targetViews objectAtIndex:i];
            //showing and docked
            if (targetView) {
                float diff = 0;
                CGPoint originInWindow = [targetView.superview convertPoint:targetView.frame.origin toView:nil];
                switch ([[UIApplication sharedApplication] statusBarOrientation]) {
                    case UIInterfaceOrientationPortrait:
                        diff = keyboardFrame.origin.y;
                        diff -= (originInWindow.y + targetView.frame.size.height);
                        break;
                    case UIInterfaceOrientationPortraitUpsideDown:
                        diff = windowFrame.size.height - keyboardFrame.size.height;
                        originInWindow.y = windowFrame.size.height - originInWindow.y;
                        diff -= (originInWindow.y + targetView.frame.size.height);
                        break;
                    case UIInterfaceOrientationLandscapeLeft:
                        diff = keyboardFrame.origin.x;
                        diff -= (originInWindow.x + targetView.frame.size.height);
                        break;
                    case UIInterfaceOrientationLandscapeRight:
                        diff = windowFrame.size.width - keyboardFrame.size.width;
                        originInWindow.x = windowFrame.size.width - originInWindow.x;
                        diff -= (originInWindow.x + targetView.frame.size.height);
                    default:
                        break;
                }
                
                
                // Because a frame change from a keyboard with auto-completion to a one without that
                // (e.g. From Japanese keyboard to English keyboard) leads to positive diff,
                // we should take into account the case by using the absolute value.
                if (fabsf(diff) > _buffer) {

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
                            displacement = minimumDisplacement - _padding;
                            delay = (animationDuration - _minimumAnimationDuration);
                            animationDuration = _minimumAnimationDuration;
                            break;
                        }
                        case KeyboardAvoidingModeMinimum:
                        default:
                        {
                            float minimumDisplacement = fmaxf(displacement, diff);
                            displacement = minimumDisplacement - _padding;
                            break;
                        }
                    }
                    
                    if (_avoidingViewUsesAutoLayout) { // if view uses constrains
                        for (NSLayoutConstraint *constraint in _avoidingView.superview.constraints) {
                            if (constraint.secondItem == _avoidingView && (constraint.secondAttribute == NSLayoutAttributeCenterY || constraint.secondAttribute == NSLayoutAttributeTop || constraint.secondAttribute == NSLayoutAttributeBottom)) {
                                if (![_updatedConstraints containsObject:constraint]) {
                                    [_updatedConstraints addObject:constraint];
                                    [_updatedConstraintConstants addObject:[NSNumber numberWithFloat:constraint.constant]];
                                }
                                constraint.constant -= displacement;
                                break;
                            }
                        }
                        [_avoidingView.superview layoutIfNeeded];
                    }
                    
                    [UIView animateWithDuration:animationDuration
                                          delay:delay
                                        options:animationDuration > 0 ? (animationCurve << 16) : UIViewAnimationOptionCurveLinear
                                     animations:^{
                                         if (_avoidingViewUsesAutoLayout) {
                                             [_avoidingView.superview layoutIfNeeded]; // to animate constraint changes
                                         }
                                         else {
                                             // There is possible case of a frame changing keyboard change
                                             // (e.g. From Japanese Keyboard with auto-completion
                                             // to English keyboard without that), so we should not make
                                             // a translation, but translate the existing transform.
                                             CGAffineTransform transform = _avoidingView.transform;
                                             transform = CGAffineTransformTranslate(transform, 0, displacement);
                                             _avoidingView.transform = transform;
                                         }
                                     }
                                     completion:nil];
                    
                }
            }
        }
        
    }
    else if (_isKeyboardVisible) {
        // hiding, undocking or splitting
        
        switch (_keyboardAvoidingMode) {
            case KeyboardAvoidingModeMaximum:
            {
                
                break;
            }
            case KeyboardAvoidingModeMinimumDelayed:
            {
                animationDuration = _minimumAnimationDuration;
                break;
            }
            case KeyboardAvoidingModeMinimum:
            default:
            {
                break;
            }
        }
        
        // restore state
        if (_avoidingViewUsesAutoLayout) { // if view uses constrains
            for (int i = 0; i < _updatedConstraints.count; i++) {
                NSLayoutConstraint *updatedConstraint = [_updatedConstraints objectAtIndex:i];
                float updatedConstraintConstant = [[_updatedConstraintConstants objectAtIndex:i] floatValue];
                updatedConstraint.constant = updatedConstraintConstant;
                
            }
            [_avoidingView.superview layoutIfNeeded];
        }
        
        [UIView animateWithDuration:animationDuration + 0.075
                              delay:0
                            options:(animationCurve << 16)
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
    }
    _isKeyboardVisible = CGRectContainsRect(windowFrame, keyboardFrame);
}

+ (void)setAvoidingView:(UIView *)avoidingView withTarget:(UIView *)targetView;
{
    [self init];
    
    [_targetViews removeAllObjects];
    [_targetViews addObject:targetView];
    _avoidingView = avoidingView;
    _avoidingViewUsesAutoLayout = _avoidingView.superview.constraints.count > 0;
}

+ (void)addTarget:(UIView *)targetView;
{
    [_targetViews addObject:targetView];
}

+ (void)removeTarget:(UIView *)targetView;
{
    [_targetViews removeObject:targetView];
}

+ (void)removeAll {
    [_targetViews removeAllObjects];
    _avoidingView = nil;
}

+ (BOOL)isKeyboardVisible {
    return _isKeyboardVisible;
}

+ (void)setBuffer:(int)buffer {
    _buffer = buffer;
}

+ (void)setPadding:(int)padding {
    _padding = padding;
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
        _targetViews = [[NSMutableArray alloc] init];
        _updatedConstraints = [[NSMutableArray alloc] init];
        _updatedConstraintConstants = [[NSMutableArray alloc] init];
    });
}

#pragma mark -

+ (void)applicationDidEnterBackground:(NSNotification *)notification
{
    // Autolayout is reset when app goes into background, so we need to dismiss the keyboard too
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window.rootViewController.view endEditing:YES];
}

@end