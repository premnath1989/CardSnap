//
//  ComponentGraphics.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 12/4/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ComponentGraphics.h"
@interface ComponentGraphics()
{
    
}

@property (nonatomic)int componentType;

@end
@implementation ComponentGraphics
-(id)initWithType : (componentType)type
{
    if(self = [super init])
    {
        self.componentType = type;
        [self setDefaults];
        
    }
    
    return self;
}

-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary
{
    if(self = [super init])
    {
        if(parsedJSONDictionary)
            [self setUpFromJSON:parsedJSONDictionary];
        else
            [self setDefaults];
    }
    
    return self;
}


-(void)setDefaults
{
    [self setDefaultGraphics];
}

-(void)setUpFromJSON : (NSDictionary*)parsedJSONDictionary
{
    self.graphicsDictionary = [parsedJSONDictionary mutableCopy];
}

-(void)setDefaultGraphics{
    self.graphicsDictionary = [[NSMutableDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:true],SHOWINSTRUCTIONSCREEN,@"",HOMEIMAGELOGO,@"",INSTRUCTIONIMAGELOGO, nil];
}
@end
