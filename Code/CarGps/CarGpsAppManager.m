//
//  CarGpsAppManager.m
//  CarGPS
//
//  Created by Panos Kalodimas on 9/21/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsAppManager.h"

@implementation CarGpsAppManager

@synthesize notificationFlag;
@synthesize autoLoginFlag;
@synthesize gpsStatus;
@synthesize netStatus;
@synthesize serverStatus;
@synthesize logStatus;
@synthesize gpsManager;
@synthesize serverClient;
@synthesize user;
@synthesize delegates;
@synthesize sessionTimer;
@synthesize locationTimer;
@synthesize neighboursTimer;
@synthesize neighbours;

-(id)init{
    
    self.notificationFlag = YES;
    self.autoLoginFlag = NO;
    self.gpsStatus = NO;
    self.netStatus = NO;
    self.serverStatus = NO;
    self.logStatus = LOG_STATE_LOGOUT;
    self.gpsManager = [[CarGpsLocationManager alloc] initWithDelegate:self];
    self.serverClient = [[CarGpsClient alloc] init];
    self.user = [[CarGpsUser alloc] init];
    self.delegates = [NSMutableArray array];
    self.sessionTimer = nil;
    self.locationTimer = nil;
    self.neighboursTimer = nil;
    self.neighbours = [NSMutableArray array];
    
    return self;
}

-(id)initFromSettings{
    
    self = [self init];
    
    NSMutableDictionary *settings = [self loadSettings];
    
    //user
    self.autoLoginFlag = [[self getSetting:settings name:SETTINGS_AUTOLOGIN] boolValue];
    if( [self getSetting:settings name:SETTINGS_REMEMBER_LAST_USER] )  self.user = [self loadLastUser:settings];
    if( !self.user ) self.user = [[CarGpsUser alloc] init];
    
    return self;
}

-(void)startServices{
    
    NSLog(@"[AppManager start services]\n");

    [self startLocationServices];
    [self startClientConnection];
    [self userLogin];
}

-(void)stopServices{
    
    NSLog(@"[AppManager stop services]");

    [self userLogout];
    [self stopLocationServices];
    [self.serverClient stopNetworkConnection];
}

-(void)restartServices{
    
    NSLog(@"[AppManager restart service]\n");
    
    self.notificationFlag = NO;
    [self restartLocationServices];
    [self restartClientConnection];
    self.notificationFlag = YES;
}

-(void)startLocationServices{
    
    if( !self.gpsManager ) self.gpsManager = [[CarGpsLocationManager alloc] initWithDelegate:self];
    [self.gpsManager initWithSettings:[self loadSettings]];
    [self.gpsManager startLocationService];
}

-(void)stopLocationServices{
    
    [self.gpsManager stopLocationService];
}

-(void)restartLocationServices{
    
    NSLog(@"[AppManager stop gps connection]\n");
    
    self.notificationFlag = NO;
    [self.gpsManager restartLocationService];
    self.notificationFlag = YES;
}

-(void)startClientConnection{
    
    NSLog(@"[AppManager start client]\n");
    
    if( !self.serverClient ) self.serverClient = [[CarGpsClient alloc] init];
    
    self.serverClient = [self.serverClient initWithDelegate:self andSettings:[self loadSettings]];
    [self.serverClient startNetworkConnection];
}

-(void)stopClientConnection{
    
    NSLog(@"[AppManager stop client]\n");
    
    [self.serverClient stopNetworkConnection];
}

-(void)restartClientConnection{
    
    NSLog(@"[AppManager restart client]\n");
    
    self.notificationFlag = NO;
    self.serverClient = [self.serverClient initFromDictionary:[self loadSettings]];
    [self.serverClient restartNetworkConnection];
    self.notificationFlag = YES;
}

//---------------------------------------------------------------------------
//---------------------------- gpsManager Delegate --------------------------
//---------------------------------------------------------------------------

-(void)LocationManagerStateChanged:(LocationState)state{
    
    if( state == LOCATION_STATE_OFF) [self gpsConnectionStatusChanged:NO];
    else [self gpsConnectionStatusChanged:YES];
}

-(void)LocationManagerLocationChanged:(CLLocationCoordinate2D)coordinates{
    
    if( !self.gpsStatus ) [self gpsConnectionStatusChanged:YES];
    if( self.user ) self.user.coordinate = coordinates;
}

