//
//  NSObject+CarGpsAlerts.m
//  CarGPS
//
//  Created by Panos Kalodimas on 10/20/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsAlerts.h"

@implementation NSObject (CarGpsAlerts)


-(void)infoAlert:(NSString *)header withMessage:(NSString *)message{

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:header message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

-(void)errorAlert:(ServerErrors)error withMessage:(NSString *)message{
    
    [self infoAlert:[NSString stringWithFormat:@"Error - %d", error] withMessage:message];
}

-(void)noGPSAlert{
    
    [self infoAlert:@"No GPS Connection" withMessage:@"Please check network connectivity!"];
}

-(void)noNetworkAlert{
    
    [self infoAlert:@"No Network Connection" withMessage:@"Please check network connectivity!"];
}

-(void)noServerAlert{
    
    [self infoAlert:[NSString stringWithFormat:@"Error %d", ERROR_SERVER_NOT_RESPOND] withMessage:ERROR_SERVER_NOT_RESPOND_MESSAGE];
}

-(void)noLoginAlert{
    
    [self infoAlert:@"User not Logged" withMessage:@"Please login to the server!"];
}

-(void)loginAlert:(id)delegate withUser:(CarGpsUser*)user{
    
    UIAlertView *loginAlert = [[UIAlertView alloc] initWithTitle:@"Login" message:nil delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
    
    [loginAlert setAlertViewStyle:UIAlertViewStyleLoginAndPasswordInput];
    if( user ){
        [[loginAlert textFieldAtIndex:0] setText:user.username];
        [[loginAlert textFieldAtIndex:1] setText:user.password];
    }
    
    [loginAlert show];
}

-(void)signoutAlert:(id<UIAlertViewDelegate>)delegate{
    
    UIAlertView *signoutAlert = [[UIAlertView alloc] initWithTitle:@"Signout" message:@"Caution! You are about to delete your account!" delegate:delegate cancelButtonTitle:@"Cancel" otherButtonTitles:@"Signout", nil];
    [signoutAlert show];
}


@end
