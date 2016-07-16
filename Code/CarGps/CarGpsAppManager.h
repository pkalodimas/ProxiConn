//
//  CarGpsAppManager.h
//  CarGPS
//
//  Created by Panos Kalodimas on 9/21/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "AppDefinitions.h"
#import "CarGpsSettings.h"
#import "CarGpsAlerts.h"
#import "CarGpsUser.h"
#import "CarGpsClient.h"
#import "CarGpsLocationManager.h"

@protocol CarGpsAppManagerDelegate @optional

-(void)AppManagerNetworkStatusChanged:(id)appmanager;
-(void)AppManagerServerStatusChanged:(id)appmanager;
-(void)AppManagerGpsStatusChanged:(id)appmanager;
-(void)AppManagerLogStatusChanged:(id)appmanager;
-(void)AppManagerLocationChanged:(id)appmanager;
-(void)AppManagerNeighboursUpdated:(id)appmanager;

@end

@interface CarGpsAppManager : NSObject <CarGpsLocationManagerDelegate, CarGpsClientDelegate, UIAlertViewDelegate> {
    
    Boolean notificationFlag;
    Boolean autoLoginFlag;
    
    Boolean gpsStatus;
    Boolean netStatus;
    Boolean serverStatus;
    LogState logStatus;
    
    CarGpsLocationManager *gpsManager;
    CarGpsClient *serverClient;
    CarGpsUser *user;
    NSMutableArray *neighbours;

    NSMutableArray *delegates;
    NSTimer *sessionTimer;
    NSTimer *locationTimer;
    NSTimer *neighboursTimer;
}

@property (assign, nonatomic) Boolean notificationFlag;
@property (assign, nonatomic) Boolean autoLoginFlag;
@property (assign, nonatomic) Boolean gpsStatus;
@property (assign, nonatomic) Boolean netStatus;
@property (assign, nonatomic) Boolean serverStatus;
@property (assign, nonatomic) LogState logStatus;
@property (retain, nonatomic) CarGpsLocationManager *gpsManager;
@property (retain, nonatomic) CarGpsClient *serverClient;
@property (retain, nonatomic) CarGpsUser *user;
@property (retain, nonatomic) NSMutableArray *delegates;
@property (retain, nonatomic) NSTimer *sessionTimer;
@property (retain, nonatomic) NSTimer *locationTimer;
@property (retain, nonatomic) NSTimer *neighboursTimer;
@property (retain, nonatomic) NSMutableArray *neighbours;


//Init Methods
-(id)initFromSettings;
-(void)startServices;
-(void)stopServices;
-(void)restartServices;

//GPS Methods
-(void)startClientConnection;
-(void)stopClientConnection;
-(void)restartClientConnection;
-(void)startLocationServices;
-(void)stopLocationServices;
-(void)restartLocationServices;

//Delegation Methods
-(void)delegateAdd:(id)delegate;
-(void)delegateRemove:(id)delegate;
-(void)netDelegateNotification;
-(void)serverDelegateNotification;
-(void)logDelegateNotification;
-(void)gpsDelegateNotification;
-(void)locationDelegateNotification;
-(void)neighbourDelegateNotification;
-(void)delegatesNotify:(AppManagerNotification)notification;

//Private Methods
-(void)gpsConnectionStatusChanged:(Boolean)status;
-(void)serverLogStatusChanged:(LogState)status;
-(void)serverStatusChanged:(Boolean)status;
-(void)updateNeighbours:(NSArray*)newNeighbours;

//Command Methods
-(void)serverErrorHanler:(ServerErrors)error withAlert:(Boolean)alert;
-(void)cancelCommand:(CarGpsServerCommand*)command sender:(id)sender;
-(CarGpsServerCommand*)getCommand:(ServerCommands)cCode;
-(void)clearCommands;

//Server Commands Methods
-(void)sessionUpdateStart;
-(void)sessionUpdateStop;

-(CarGpsServerCommand*)userLogin;
-(void)userLoginResponse:(CarGpsServerCommand*)command;
-(CarGpsServerCommand*)userLogout;
-(void)userLogoutResponse:(CarGpsServerCommand*)command;

-(CarGpsServerCommand*)userLocationUpdate;
-(void)userLocationUpdatingStart;
-(void)userLocationUpdatingStop;
-(void)userLocationUpdateResponse:(CarGpsServerCommand*)command;

-(CarGpsServerCommand*)userNeighboursUpdate;
-(void)userNeighboursUpdatingStart;
-(void)userNeighboursUpdatingStop;
-(void)userNeighboursResponse:(CarGpsServerCommand*)command;

-(CarGpsServerCommand*)userInfo:(CarGpsUser*)userInfo;
-(void)userInfoResponse:(CarGpsServerCommand*)command;

-(CarGpsServerCommand*)userSignup:(CarGpsUser*)newUser;
-(void)userSignupResponse:(CarGpsServerCommand*)command;
-(CarGpsServerCommand*)userSignout;
-(void)userSignoutResponse:(CarGpsServerCommand*)command;

-(CarGpsServerCommand*)userEdit:(CarGpsUser*)newUser;
-(void)userEditResponse:(CarGpsServerCommand*)command;

@end