//---------------------------------------------------------------------------
//---------------------------- Stauts Methods -------------------------------
//---------------------------------------------------------------------------

-(void)gpsConnectionStatusChanged:(Boolean)status{
    
    NSLog(@"[AppManager gpsStatusChanged]:%d \n",status);
    
    if( self.gpsStatus == status ) return;
    else self.gpsStatus = status;
        
    if( self.gpsStatus ) {
        
        if( self.netStatus && self.logStatus == LOG_STATE_LOGIN ) [self userLocationUpdatingStart];
        else if( self.netStatus && self.autoLoginFlag ) [self userLogin];
    }
    else {
        
        [self userLocationUpdatingStop];
        if( self.notificationFlag ) [self noGPSAlert];
    }
    
    [self delegatesNotify:APPMANAGER_GPS_NOTIFICATION];
}

//Delegate from server client
-(void)clientNetworkStatusChanged:(Boolean)status{
    
    NSLog(@"[AppManager NetworkStatusChanged]:%d\n", status);
   
    if( self.netStatus == status ) return;
    else self.netStatus = status;
    
    if( self.netStatus ){
        
        if( self.gpsStatus && self.autoLoginFlag ) [self userLogin];
        //else [self.serverClient sendPing];
        else [self sessionUpdateStart];
    }
    else {
        
        [self sessionUpdateStop];
        [self serverStatusChanged:NO];
        //[self serverLogStatusChanged:LOG_STATE_LOGOUT]; //isws na fugei
        if( self.notificationFlag ) [self noNetworkAlert];
    }
    
    [self delegatesNotify:APPMANAGER_NET_NOTIFICATION];
}

-(void)serverLogStatusChanged:(LogState)status{
    
    NSLog(@"[AppManager logStatusChanged]:%d\n", status);
    
    if( self.logStatus == status ) return;
    else self.logStatus = status;
    
    if( status == LOG_STATE_LOGIN ){
        
        NSMutableDictionary *settings = [self loadSettings];
        [self sessionUpdateStop];
        [self userLocationUpdatingStart];
        if( [self getSetting:settings name:SETTINGS_NEIGHBOUR_UPDATE_TIME] != 0 ) [self userNeighboursUpdatingStart];
    }
    else if( status == LOG_STATE_PENDING ){ [self sessionUpdateStop]; }
    else if( status == LOG_STATE_ERROR ){
        
        [self userLocationUpdatingStop];
        [self userNeighboursUpdatingStop];
        if( self.netStatus ) [self sessionUpdateStart];
    }
    else{
                    
        [self userLocationUpdatingStop];
        [self userNeighboursUpdatingStop];
        if( self.neighbours.count > 0 ){
                
            [self.neighbours removeAllObjects];
            [self delegatesNotify:APPMANAGER_NEIGHBOURS_NOTIFICATION];
        }
        if( self.netStatus && self.gpsStatus && self.autoLoginFlag ) [NSTimer scheduledTimerWithTimeInterval:[[self getSetting:nil name:SETTINGS_SESSION_UPDATE_TIME] integerValue] target:self selector:@selector(userLogin) userInfo:nil repeats:NO];
        else if( self.netStatus ) [self sessionUpdateStart];
    }
    
    [self delegatesNotify:APPMANAGER_LOG_NOTIFICATION];
}

-(void)serverStatusChanged:(Boolean)status{
    
    NSLog(@"[AppManager serverStatusChanged]:%d\n", status);

    if( self.serverStatus == status ) return;
    
    self.serverStatus = status;
    [self delegatesNotify:APPMANAGER_SERVER_NOTIFICATION];
    [self serverLogStatusChanged:LOG_STATE_LOGOUT];
}


//---------------------------------------------------------------------------
//---------------------------- Delegade Methods -----------------------------
//---------------------------------------------------------------------------

-(void)netDelegateNotification{
    
    for( int i=0; i<self.delegates.count; i++ ){
        
        NSObject <CarGpsAppManagerDelegate> *delegate = [self.delegates objectAtIndex:i];
        if( [delegate respondsToSelector:@selector(AppManagerNetworkStatusChanged:)] ) [delegate AppManagerNetworkStatusChanged:self];
    }
}

