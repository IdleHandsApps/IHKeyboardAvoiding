//
//  IHKeyboardDismissing.m
//  Idle Hands Apps
//
//  Created by Fraser Scott-Morrison on 30/05/14.
//  Copyright (c) 2014 Idle Hands Apps Ltd. All rights reserved.
//

#import "IHKeyboardDismissing.h"

@implementation IHKeyboardDismissing

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    BOOL hasResigned = [IHKeyboardDismissing resignAnyFirstResponder:self];
    
    if (self.delegate && hasResigned) {
        [self.delegate hasResignedAResponder];
    }
}

+ (BOOL)resignAnyFirstResponder:(UIView *)view
{
    BOOL hasResigned = NO;
    for (UIView *subView in view.subviews) {
        if ([subView isFirstResponder]) {
            [subView resignFirstResponder];
            hasResigned = YES;
            if ([subView isKindOfClass:[UISearchBar class]]) {
                [(UISearchBar *)subView setShowsCancelButton:NO animated:YES];
            }
            break;
        }
        else {
            hasResigned = [IHKeyboardDismissing resignAnyFirstResponder:subView] || hasResigned;
        }
    }
    return hasResigned;
}

@end
