//
//  IHAppDelegate.h
//  IHKeyboardAvoiding
//
//  Created by Fraser Scott-Morrison on 18/04/13.
//  Copyright (c) 2013 Idle Hands Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IHViewController;

@interface IHAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) IHViewController *viewController;

@end