-(void)serverDelegateNotification{
    
    for( int i=0; i<self.delegates.count; i++ ){
        
        NSObject <CarGpsAppManagerDelegate> *delegate = [self.delegates objectAtIndex:i];
        if( [delegate respondsToSelector:@selector(AppManagerServerStatusChanged:)] ) [delegate AppManagerServerStatusChanged:self];
    }
}

-(void)logDelegateNotification{
    
    for( int i=0; i<self.delegates.count; i++ ){
        
        NSObject <CarGpsAppManagerDelegate> *delegate = [self.delegates objectAtIndex:i];
        if( [delegate respondsToSelector:@selector(AppManagerLogStatusChanged:)] ) [delegate AppManagerLogStatusChanged:self];
    }
}

-(void)gpsDelegateNotification{
    
    for( int i=0; i<self.delegates.count; i++ ){
        
        NSObject <CarGpsAppManagerDelegate> *delegate = [self.delegates objectAtIndex:i];
        if( [delegate respondsToSelector:@selector(AppManagerGpsStatusChanged:)] ) [delegate AppManagerGpsStatusChanged:self];
    }
}

-(void)locationDelegateNotification{
    
    for( int i=0; i<self.delegates.count; i++ ){
        
        NSObject <CarGpsAppManagerDelegate> *delegate = [self.delegates objectAtIndex:i];
        if( [delegate respondsToSelector:@selector(AppManagerLocationChanged:)] ) [delegate AppManagerLocationChanged:self];
    }
}

-(void)neighbourDelegateNotification{
    
    for( int i=0; i<self.delegates.count; i++ ){
        
        NSObject <CarGpsAppManagerDelegate> *delegate = [self.delegates objectAtIndex:i];
        if( [delegate respondsToSelector:@selector(AppManagerNeighboursUpdated:)] ) [delegate AppManagerNeighboursUpdated:self];
    }
}

-(void)delegatesNotify:(AppManagerNotification)notification{
    
    if( !self.notificationFlag ) notification = APPMANAGER_NONE_NOTIFICATION;
    
    NSLog(@"[AppManager delegate notify]:%d \n",notification);
    
    switch (notification) {
        case APPMANAGER_GPS_NOTIFICATION:{
            [self gpsDelegateNotification];
            break;
        }
        case APPMANAGER_NET_NOTIFICATION:{
            [self netDelegateNotification];
            break;
        }
        case APPMANAGER_LOG_NOTIFICATION:{
            [self logDelegateNotification];
            break;
        }
        case APPMANAGER_LOCATION_NOTIFICATION:{
            [self locationDelegateNotification];
            break;
        }
        case APPMANAGER_NEIGHBOURS_NOTIFICATION:{
            [self neighbourDelegateNotification];
            break;
        }
        case APPMANAGER_SERVER_NOTIFICATION:{
            [self serverDelegateNotification];
            break;
        }
        default:
            break;
    }
}

-(void)delegateAdd:(id)delegate{
    
    if( delegate ) [self.delegates addObject:delegate];
}

-(void)delegateRemove:(id)delegate{
    
    if( delegate ) [self.delegates removeObject:delegate];
}


//---------------------------------------------------------------------------
//---------------------------- Client Methods -------------------------------
//---------------------------------------------------------------------------

-(void)sessionUpdateStart{
    
    if( self.sessionTimer ) [self.sessionTimer invalidate];
    self.sessionTimer = [NSTimer scheduledTimerWithTimeInterval:[[self getSetting:nil name:SETTINGS_SESSION_UPDATE_TIME] integerValue] target:self.serverClient selector:@selector(sendPing) userInfo:nil repeats:YES];
}

-(void)sessionUpdateStop{
    
    if( self.sessionTimer ) [self.sessionTimer invalidate];
    self.sessionTimer = nil;
}


//----------------------------- LOGIN
-(CarGpsServerCommand*)userLogin{
    
    NSLog(@"[AppManager userLogin]\n");

    if( !self.gpsStatus || !self.netStatus || self.logStatus > LOG_STATE_LOGOUT ) return nil;
    
    if( !user || [self.user.username isEqualToString:@""] || [self.user.password isEqualToString:@""] ){
        
        [self loginAlert:self withUser:self.user];
        return nil;
    }
    
    self.user.coordinate = self.gpsManager.coordinates;
    CarGpsServerCommand *command = [self.serverClient userLogin:self.user];
    if( !command ) return nil;
    
    [self serverLogStatusChanged:LOG_STATE_PENDING];
    return command;
}

