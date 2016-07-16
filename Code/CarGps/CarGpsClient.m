//
//  CarGpsClient.m
//  CarGPS
//
//  Created by Panos Kalodimas on 10/13/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsClient.h"

@implementation CarGpsClient

@synthesize netStatus;
@synthesize server;
@synthesize serverUrl;
@synthesize session;
@synthesize delegate;
@synthesize serverCommands;

-(id)init{
  
    self = [super init];
    
    
    self.netStatus = FALSE;
    self.server = @"";
    self.session = @"";
    self.serverUrl = [[NSURL alloc] init];
    self.delegate = nil;
    self.serverCommands = [NSMutableArray arrayWithCapacity:SERVER_COMMANDS_NUMBER+1];
    for( int i=0; i<=SERVER_COMMANDS_NUMBER; i++ ) self.serverCommands[i] = [NSNull null];
    
    return self;
}

-(id)initFromDictionary:(NSMutableDictionary *)settings{
        
    //self.server = [settings valueForKey:SETTINGS_SERVER];
    //self.serverUrl = [NSURL URLWithString:[[@"http://" stringByAppendingString:self.server] stringByAppendingString:[settings valueForKey:SETTINGS_SERVER_URL]]];
    self.server = [self getSetting:settings name:SETTINGS_SERVER];
    self.serverUrl = [NSURL URLWithString:[[@"http://" stringByAppendingString:self.server] stringByAppendingString:[self getSetting:settings name:SETTINGS_SERVER_URL]]];
    
    return self;
}

-(id)initWithDelegate:(id)delegateID andSettings:(NSMutableDictionary *)settings{
    
    self = [self initFromDictionary:settings];
    self.delegate = delegateID;
    
    return self;
}

//---------------------------------------------------------------------------
//----------------------------- Network Methods -----------------------------
//---------------------------------------------------------------------------

-(void)startNetworkConnection{
    
    NSLog(@"[CarGpsClient startNetworkConnection]\n");
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    self.reachabilityRef = SCNetworkReachabilityCreateWithName(nil, [self.server UTF8String]);
    self.localWiFiRef = NO;
    [self startNotifier];
    [self networkStatusChanged:nil];
}

-(void)stopNetworkConnection{
    
    NSLog(@"[CarGpsClient stopNetworkConnection]\n");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [self stopNotifier];
    self.reachabilityRef = nil;
    self.netStatus = NO;
    [self.delegate clientNetworkStatusChanged:NO];
    [self clearCommands];
}

-(void)restartNetworkConnection{
    
    [self clearCommands];
    self.reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [self.server UTF8String]);
    [self networkStatusChanged:nil];
}

//Called by Reachability whenever status changes.
- (void)networkStatusChanged:(NSNotification *)note {
    
    NSLog(@"[CarGpsClient network changed]\n");

    switch ([self currentReachabilityStatus])
    {
        case NotReachable:
        {
            self.netStatus = NO;
            break;
        }
        case ReachableViaWWAN:
        {
            self.netStatus = YES;
            break;
        }
        case ReachableViaWiFi:
        {
            self.netStatus = YES;
            break;
        }
    }

    [self.delegate clientNetworkStatusChanged:self.netStatus];
}

-(CarGpsServerCommand*)sendCommand:(NSDictionary*)data{
    
    if( !data ) return nil;
    
    //Check command validation
    int cCode = [[data valueForKey:COMMAND] integerValue];
    if( ![self commandIsValid:cCode] ) return nil;
    if( [self getCommand:cCode] ) return [self.serverCommands objectAtIndex:cCode];
    
    //Create Request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.serverUrl];
    [request setHTTPMethod:HTTP_POST];
    if( [NSJSONSerialization isValidJSONObject:data] ) [request setHTTPBody:[NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil]];
    else return nil;
    //NSLog([[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    
    //Send command
    CarGpsServerCommand *command = [[[CarGpsServerCommand alloc] init] initWithRequest:request delegate:self startImmediately:YES];
    [command getData:data];
    if( command ) [self.serverCommands replaceObjectAtIndex:cCode withObject:command];
    
    NSLog(@"[CarGpsClient send command]:%d \n", command.command);

    return command;
}

-(CarGpsServerCommand*)getCommand:(ServerCommands)cCode{
    
    if( ![self commandIsValid:cCode] ) return nil;
    if( [[self.serverCommands objectAtIndex:cCode] isEqual:[NSNull null]] ) return nil;
    return self.serverCommands[cCode];
}

//---------------------------------------------------------------------------
//----------------------------- Server Methods ------------------------------
//---------------------------------------------------------------------------

-(void)startSession:(NSString *)sid{
    
    NSLog(@"[CarGpsClient start session]\n");

    if( sid )  self.session = sid;
    else self.session = @"";
}

-(void)destroySession{
    
    NSLog(@"[CarGpsClient stop session]\n");

    self.session = @"";
}

-(CarGpsServerCommand*)sendPing{
    
    if( !self.netStatus || [self getCommand:SERVER_NO_COMMAND] ) return [self getCommand:SERVER_NO_COMMAND];

    return [self sendCommand:[NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:SERVER_NO_COMMAND] forKey:COMMAND]];
}

-(CarGpsServerCommand*)userLogin:(CarGpsUser*)user{
    
    if( !self.netStatus || !user || [self getCommand:SERVER_LOGIN] ) return [self getCommand:SERVER_LOGIN];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_LOGIN], COMMAND,
                                                                    user.username, USERNAME,
                                                                    user.password, PASSWORD,
                                                                    [NSNumber numberWithDouble:user.coordinate.latitude], COORDINATE_Y,
                                                                    [NSNumber numberWithDouble:user.coordinate.longitude], COORDINATE_X,
                          nil];
    
    return [self sendCommand:data];
}

