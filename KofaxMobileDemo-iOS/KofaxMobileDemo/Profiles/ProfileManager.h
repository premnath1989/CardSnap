//
//  ProfileManager.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 13/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//
//This class is responsible to manage/import/Create/Export of Profiles. It would invoke JSON engine and try to parse/form JSON.

#import <Foundation/Foundation.h>
#import "JSONEngine.h"


@interface ProfileManager : NSObject




//Singleton Method
+(id)sharedInstance;


-(void)importProfile: (NSURL*)url;
-(int)createNewProfile : (Profile*)profile;
-(NSData*)getExportDataForProfile :(Profile*)profile;
-(Profile*)getActiveProfile;
-(void)setActiveProfile : (Profile*)profile;
-(NSArray*)getComponentTypes;

-(NSArray*)getListOfProfiles;
-(Profile*)getProfileWithID : (int)profileID;

-(void)loadActiveProfile;

-(int)updateProfile : (Profile*)profile;

-(void)setActiveProfileWithID : (int)profileID;

-(BOOL)deleteProfile : (Profile*)profile;


@end
