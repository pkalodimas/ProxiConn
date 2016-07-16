//
//  CarGpsClient.h
//  CarGPS
//
//  Created by Panos Kalodimas on 10/13/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <arpa/inet.h>

#import "AppDefinitions.h"
#import "reachability.h"
#import "CarGpsSettings.h"
#import "CarGpsUser.h"
#import "CarGpsServerCommand.h"

@protocol CarGpsClientDelegate @required

-(void)clientNetworkStatusChanged:(Boolean)status;
-(void)serverCommandHanler:(CarGpsServerCommand*)command;

@end

@interface CarGpsClient : Reachability <NSURLConnectionDelegate, NSURLConnectionDataDelegate>{

    Boolean netStatus;
    NSString *server;
    NSURL *serverUrl;
    NSString *session;
    NSMutableArray *serverCommands;
    id <CarGpsClientDelegate> delegate;
}

@property (assign, nonatomic) Boolean netStatus;
@property (retain, nonatomic) NSString *server;
@property (retain, nonatomic) NSURL *serverUrl;
@property (retain, nonatomic) NSString *session;
@property (retain, nonatomic) NSMutableArray *serverCommands;
@property (retain, nonatomic) id delegate;


//Init Methods
-(id)init;
-(id)initWithDelegate:(id)delegateID andSettings:(NSMutableDictionary*)settings;
-(id)initFromDictionary:(NSMutableDictionary*)settings;

//Network Methods
-(void)startNetworkConnection;
-(void)stopNetworkConnection;
-(void)restartNetworkConnection;

-(void)networkStatusChanged:(NSNotification*)note;
-(CarGpsServerCommand*)sendCommand:(NSDictionary*)data;
-(CarGpsServerCommand*)getCommand:(ServerCommands)cCode;
-(Boolean)removeCommand:(CarGpsServerCommand*)command;
-(void)clearCommands;
-(void)cancelCommand:(CarGpsServerCommand*)command;
-(Boolean)commandIsValid:(ServerCommands)cCode;

//Server Methods
-(void)startSession:(NSString*)sid;
-(void)destroySession;

-(CarGpsServerCommand*)sendPing;

-(CarGpsServerCommand*)userLogin:(CarGpsUser*)user;
-(CarGpsServerCommand*)userLogout;

-(CarGpsServerCommand*)updateLocation:(CLLocationCoordinate2D)coordinates;

-(CarGpsServerCommand*)userNeighbours:(CLLocationCoordinate2D)coordinates withRange:(NSNumber*)range;

-(CarGpsServerCommand*)userInfo:(NSString*)username;

-(CarGpsServerCommand*)signup:(CarGpsUser*)user;
-(CarGpsServerCommand*)signout;

-(CarGpsServerCommand*)userEdit:(CarGpsUser*)user;


@end
