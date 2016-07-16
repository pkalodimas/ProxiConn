//
//  CarGpsServerCommand.h
//  CarGps
//
//  Created by Panos Kalodimas on 11/1/13.
//  Copyright (c) 2013 Panos Kalodimas. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppDefinitions.h"

@protocol CarGpsServerCommandDelegate @required

@property (retain, nonatomic) id commandRequest;
-(void)serverCommandHanler:(id)command;

@end

@interface CarGpsServerCommand : NSURLConnection{
    
    ServerCommands command;
    ServerErrors error;
    NSDictionary *data;
    NSDictionary *response;
    NSMutableArray *delegates;
}

@property (assign, nonatomic) ServerCommands command;
@property (assign, nonatomic) ServerErrors error;
@property (retain, nonatomic) NSDictionary *data;
@property (retain, nonatomic) NSDictionary *response;
@property (retain, nonatomic) NSMutableArray *delegates;

-(id)init;

-(void)getData:(NSDictionary*)cdata;
-(void)getRespone:(NSDictionary*)resp;
-(void)cancel;
-(void)addDelegate:(id)del;
-(void)removeDelegate:(id)del;
-(void)callDelegates;

@end