-(CarGpsServerCommand*)userLogout{
    
    if( !self.netStatus || [self getCommand:SERVER_LOGOUT] ) return [self getCommand:SERVER_LOGOUT];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_LOGOUT], COMMAND,
                                                                    self.session, SESSION,
                          nil];
        
    return [self sendCommand:data];
}

-(CarGpsServerCommand*)updateLocation:(CLLocationCoordinate2D)coordinates{
    
    if( !self.netStatus || !CLLocationCoordinate2DIsValid(coordinates) || [self getCommand:SERVER_UPDATE_LOCATION] ) return [self getCommand:SERVER_UPDATE_LOCATION];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_UPDATE_LOCATION], COMMAND,
                                                                    self.session, SESSION,
                                                                    [NSNumber numberWithDouble:coordinates.latitude], COORDINATE_Y,
                                                                    [NSNumber numberWithDouble:coordinates.longitude], COORDINATE_X,
                          nil];
            
    return [self sendCommand:data];
}

-(CarGpsServerCommand*)userNeighbours:(CLLocationCoordinate2D)coordinates withRange:(NSNumber*)range{
    
    if( !self.netStatus || [self getCommand:SERVER_NEIGHBOURS] ) return [self getCommand:SERVER_NEIGHBOURS];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_NEIGHBOURS], COMMAND,
                                 self.session, SESSION,
                                 range, RANGE,
                                 nil];
    if( coordinates.latitude !=0 || coordinates.longitude != 0 ){
        
        [data setValue:[NSNumber numberWithDouble:coordinates.latitude] forKey:COORDINATE_Y];
        [data setValue:[NSNumber numberWithDouble:coordinates.longitude] forKey:COORDINATE_X];
    }

    return [self sendCommand:data];
}

-(CarGpsServerCommand*)userInfo:(NSString*)username{
    
    if( !self.netStatus || [self getCommand:SERVER_USER_INFO] || !username ) return [self getCommand:SERVER_USER_INFO];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_USER_INFO], COMMAND,
                                                                    self.session, SESSION,
                                                                    username, USERNAME,
                          nil];
        
    return [self sendCommand:data];
}

-(CarGpsServerCommand*)signup:(CarGpsUser *)user{
    
    if( !self.netStatus || !user || [self getCommand:SERVER_SIGNUP] ) return [self getCommand:SERVER_SIGNUP];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_SIGNUP], COMMAND,
                                                                    user.username, USERNAME,
                                                                    user.password, PASSWORD,
                                                                    [user.info valueForKey:EMAIL], EMAIL,
                                                                    [user.info valueForKey:NAME], NAME,
                                                                    [user.info valueForKey:FACEBOOK], FACEBOOK,
                          nil];
        
    return [self sendCommand:data];
}

-(CarGpsServerCommand*)userEdit:(CarGpsUser*)user{
    
    if( !self.netStatus || !user || [self getCommand:SERVER_EDIT_USER] ) return [self getCommand:SERVER_EDIT_USER];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_EDIT_USER], COMMAND,
                                                                    self.session, SESSION,
                                                                    user.password, PASSWORD,
                                                                    [user.info valueForKey:EMAIL], EMAIL,
                                                                    [user.info valueForKey:NAME], NAME,
                                                                    [user.info valueForKey:FACEBOOK], FACEBOOK,
                          nil];
        
    return [self sendCommand:data];
}

-(CarGpsServerCommand*)signout{
    
    if( !self.netStatus || [self getCommand:SERVER_SIGNOUT] ) return [self getCommand:SERVER_SIGNOUT];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:SERVER_SIGNOUT], COMMAND,
                                                                    self.session, SESSION, nil];
            
    return [self sendCommand:data];
}


//---------------------------------------------------------------------------
//----------------------------- Connection delegates ------------------------
//---------------------------------------------------------------------------

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
   
    NSLog(@"[CarGpsClient connection succeed]\n");

    CarGpsServerCommand *command = (CarGpsServerCommand*) connection;
    
    if( ![self removeCommand:command] )  return;
    
    [command getRespone:nil];
    [self.delegate serverCommandHanler:command];
    [self networkStatusChanged:nil];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    NSLog(@"[CarGpsClient connection succedded]\n");
    //NSLog([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    CarGpsServerCommand *command = (CarGpsServerCommand*) connection;
    
    if( ![self removeCommand:command] )  return;
    
    if( data ) [command getRespone:[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]];
    else [command getRespone:NULL];
    
    [self.delegate serverCommandHanler:command];
}

-(Boolean)removeCommand:(CarGpsServerCommand*)command{
    
    NSLog(@"[CarGpsClient remove command]:%d\n", command.command);

    if( !command || ![self getCommand:command.command] ) return NO;
    
    [self.serverCommands replaceObjectAtIndex:command.command withObject:[NSNull null]];
    return YES;
}

-(void)clearCommands{
    
    for( int i=1; i<=self.serverCommands.count; i++ ){
        
        CarGpsServerCommand *command = [self getCommand:i];
        if( !command ) continue;
        
        [self.serverCommands replaceObjectAtIndex:i withObject:[NSNull null]];
        [command cancel];
        [self.delegate serverCommandHanler:command];
    }
}

-(void)cancelCommand:(CarGpsServerCommand*)command{
    
    NSLog(@"[CarGpsClient cancel command]:%d\n", command.command);

    if( !command || ![self getCommand:command.command] ) return;
    if( ![command isEqual:[self getCommand:command.command]] ) return;
        
    [self removeCommand:command];
    [command cancel];
    [self.delegate serverCommandHanler:command];
}

-(Boolean)commandIsValid:(ServerCommands)cCode{
    
    if( cCode <= SERVER_COMMANDS_NUMBER ) return YES;
    return NO;
}











@end
