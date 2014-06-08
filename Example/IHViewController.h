//
//  IHViewController.h
//  IHKeyboardAvoiding
//
//  Created by Fraser Scott-Morrison on 18/04/13.
//  Copyright (c) 2013 Idle Hands Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IHViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIView* targetView;
@property (nonatomic, strong) IBOutlet UIView* avoidingView;
@property (nonatomic, strong) IBOutlet UITextField* textField1;
@property (nonatomic, strong) IBOutlet UITextField* textField2;

@end
