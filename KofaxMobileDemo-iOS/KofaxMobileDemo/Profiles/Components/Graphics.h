//
//  Graphics.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/27/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Graphics : NSObject
@property (nonatomic, strong) NSString *logoImage;
@property (nonatomic, strong) NSString *homeScreenBackgroundImage;
@property (nonatomic, strong) NSString *loginScreenBackgroundImage;

-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary;
@end
