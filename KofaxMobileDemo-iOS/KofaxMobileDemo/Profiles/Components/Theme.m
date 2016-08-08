//
//  Theme.m
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/20/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "Theme.h"

@implementation Theme

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
        self.themeColor = [parsedJSONDictionary valueForKey:COLOR];
        self.titleColor = [parsedJSONDictionary valueForKey:TITLECOLOR];
        self.buttonColor = [parsedJSONDictionary valueForKey:BUTTONCOLOR];
        self.buttonBorder = [parsedJSONDictionary valueForKey:BUTTONCORNERSTYLE];
        self.buttonStyle = [parsedJSONDictionary valueForKey:BUTTONCOLORSTYLE];
        
        self.buttonTextColor = [parsedJSONDictionary valueForKey:BUTTONTEXTCOLOR];
    }
    
    return self;
}



-(void)setDefaultTheme
{
    self.themeColor = @"#0079C2";
    self.titleColor = @"#FFFFFF";
    self.buttonColor = @"#0079C2";
    self.buttonTextColor = @"#FFFFFF";
    self.buttonBorder =  [NSNumber numberWithInt:0];
    self.buttonStyle = [NSNumber numberWithInt:0];
}

@end
