//
//  NSObject+CarGpsAlerts.h
//  CarGPS
//
//  Created by Panos Kalodimas on 10/20/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarGpsUser.h"


@protocol CarGpsAlertDelegate @optional

-(void)CarGpsAlertLoginReturnValue:(Boolean)status;

@end

@interface NSObject (CarGpsAlerts) 

-(void)infoAlert:(NSString*)header withMessage:(NSString*)message;
-(void)errorAlert:(ServerErrors)error withMessage:(NSString*)message;
-(void)noGPSAlert;
-(void)noNetworkAlert;
-(void)noServerAlert;
-(void)noLoginAlert;
-(void)loginAlert:(id<UIAlertViewDelegate>)delegate withUser:(CarGpsUser*)user;
-(void)signoutAlert:(id<UIAlertViewDelegate>)delegate;

@end
