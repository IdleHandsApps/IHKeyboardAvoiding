//
//  IHKeyboardAvoiding.h
//  IHKeyboardAvoiding
//
//  Created by Fraser Scott-Morrison on 29/03/13.
//  Copyright (c) 2013 Idle Hands Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

enum KeyboardAvoidingMode {
    KeyboardAvoidingModeMaximum = 0, // Avoiding starts with keyboard and moves up same distance as keyboard
    KeyboardAvoidingModeMinimum = 1, // default. Avoiding starts with keyboard and moves up just enough to remain visible
    KeyboardAvoidingModeMinimumDelayed = 2 // Avoiding doesnt start until the keyboard is about to intercept, then avoiding moves up just enought to remain visible
}
typedef KeyboardAvoidingMode;

@interface IHKeyboardAvoiding : NSObject

// use this call for general avoiding
+ (void)setAvoidingView:(UIView *)avoidingView;

// if you want the triggering view to be different to the avoiding view, use this
+ (void)setAvoidingView:(UIView *)avoidingView withTriggerView:(UIView *)triggerView;
// if you want additional trigger views, use this
+ (void)addTriggerView:(UIView *)triggerView;
// removes a trigger
+ (void)removeTriggerView:(UIView *)triggerView;

// sets avoiding view to nil, and removes any trigger views
+ (void)removeAll;

// changes the avoiding mode
+ (void)setKeyboardAvoidingMode:(KeyboardAvoidingMode)keyboardAvoidingMode;

// static padding between the keyboard and avoiding views. Default padding is 0 points.
+ (void)setPadding:(int)padding;

// padding between the keyboard and current avoiding view. If not set, uses the static padding value, above.
+ (void)setPaddingForCurrentAvoidingView:(int)padding;

// If the visible keyboard plus the buffer intersect with the targetView, then the avoiding View will be moved. Default buffer is 0 points
+ (void)setBuffer:(int)buffer;

// utility method to find out if the keyboard is visible. Works for docked, undocked and split keyboards
+ (BOOL)isKeyboardVisible;


// deprecated
+ (void)setAvoidingView:(UIView *)avoidingView withTarget:(UIView *)targetView NS_DEPRECATED_IOS(2_0,5_0); // use setAvoidingView:(UIView *)avoidingView; or setAvoidingView:(UIView *)avoidingView withTrigger:(UIView *)triggerView;
+ (void)addTarget:(UIView *)targetView NS_DEPRECATED_IOS(2_0,5_0); // use addTrigger:(UIView *)triggerView;
+ (void)removeTarget:(UIView *)targetView NS_DEPRECATED_IOS(2_0,5_0); // removeTrigger:(UIView *)triggerView;
@end
