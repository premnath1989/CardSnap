//
//  Localization.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Localization : NSObject

@property(nonatomic,strong)NSDictionary* previewText;
@property(nonatomic,strong)NSDictionary* summaryText;
@property(nonatomic,strong)NSDictionary* cameraText;

-(id)initWithType :(componentType)type;
-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary;

@end
