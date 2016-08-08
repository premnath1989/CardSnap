//
//  ComponentGraphics.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 12/4/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ComponentGraphics : NSObject

@property(nonatomic,strong)NSMutableDictionary* graphicsDictionary;
-(id)initWithType : (componentType)type;
-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary;
@end
