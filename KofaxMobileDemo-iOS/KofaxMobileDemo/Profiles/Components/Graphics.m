//
//  Graphics.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/27/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "Graphics.h"
@implementation Graphics
-(id)init
{
    if(self = [super init])
    {
        [self setDefaultTheme];
        
    }
    
    return self;
    
}
-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary
{
    if(self = [super init])
    {
        self.logoImage = [parsedJSONDictionary valueForKey:LOGO];
        self.homeScreenBackgroundImage =  [parsedJSONDictionary valueForKey:HOMESCREENBACKGROUND];
        self.loginScreenBackgroundImage =  [parsedJSONDictionary valueForKey:LOGINSCREENBACKGROUND];
    }
    return self;
}



-(void)setDefaultTheme
{
    self.logoImage = @"";
    self.homeScreenBackgroundImage = @"";
    self.loginScreenBackgroundImage = @"";
}
@end
