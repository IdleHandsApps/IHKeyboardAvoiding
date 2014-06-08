//
//  IHViewController.m
//  IHKeyboardAvoiding
//
//  Created by Fraser Scott-Morrison on 18/04/13.
//  Copyright (c) 2013 Idle Hands Apps. All rights reserved.
//

#import "IHViewController.h"
#import "IHKeyboardAvoiding.h"

@interface IHViewController ()

@end

@implementation IHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.avoidingView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"diamond_upholstery"]];
    
    [IHKeyboardAvoiding setAvoidingView:self.avoidingView withTarget:self.targetView];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField; 
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
