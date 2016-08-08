//
//  Profile.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

//This class represents the parsed data of the JSON file and has components as objects

#import "Profile.h"
#import "SettingsFilter.h"

@implementation Profile


-(id)init
{
    if(self = [super init])
    {
        [self setDefaults];
        
    }
    
    return self;
}


-(id)initWithParsedJSONData: (NSDictionary*)parsedJSONDictionary
{
    if(self = [super init])
    {
        [self setDefaults];
        if(parsedJSONDictionary)
            [self setUpProfileWithJSON:parsedJSONDictionary];
    }
    
    return self;
    
}

-(void)setDefaults
{
    self.name = @"";
    self.appTitle = @"BankRight";
    self.numberOfComponents = 0;
    self.footer = @"© 2016 Kofax Mobile Demo";
    self.isLoginRequired = NO;
    self.userName = @"test";
    self.passWord = @"test";
    self.loginURL = @"https://mobiledemo.kofax.com";
    self.componentArray = [[NSMutableArray alloc] init];
    self.theme = [[Theme alloc] init];
    self.graphics = [[Graphics alloc]init];
}

-(void)setUpProfileWithJSON:(NSDictionary*)parsedJSONDictionary
{
    
    SettingsFilter *settingsFilter=[[SettingsFilter alloc]init];
    parsedJSONDictionary=[settingsFilter filterProfile:[parsedJSONDictionary mutableCopy]];
    
    self.name = [[parsedJSONDictionary valueForKey:METADATA] valueForKey:NAME];
    self.profileID = [[[parsedJSONDictionary valueForKey:METADATA] valueForKey:ID] intValue];
    self.appTitle = [[parsedJSONDictionary valueForKey:METADATA] valueForKey:APPTITLE];
    self.numberOfComponents = [[[parsedJSONDictionary valueForKey:METADATA] valueForKey:NUMBEROFCOMPONENTS] intValue];
    self.footer = [[parsedJSONDictionary valueForKey:METADATA] valueForKey:FOOTER];
    //TODO Test this
    self.isLoginRequired = [[[parsedJSONDictionary valueForKey:METADATA] valueForKey:LOGINREQUIRED] boolValue];
    self.userName = [[[parsedJSONDictionary valueForKey:METADATA] valueForKey:CREDENTIALS] valueForKey:USERNAME];
    self.passWord = [[[parsedJSONDictionary valueForKey:METADATA] valueForKey:CREDENTIALS] valueForKey:PASSWORD];
    self.loginURL = [[[parsedJSONDictionary valueForKey:METADATA] valueForKey:CREDENTIALS] valueForKey:LOGINURL];
    self.theme = [[Theme alloc]initWithParsedJSON:[[parsedJSONDictionary valueForKey:METADATA] valueForKey:THEME]];
    self.graphics = [[Graphics alloc]initWithParsedJSON:[[parsedJSONDictionary valueForKey:METADATA] valueForKey:GRAPHICS]];
    NSMutableArray* temporaryComponents = [parsedJSONDictionary valueForKey:COMPONENTS];
    
    for(int i=0;i< [temporaryComponents count];i++)
    {
        Component* component = [[Component alloc] initWithParsedJSON:[temporaryComponents objectAtIndex:i]];
        [self.componentArray addObject:component];
        
    }
    
    settingsFilter = nil;
}



-(void)addComponent:(Component*)component
{
    if(component)
    {
        if(self.componentArray)
        {
            [self.componentArray addObject:component];
            self.numberOfComponents = (int)[self.componentArray count];
        }

    }
}

-(void)removeComponent: (Component*)component
{
    if(self.componentArray)
    {
        [self.componentArray removeObject:component];
    }
}

@end