-(void)userLoginResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    if( command.error == 0 ){
        
        [self.serverClient startSession:[command.response valueForKey:SESSION]];
        [self.user infoFromDictionary:command.response];
        [self serverLogStatusChanged:LOG_STATE_LOGIN];
        if( [[self getSetting:nil name:SETTINGS_REMEMBER_LAST_USER] boolValue] ) [self saveLastUser:self.user toSettings:nil];
    }
    else{
        
        if( ![[self getSetting:nil name:SETTINGS_REMEMBER_LAST_USER] boolValue] ) self.user.password = @"";
        [self serverErrorHanler:command.error withAlert:NO];

        if( command.error > 0 && command.error < 8 ) [self serverLogStatusChanged:LOG_STATE_LOGOUT];
        else [self serverLogStatusChanged:LOG_STATE_ERROR];
    }
    
    [command callDelegates];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if( buttonIndex == 1 ) {
        
        self.user = [[CarGpsUser alloc] initWithUsername:[[alertView textFieldAtIndex:0] text] password:[[alertView textFieldAtIndex:1] text]];
        [self userLogin];
    }
    else self.autoLoginFlag = NO;
}

//---------------------------------- LOGOUT
-(CarGpsServerCommand*)userLogout{
    
    NSLog(@"[AppManager userLogout]\n");

    if( !self.netStatus || self.logStatus != LOG_STATE_LOGIN ) return nil;
    
    CarGpsServerCommand *command = [self.serverClient userLogout];
    if( !command ) return nil;
        
    [self serverLogStatusChanged:LOG_STATE_PENDING];
    return command;
}

-(void)userLogoutResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    
    [self.serverClient destroySession];
    [self serverLogStatusChanged:LOG_STATE_LOGOUT];
    
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}

//------------------------------- LOCATION UPDATE
-(CarGpsServerCommand*)userLocationUpdate{
    
    NSLog(@"[AppManager locationUpdate]\n");

    if( !self.gpsStatus || !self.netStatus || self.logStatus != LOG_STATE_LOGIN ) return NULL;
                    
    return [self.serverClient updateLocation:self.gpsManager.coordinates];

}

-(void)userLocationUpdatingStart{
    
    int period = [[self getSetting:nil name:SETTINGS_SESSION_UPDATE_TIME] integerValue];
    if( period > 0 ) {
        
        [self userLocationUpdate];
        if( self.locationTimer ) [self.locationTimer invalidate];
        self.locationTimer = [NSTimer scheduledTimerWithTimeInterval:(double)period target:self selector:@selector(userLocationUpdate) userInfo:nil repeats:YES];
    }
}

-(void)userLocationUpdatingStop{
    
    if( self.locationTimer ) [self.locationTimer invalidate];
    self.locationTimer = nil;
}

-(void)userLocationUpdateResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}

//---------------------------------- NEIGHBOURS
-(CarGpsServerCommand*)userNeighboursUpdate{
    
    NSLog(@"[AppManager userNeighbors]\n");

    if( !self.netStatus || self.logStatus != LOG_STATE_LOGIN  ) return nil;
                    
    if( self.gpsStatus ) return [self.serverClient userNeighbours:self.gpsManager.coordinates withRange:[self getSetting:nil name:SETTINGS_NEIGHBOUR_RANGE]];
    else return [self.serverClient userNeighbours:CLLocationCoordinate2DMake(0, 0) withRange:[self getSetting:nil name:SETTINGS_NEIGHBOUR_RANGE]];
}

-(void)userNeighboursUpdatingStart{
    
    int period = [[self getSetting:nil name:SETTINGS_NEIGHBOUR_UPDATE_TIME] integerValue];
    if( period > 0 ) {
        
        [self userNeighboursUpdate];
        if( self.neighboursTimer ) [self.neighboursTimer invalidate];
        self.neighboursTimer = [NSTimer scheduledTimerWithTimeInterval:(double)period target:self selector:@selector(userNeighboursUpdate) userInfo:nil repeats:YES];
    }
}

-(void)userNeighboursUpdatingStop{
    
    if( self.neighboursTimer ) [self.neighboursTimer invalidate];
    self.neighboursTimer = nil;
}

