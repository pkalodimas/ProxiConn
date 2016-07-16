//
//  AccountViewController.m
//  CarGPS
//
//  Created by Panos Kalodimas on 10/8/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "AccountViewController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

@synthesize usernameTextField;
@synthesize passwordTextField;
@synthesize confirmTextField;
@synthesize emailTextField;
@synthesize facebookTextField;
@synthesize nameTextField;
@synthesize signoutButton;
@synthesize confirmButton;
@synthesize navigationBar;
@synthesize accountLoadingView;
@synthesize commandRequest;
@synthesize option;
@synthesize manager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if( self.option == ACCOUNT_VIEW_SIGNUP){
        
        self.navigationBar.title = ACCOUNTVIEW_TITLE_SIGNUP;
        [self.confirmButton setTitle:ACCOUNTVIEW_CONFIRM_BUTTON_SIGNUP];
        [self.signoutButton setHidden:YES];
    }
    else{
        
        self.navigationBar.title = ACCOUNTVIEW_TITLE_EDIT_USER;
        [self.confirmButton setTitle:ACCOUNTVIEW_CONFIRM_BUTTON_EDIT_USER];
        [self.usernameTextField setEnabled:NO];
        
        self.usernameTextField.text = self.manager.user.username;
        self.passwordTextField.text = self.manager.user.password;
        self.confirmTextField.text = self.manager.user.password;
        self.emailTextField.text = [self.manager.user.info valueForKey:EMAIL];
        self.nameTextField.text = [self.manager.user.info valueForKey:NAME];
        self.facebookTextField.text = [self.manager.user.info valueForKey:FACEBOOK];
    }
    
    self.commandRequest = NULL;
    self.accountLoadingView.hidden = YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)cancelButtonPushed:(id)sender{
    
    if( self.commandRequest ) [self.manager cancelCommand:self.commandRequest sender:self];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(IBAction)signoutButtonPushed:(id)sender{
    
    if( !self.commandRequest ) [self signoutAlert:self];
}

-(void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex{
            
    if( buttonIndex ){
        
        self.commandRequest = [self.manager userSignout];
        if( self.commandRequest ){
            
            [self.commandRequest addDelegate:self];
            self.accountLoadingView.hidden = NO;
            [self.accountLoadingView startAnimating];
        }
        else if( !self.manager.netStatus ) [self noNetworkAlert];
        else [self infoAlert:@"Signout" withMessage:@"Signout request denied. Please check services!"];
    }
}


-(IBAction)confirmButtonPushed:(id)sender{
    
    if( self.commandRequest ) return;
    
    //Checking textfields for errors!
    if( [self.usernameTextField.text isEqualToString:@""] ) [self errorAlert:ERROR_INVALID_USERNAME withMessage:ERROR_INVALID_USERNAME_MESSAGE];
    else if( [self.passwordTextField.text isEqualToString:@""] ) [self errorAlert:ERROR_INVALID_PASSWORD withMessage:ERROR_INVALID_PASSWORD_MESSAGE];
    else if( ![self.passwordTextField.text isEqualToString:self.confirmTextField.text] ) [self errorAlert:ERROR_PASSWORD_NOT_MATCH withMessage:ERROR_PASSWORD_NOT_MATCH_MESSAGE];
    else if( [self.emailTextField.text rangeOfString:@"@"].location == NSNotFound ) [self.manager errorAlert:ERROR_INVALID_EMAIL withMessage:ERROR_INVALID_EMAIL_MESSAGE];
    else{
        //Everything is fine
        CarGpsUser *user = [[CarGpsUser alloc] initWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
        user.info = [NSMutableDictionary dictionaryWithObjectsAndKeys: self.emailTextField.text, EMAIL,
                                                                            self.facebookTextField.text, FACEBOOK,
                                                                            self.nameTextField.text, NAME, nil];
    
        if( self.option == ACCOUNT_VIEW_EDIT_USER)  self.commandRequest = [self.manager userEdit:user];
        else self.commandRequest = [self.manager userSignup:user];
        
        if( self.commandRequest ) {
            
            [self.commandRequest addDelegate:self];
            self.accountLoadingView.hidden = NO;
            [self.accountLoadingView startAnimating];
        }
        else if( !self.manager.netStatus ) [self noNetworkAlert];
        else if( self.option == ACCOUNT_VIEW_EDIT_USER) [self infoAlert:@"Edit User" withMessage:@"Edit user request denied. Please check services"];
        else [self infoAlert:@"Signup" withMessage:@"Signup request denied. Please check services!"];
    }
}

-(void)serverCommandHanler:(id)command{
    
    if( ![self.commandRequest isEqual:command] ) return;
    
    if( self.commandRequest.error != 0 ) [self.manager serverErrorHanler:self.commandRequest.error withAlert:YES];
    else{
        switch(self.commandRequest.command) {
            case SERVER_EDIT_USER:{
                [self infoAlert:@"Account Edit" withMessage:@"User profile succesfully updated."];
                break;
            }
            case SERVER_SIGNUP:{
                [self infoAlert:@"Signup" withMessage:@"User account succesfully created. Use your e-mail to activate it."];
                break;
            }
            case SERVER_SIGNOUT:{
                [self infoAlert:@"Signout" withMessage:@"User profile succesfully deleted."];
                [self cancelButtonPushed:nil];
                break;
            }
            default:
                break;
        }
    }
    
    [self.accountLoadingView stopAnimating];
    self.accountLoadingView.hidden = YES;
    self.commandRequest = nil;
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if( [textField isEqual:self.nameTextField] || [textField isEqual:self.facebookTextField] ) [self keyboardAnimation:NO];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    
    if( [textField isEqual:self.nameTextField] || [textField isEqual:self.facebookTextField] ) [self keyboardAnimation:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField endEditing:YES];
    return NO;
}

-(void)keyboardAnimation:(Boolean)up{
    
    int pixels = ( up ) ? 130 : -130;
    
    [UIView beginAnimations:@"animations" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    if( self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ) self.view.frame = CGRectOffset(self.view.frame, pixels, 0);
    else if( self.interfaceOrientation == UIInterfaceOrientationLandscapeRight ) self.view.frame = CGRectOffset(self.view.frame, -pixels, 0);
    else self.view.frame = CGRectOffset(self.view.frame, 0, pixels);
    [UIView commitAnimations];
}


@end
