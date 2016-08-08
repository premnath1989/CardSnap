//
//  Component.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//
//This is a base class which contains the common elements and methods that a component should have. Components fall into any of the four categories

#import "Component.h"

@implementation Component

-(id)initWithType: (componentType)componentType
{
    if(self = [super init])
    {
        if(componentType < CHECKDEPOSIT || componentType > CUSTOM)
            return nil;
        self.type = componentType;
        [self setDefaults];
        
    }
    
    return self;
}

-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary
{
    if(self = [super init])
    {
        if(parsedJSONDictionary)
            [self setUpComponentWithJSON:parsedJSONDictionary];
        else
            [self setDefaults];
    }
    
    return self;
}
    
-(void)setDefaults
{
    self.submit = @"NONE";
    
    if(self.type == CHECKDEPOSIT)
    {
        self.typeString = @"Check Deposit";
    }
    else if(self.type == IDCARD)
    {
        self.typeString = @"ID Card";
    }
    else if(self.type == BILLPAY)
    {
        self.typeString = @"Pay Bills";
    }
    else if(self.type == CUSTOM)
    {
        self.typeString = @"Custom Component";
    }
    else if(self.type == CREDITCARD)
    {
        self.typeString = @"Credit Card";
    }
    
    self.componentGraphics = [[ComponentGraphics alloc]initWithType:self.type];
    self.texts = [[Localization alloc] initWithType:self.type];
    self.settings = [[Settings alloc] initWithType:self.type];
}


-(void)setUpComponentWithJSON : (NSDictionary*)parsedJSONDictionary
{
    self.typeString =  [parsedJSONDictionary valueForKey:TYPE];
    if([self.typeString isEqualToString:@"Check Deposit"])
        self.type = CHECKDEPOSIT;
    else if([self.typeString isEqualToString:@"ID Card"]||[self.typeString isEqualToString:@"Driver License"])
        self.type = IDCARD;
    else if([self.typeString isEqualToString:@"Pay Bills"])
        self.type = BILLPAY;
    else if([self.typeString isEqualToString:@"Custom Component"])
        self.type = CUSTOM;
    else if([self.typeString isEqualToString:@"Credit Card"])
        self.type = CREDITCARD;
    if ([[parsedJSONDictionary allKeys] containsObject:@"subtype"]) { //Only passport component contains subtype key.
        self.subType = @"Passport";
    }
    else {
        self.subType = @"";  //Setting empty subtype for other components.
    }
    self.name = [parsedJSONDictionary valueForKey:COMPONENTNAME];
    self.submit = [parsedJSONDictionary valueForKey:SUBMITTO];
    self.componentGraphics = [[ComponentGraphics alloc]initWithParsedJSON:[parsedJSONDictionary valueForKey:COMPONENTGRAPHICS]];
    self.texts = [[Localization alloc] initWithParsedJSON:[parsedJSONDictionary valueForKey:SCREENTEXTS]];
    self.settings = [[Settings alloc] initWithParsedJSON:[parsedJSONDictionary valueForKey:SETTINGS]];
}

@end