-(void)userNeighboursResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    if( command.error == 0 ){
    
        NSArray *neighbourhood = [command.response valueForKey:NEIGHBOURS];
        if( neighbourhood ){
        
            NSMutableArray *newNeighbours = [NSMutableArray array];
            for (int i=0; i<neighbourhood.count; i++) [newNeighbours addObject:[[CarGpsUser alloc] initNeighbour:[neighbourhood objectAtIndex:i]]];
        
            [self updateNeighbours:newNeighbours];
        }
    }
    
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}

//---------------------------------------------- INFO
-(CarGpsServerCommand*)userInfo:(CarGpsUser *)userInfo{
    
    NSLog(@"[AppManager user info]\n");

    if( !userInfo || !self.netStatus || self.logStatus != LOG_STATE_LOGIN ) return nil;
                    
    return [self.serverClient userInfo:userInfo.username];
}

-(void)userInfoResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}

//-------------------------------------------- SIGNUP
-(CarGpsServerCommand*)userSignup:(CarGpsUser *)newUser{
    
    NSLog(@"[AppManager signup]\n");

    if( !self.netStatus || !newUser ) return nil;
            
    return [self.serverClient signup:newUser];        
}

-(void)userSignupResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}

//------------------------------------ SIGNOUT
-(CarGpsServerCommand*)userSignout{
    
    NSLog(@"[AppManager signout]\n");

    if( !self.netStatus || self.logStatus != LOG_STATE_LOGIN ) return nil;
            
    return [self.serverClient signout];
}

-(void)userSignoutResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    if( command.error == 0 ) [self userLogoutResponse:command];
    
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}

//----------------------------------------------  EDIT USER
-(CarGpsServerCommand*)userEdit:(CarGpsUser *)newUser{
    
    NSLog(@"[AppManager user edit]\n");

    if( !newUser || !self.netStatus || self.logStatus != LOG_STATE_LOGIN ) return nil;
    
    return [self.serverClient userEdit:newUser];
}

-(void)userEditResponse:(CarGpsServerCommand *)command{
    
    if( !command ) return;
    if( command.error == 0 ){
     
        [self.user infoFromDictionary:command.data];
        self.user.password = [command.data valueForKey:PASSWORD];
    }
    
    [self serverErrorHanler:command.error withAlert:NO];
    [command callDelegates];
}


//---------------------------------------------------------------------------
//---------------------------- Delegates ------------------------------------
//---------------------------------------------------------------------------

-(void)updateNeighbours:(NSArray *)newNeighbours{
    
    if( !newNeighbours ) return;
    
    [self.neighbours removeAllObjects];
    for( int i=0; i<newNeighbours.count; i++ ) {
        
        CarGpsUser *neighbour = [newNeighbours objectAtIndex:i];
        if( [neighbour.username isEqualToString:self.user.username] ) continue;
        
        [neighbour countDinstane:self.gpsManager.coordinates];
        int j;
        for( j=0; j<self.neighbours.count; j++ ) if( [[self.neighbours objectAtIndex:j]  distance] > neighbour.distance ) break;
                
        if( neighbour ) [self.neighbours insertObject:neighbour atIndex:j];
    }
    [self delegatesNotify:APPMANAGER_NEIGHBOURS_NOTIFICATION];
}

-(void)cancelCommand:(CarGpsServerCommand*)command sender:(id)sender{
    
    if( !command || !sender ) return;
    
    [command removeDelegate:sender];
    if( command.delegates.count == 0 ) [self.serverClient cancelCommand:command];
}

-(CarGpsServerCommand*)getCommand:(ServerCommands)cCode{
    
    return [self.serverClient getCommand:cCode];
}

-(void)clearCommands{
    
    [self.serverClient clearCommands];
}

