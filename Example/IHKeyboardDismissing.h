//
//  IHKeyboardDismissing.h
//  Idle Hands Apps
//
//  Created by Fraser Scott-Morrison on 30/05/14.
//  Copyright (c) 2014 Idle Hands Apps Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IHKeyboardDismissingDelegate <NSObject>

- (void)hasResignedAResponder;

@end

@interface IHKeyboardDismissing : UIView

@property (nonatomic, weak) NSObject <IHKeyboardDismissingDelegate> *delegate;

+ (BOOL)resignAnyFirstResponder:(UIView *)view;

@end
