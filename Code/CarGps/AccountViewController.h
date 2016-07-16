//
//  AccountViewController.h
//  CarGPS
//
//  Created by Panos Kalodimas on 10/8/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDefinitions.h"
#import "CarGpsAlerts.h"
#import "CarGpsAppManager.h"

@interface AccountViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, CarGpsServerCommandDelegate> {
    
    UITextField *usernameTextField;
    UITextField *passwordTextField;
    UITextField *confirmTextField;
    UITextField *emailTextField;
    UITextField *facebookTextField;
    UITextField *nameTextField;
    UIButton *signoutButton;
    UIBarButtonItem *confirmButton;
    UINavigationItem *navigationBar;
    UIActivityIndicatorView *accountLoadingView;

    CarGpsServerCommand *commandRequest;
    AccountViewOptions option;
    CarGpsAppManager *manager;
}

@property (retain, nonatomic) IBOutlet UITextField *usernameTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;
@property (retain, nonatomic) IBOutlet UITextField *confirmTextField;
@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *facebookTextField;
@property (retain, nonatomic) IBOutlet UITextField *nameTextField;
@property (retain, nonatomic) IBOutlet UIButton *signoutButton;
@property (retain, nonatomic) IBOutlet UIBarButtonItem *confirmButton;
@property (retain, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *accountLoadingView;
@property (retain, nonatomic) CarGpsServerCommand *commandRequest;
@property (assign, nonatomic) AccountViewOptions option;
@property (retain, nonatomic) CarGpsAppManager *manager;

-(IBAction)signoutButtonPushed:(id)sender;
-(IBAction)cancelButtonPushed:(id)sender;
-(IBAction)confirmButtonPushed:(id)sender;

-(void)keyboardAnimation:(Boolean)up;

@end
