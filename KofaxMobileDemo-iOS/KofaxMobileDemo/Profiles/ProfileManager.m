//
//  ProfileManager.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 13/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ProfileManager.h"
#import "PersistenceManager.h"

@interface ProfileManager() 
{
    
}

@property(nonatomic,strong)JSONEngine* jsonEngine;
@property(nonatomic,strong)NSDictionary* parsedProfileData;
@property(nonatomic,strong)Profile* currentActiveProfile;
@property(nonatomic,strong)Profile* profileUnderConstruction;
@property(nonatomic,strong)PersistenceManager* storageManager;
@property(nonatomic)int profileCounter;


@end

static ProfileManager* profileManager = nil;

@implementation ProfileManager


//Singleton Method for the instance
+(id)sharedInstance
{
    if(profileManager == nil)
    {
        static dispatch_once_t gcdToken;
        dispatch_once(&gcdToken, ^{
            profileManager = [[ProfileManager alloc] init];
            [profileManager setDefaults];
            
        });
    }
    
    
    return profileManager;
}


-(void)setDefaults
{
    self.jsonEngine = [[JSONEngine alloc] init];
}

//This method imports the profiles from a file url path. URL should be a file URL
-(void)importProfile: (NSURL*)url
{
    if(![url isFileURL])
        return; //throw error may be
    
    NSData* importedProfileData = [NSData dataWithContentsOfURL:url];
    
    if(!importedProfileData)
        NSLog(@"error importing file"); //throw error
    
    if(!self.storageManager)
        self.storageManager = [[PersistenceManager alloc] init];
    
    self.parsedProfileData = [self.jsonEngine parseJSONData:importedProfileData];
    
    self.profileCounter = [self.storageManager getProfileCounter];
    Profile* importedProfile = [[Profile alloc] initWithParsedJSONData:self.parsedProfileData];
    self.profileCounter++;
    importedProfile.profileID = self.profileCounter;
    [self.storageManager storeProfileCounter:self.profileCounter];
    NSString* jsonString = [[NSString alloc] initWithData:importedProfileData encoding:NSUTF8StringEncoding];
    [self.storageManager addProfileWithName:importedProfile.name profileID:importedProfile.profileID AndContents:jsonString];
    [self setActiveProfile:importedProfile];
    
}


//This is a factory method which gives pre manufactured objects of component types

-(NSArray*)getComponentTypes
{
    NSArray* componentTypes = [[NSArray alloc] initWithObjects:@"Check Deposit",@"Pay Bills",@"ID Card",@"Credit Card",@"Custom Component", nil];
    return componentTypes;
}

-(void)loadActiveProfile
{
    
    if([PersistenceManager isActiveProfileNameSaved])
    {
        if([[self.storageManager getProfileWithName:[PersistenceManager getActiveProfileName]] length])
        {
            NSData* jsonData = [[self.storageManager getProfileWithName:[PersistenceManager getActiveProfileName]] dataUsingEncoding:NSUTF8StringEncoding];
            
            Profile* profile = [[Profile alloc] initWithParsedJSONData:[self.jsonEngine parseJSONData:jsonData]];
            [self setActiveProfile:profile];

        }
        else
        {
            [self setActiveProfileWithID:DEFAULTPROFILEID];
        }
            
    }
}

-(void)setActiveProfile : (Profile*)profile
{
    self.currentActiveProfile = profile;
    
    [PersistenceManager storeActiveProfileName:profile.name];
}

-(void)setActiveProfileWithID : (int)profileID
{
    NSData* jsonData = [[self.storageManager getProfile:profileID] dataUsingEncoding:NSUTF8StringEncoding];
    NSString* newStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    Profile* activeProfile = [[Profile alloc] initWithParsedJSONData:[self.jsonEngine parseJSONData:jsonData]];
    [self setActiveProfile:activeProfile];
}


-(Profile*)getActiveProfile
{
    return self.currentActiveProfile;
}

-(Profile*)getProfileWithID : (int)profileID
{
    NSData* jsonData = [[self.storageManager getProfile:profileID] dataUsingEncoding:NSUTF8StringEncoding];
    Profile* profile = [[Profile alloc] initWithParsedJSONData:[self.jsonEngine parseJSONData:jsonData]];
    return profile;
}

//This method creates the JSON for the newly created profile and stores it in the DB It also sets it as active profile
//TODO replace with error code
-(int)createNewProfile : (Profile*)profile
{
    if(!profile)
        return 0;
    int previousID = profile.profileID;
    self.profileCounter = [self.storageManager getProfileCounter];
    self.profileCounter ++;
    [self.storageManager storeProfileCounter:self.profileCounter];
    profile.profileID = self.profileCounter;
    
    NSData* newProfileData = [self.jsonEngine createJSONForProfile:profile];
    NSString* jsonString = [[NSString alloc] initWithData:newProfileData encoding:NSUTF8StringEncoding];
    NSString* error = [self.storageManager addProfileWithName:profile.name profileID:profile.profileID AndContents:jsonString];
    
    
    if([error isEqualToString:@"column profName is not unique"])
    {
        self.profileCounter --;
        [self.storageManager storeProfileCounter:self.profileCounter];
        profile.profileID = previousID;
        return 0;
    }
    else
    {
        [self setActiveProfile:profile];
    }
    
    
    return 1;
    
}

-(NSArray*)getListOfProfiles
{
    if(!self.storageManager)
        self.storageManager = [[PersistenceManager alloc] init];
    
    return [self.storageManager getListofProfiles];
}

//This method give the data to be exported as email attachment
-(NSData*)getExportDataForProfile :(Profile*)profile
{
    NSData* exportData;
    if(self.jsonEngine && profile)
        exportData =  [self.jsonEngine createJSONForProfile:profile];
    else
        NSLog(@"empty profile or no JSON engine available");
    
    return exportData;
}

-(int)updateProfile : (Profile*)profile
{
    if(!profile)
        return 0;
    
    NSData* newProfileData = [self.jsonEngine createJSONForProfile:profile];
    NSString* jsonString = [[NSString alloc] initWithData:newProfileData encoding:NSUTF8StringEncoding];
    NSString* error = [self.storageManager replaceProfile:profile.name withID:profile.profileID withContents:jsonString];
    NSLog(@"update error is %@",error);
    [self setActiveProfile:profile];
    
    return 1;

}

//Deletes a profile currently deletes active profile
-(BOOL)deleteProfile : (Profile*)profile
{
    if(!profile || profile.profileID == DEFAULTPROFILEID)
        return NO;
    
    [self.storageManager deleteProfileData:profile.name];
    [self setActiveProfileWithID:DEFAULTPROFILEID];
    
    //TODO replace with error returned from actual delete call
    return YES;
}





@end
