//
//  Settings.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject


@property(nonatomic,strong)NSMutableDictionary* settingsDictionary;
-(id)initWithType : (componentType)type;
-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary;

@end
