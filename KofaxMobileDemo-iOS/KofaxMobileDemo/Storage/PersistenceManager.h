//
//  PersistentManager.h
//  Kofax Mobile Demo
//
//  Created by kaushik on 15/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistenceManager : NSObject

//This method will add a profile with given ID. Returns "SUCCESS" if added successfully otherwise error message.
-(NSString*)addProfileWithName:(NSString*)profileName profileID:(int)profileID AndContents:(NSString*)profileContents;

//This method will delete the profile with given Name. Returns "SUCCESS" if deleted successfully otherwise error message.
-(NSString*)deleteProfileData:(NSString*)profileName;

//This method will fetch contents of given profile ID. Returns JSON if profile is found otherwise Nil is returned.
-(NSString*)getProfile:(int)profileID;

//This method will replace a row in the table. Returns "SUCCESS" if updated successfully otherwise error message.
-(NSString*)updateProfile:(int)profileID withContents:(NSString*)profileContents;

//This method returns list of available profiles as a dictionary with KEYS as id and name and their equivalents as VALUES.
-(NSArray*)getListofProfiles;


//temporary method
-(NSString*)getProfileWithName : (NSString*)profileName;
-(NSString*)replaceProfile:(NSString*)profileName withID:(int)profileID withContents: (NSString*)profileContents;

-(void)storeProfileCounter:(int)profileCounter;
-(int)getProfileCounter;


+(BOOL)isAppStatsSaved;
+(void)storeAppStats:(NSDictionary*)appStatsInfo;
+(NSMutableDictionary*)getAppStatsInfo;

+(void)storeUserLoginInfo:(BOOL)login;
+(BOOL)isUserLoggedIn;
+(void)storeLoginInfo:(NSDictionary*)loginInfo;
+(NSMutableDictionary*)getUserLoginInfo;

+(void)storeRememberUserInfo:(BOOL)rememberUser;
+(BOOL)getRememberUserInfo;

+(void)storeActiveProfileName:(NSString*)profileName;
+(NSString*)getActiveProfileName;
+(BOOL)isActiveProfileNameSaved;

+(void)storeBackSignature:(BOOL)backSignature;
+(BOOL)getBackSignature;

+(void)storeCheckInformation:(NSArray*)results;
+(NSMutableArray*)getCheckInformation;

+(void )setLicenseString:(NSString *)license;
+(NSString *)getLicenseString;
+(void)resetKeychainItem;

@end