//Delegate from client also
-(void)serverCommandHanler:(CarGpsServerCommand*)command{
    
    NSLog(@"[AppManager command handler]c=%d, e=%d\n", command.command, command.error);

    if( !command ) return;
    if( command.error == ERROR_SERVER_NOT_RESPOND ) [self serverStatusChanged:NO];
    else [self serverStatusChanged:YES];
    
    switch (command.command) {
        case SERVER_LOGIN:{
            [self userLoginResponse:command];
            break;
        }
        case SERVER_LOGOUT:{
            [self userLogoutResponse:command];
        }
        case SERVER_UPDATE_LOCATION:{
            [self userLocationUpdateResponse:command];
            break;
        }
        case SERVER_NEIGHBOURS:{
            [self userNeighboursResponse:command];
            break;
        }
        case SERVER_SIGNUP:{
            [self userSignupResponse:command];
            break;
        }
        case SERVER_SIGNOUT:{
            [self userSignoutResponse:command];
            break;
        }
        case SERVER_USER_INFO:{
            [self userInfoResponse:command];
            break;
        }
        case SERVER_EDIT_USER:{
            [self userEditResponse:command];
            break;
        }
        default:
            break;
    }
}


-(void)serverErrorHanler:(ServerErrors)error withAlert:(Boolean)alert{
    
    NSLog(@"[AppManager error handler]:%d\n", error);

    switch (error) {
        case NO_ERROR:{
            break;
        }
        case ERROR_SERVER_NOT_RESPOND:{
            if( alert ) [self noServerAlert];
            break;
        }
        case ERROR_USER_CANCEL: {
            break;
        }
        case ERROR_SQL_CONNECT:{
            if( alert ) [self errorAlert:ERROR_SQL_CONNECT withMessage:ERROR_SQL_CONNECT_MESSAGE];
            break;
        }
        case ERROR_SQL_SERVER:{
            if( alert ) [self errorAlert:ERROR_SQL_SERVER withMessage:ERROR_SQL_SERVER_MESSAGE];
            break;
        }
        case ERROR_USER_UNLOGGED:{
            if( alert ) [self errorAlert:ERROR_USER_UNLOGGED withMessage:ERROR_USER_UNLOGGED_MESSAGE];
            [self serverLogStatusChanged:LOG_STATE_LOGOUT];
            if( self.gpsStatus && self.netStatus && self.autoLoginFlag ) [self userLogin];
            break;
        }
        case ERROR_INVALID_USERNAME_OR_PASSWORD:{
            if( alert ) [self errorAlert:ERROR_INVALID_USERNAME_OR_PASSWORD withMessage:ERROR_INVALID_USERNAME_OR_PASSWORD_MESSAGE];
            break;
        }
        case ERROR_INVALID_COORDINATES:{
            if( alert ) [self errorAlert:ERROR_INVALID_COORDINATES withMessage:ERROR_INVALID_COORDINATES_MESSAGE];
            break;
        }
        case ERROR_INVALID_RANGE:{
            if( alert ) [self errorAlert:ERROR_INVALID_RANGE withMessage:ERROR_INVALID_RANGE_MESSAGE];
            break;
        }
        case ERROR_INVALID_USERNAME:{
            if( alert ) [self errorAlert:ERROR_INVALID_USERNAME withMessage:ERROR_INVALID_USERNAME_MESSAGE];
            break;
        }
        case ERROR_INVALID_PASSWORD:{
            if( alert ) [self errorAlert:ERROR_INVALID_PASSWORD withMessage:ERROR_INVALID_PASSWORD_MESSAGE];
            break;
        }
        case ERROR_INVALID_EMAIL:{
            if( alert ) [self errorAlert:ERROR_INVALID_EMAIL withMessage:ERROR_INVALID_EMAIL_MESSAGE];
            break;
        }
        case ERROR_USERNAME_EXISTS:{
            if( alert ) [self errorAlert:ERROR_USERNAME_EXISTS withMessage:ERROR_USERNAME_EXISTS_MESSAGE];
            break;
        }
        case ERROR_EMAIL_EXISTS:{
            if( alert ) [self errorAlert:ERROR_EMAIL_EXISTS withMessage:ERROR_EMAIL_EXISTS_MESSAGE];
            break;
        }
        case ERROR_PASSWORD_LENGTH:{
            if( alert ) [self errorAlert:ERROR_PASSWORD_LENGTH withMessage:ERROR_PASSWORD_LENGTH_MESSAGE];
            break;
        }
        case ERROR_USERNAME_NOT_EXISTS:{
            if( alert ) [self errorAlert:ERROR_USERNAME_NOT_EXISTS withMessage:ERROR_USERNAME_NOT_EXISTS_MESSAGE];
            break;
        }
        default:{
            if( alert ) [self infoAlert:[NSString stringWithFormat:@"Error - %d", error] withMessage:@""];
            break;
        }
    }
}




@end
