//
//  CarGpsServerCommand.m
//  CarGps
//
//  Created by Panos Kalodimas on 11/1/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import "CarGpsServerCommand.h"

@implementation CarGpsServerCommand

@synthesize error;
@synthesize command;
@synthesize data;
@synthesize response;
@synthesize delegates;

-(id)init{
    
    self = [super init];
    
    self.command = SERVER_NO_COMMAND;
    self.error = NO_ERROR;
    self.data = nil;
    self.response = nil;
    self.delegates =[NSMutableArray array];
    
    return self;
}

-(void)getData:(NSDictionary*)cdata{
    
    self.data = cdata;
    self.command = [[cdata valueForKey:COMMAND] intValue];
    if( !self.command ) self.command = SERVER_NO_COMMAND;
}

-(void)getRespone:(NSDictionary *)resp{
    
    if( !resp ){
        
        self.response = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:ERROR_SERVER_NOT_RESPOND], ERROR,
                    ERROR_SERVER_NOT_RESPOND_MESSAGE, MESSAGE, nil];
    }
    else {
        self.response = resp;
    }
    self.error = [[self.response valueForKey:ERROR] integerValue];
}

-(void)cancel{
    
    [super cancel];
    
    self.error = ERROR_USER_CANCEL;
    self.response = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:ERROR_USER_CANCEL], ERROR,
                     ERROR_USER_CANCEL_MESSAGE, MESSAGE, nil];
}

-(void)addDelegate:(id)del{
    
    if( del ) [self.delegates addObject:del];
}

-(void)removeDelegate:(id)del{
    
    if( del ) [self.delegates removeObject:del];
}

-(void)callDelegates{
    
    for( int i=0; i<self.delegates.count; i++ ) [[self.delegates objectAtIndex:i] serverCommandHanler:self];
}


@end
