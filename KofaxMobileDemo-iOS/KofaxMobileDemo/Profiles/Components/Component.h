//
//  Component.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Localization.h"
#import "ExtractionFields.h"
#import "Settings.h"
#import "ComponentGraphics.h"

@interface Component : NSObject

@property(nonatomic)componentType type;
@property(nonatomic,strong) NSString* typeString;
@property(nonatomic,strong) NSString* subType;
@property(nonatomic,strong)NSString* name;
@property(nonatomic,strong)NSString* submit;
@property(nonatomic,strong)Localization* texts;
@property(nonatomic,strong)ExtractionFields* extractionFields;
@property(nonatomic,strong)Settings* settings;
@property (nonatomic,strong) ComponentGraphics *componentGraphics;

-(id)initWithType: (componentType)componentType;
-(id)initWithParsedJSON : (NSDictionary*)parsedJSONDictionary;

@end
