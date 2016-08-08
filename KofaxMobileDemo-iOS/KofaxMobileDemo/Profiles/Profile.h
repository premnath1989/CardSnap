//
//  Profile.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 14/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Component.h"
#import "Theme.h"
#import "Graphics.h"
@interface Profile : NSObject

@property(nonatomic)int profileID;
@property(nonatomic,strong)NSString* name;
@property(nonatomic,strong)NSString* appTitle;
@property(nonatomic)int numberOfComponents;
@property(nonatomic,strong)NSString* footer;
@property(nonatomic)BOOL isLoginRequired;
@property(nonatomic,strong)NSString* userName;
@property(nonatomic,strong)NSString* passWord;
@property(nonatomic,strong)NSString* loginURL;
@property(nonatomic,strong)NSMutableArray* componentArray;
@property(nonatomic, strong)Theme *theme;
@property(nonatomic, strong)Graphics *graphics;

-(id)initWithParsedJSONData: (NSDictionary*)parsedJSONDictionary;
-(void)addComponent:(Component*)component;
-(void)removeComponent: (Component*)component;

@end
    
