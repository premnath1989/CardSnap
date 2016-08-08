//
//  SettingsFilter.m
//  KofaxMobileDemo
//
//  Created by srilatha.karancheti on 3/24/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "SettingsFilter.h"


@implementation SettingsFilter

//This method filters Profile and returns a filtered dictionary
-(NSMutableDictionary *)filterProfile:(NSMutableDictionary *)jsonDictionary
{
    
    NSMutableArray* temporaryComponents = [jsonDictionary valueForKey:COMPONENTS];
    NSMutableArray *arrComponents=[[NSMutableArray alloc]init];
    for (int index=0; index<[temporaryComponents count]; index++) {
        //Get each component
        NSMutableDictionary *component=[[temporaryComponents objectAtIndex:index] mutableCopy];
        //Filter the component
        component= [self filterComponent:component];
        //Add the filtered component to the array
        [arrComponents addObject:component];
    }
    //Reset the dictonary with array of filtered components
    [jsonDictionary  setValue:arrComponents forKey:COMPONENTS];
    
    return jsonDictionary;
}

//This method filters the component
-(NSMutableDictionary *)filterComponent:(NSMutableDictionary *)component
{

    //Check if the component is credit card and remove all the settings
    NSMutableDictionary *settingsDictionary=[[component valueForKey:SETTINGS] mutableCopy];
    
    //Filter Camera Settings from default Camera settings
    NSMutableDictionary *filteredCameraSettings=[self filterCameraSettingsForComponent:[component valueForKey:TYPE ]fromDefaultSettings:[[settingsDictionary valueForKey:CAMERASETTINGS] mutableCopy]];
    [settingsDictionary setValue:filteredCameraSettings forKey:CAMERASETTINGS];
    
    //Check if the component is CheckDeposit.Remove advanced settings if the component is not CheckDeposit
    if(![[component valueForKey:TYPE] isEqualToString:COMP_CHECKDEPOSIT])
    {
        [settingsDictionary removeObjectForKey:ADVANCEDSETTINGS];
    }
    
    //Filter RTTISettings from default RRTI settings
    NSMutableDictionary *filteredRTTISettings=[self filterRTTISettingsForComponent:[component valueForKey:TYPE]  fromDefaultSettings:[[settingsDictionary valueForKey:RTTISETTINGS] mutableCopy]];
    [settingsDictionary setValue:filteredRTTISettings forKey:RTTISETTINGS];
    
    //Filter EVRSSettings from default RRTI settings
     NSMutableDictionary *filteredEVRSSettings=[self filterEVRSSettingsForComponent:[component valueForKey:TYPE]  fromDefaultSettings:[[settingsDictionary valueForKey:EVRSSETTINGS] mutableCopy]];
     [settingsDictionary setValue:filteredEVRSSettings forKey:EVRSSETTINGS];
    
    
    //Crash was happening due to settingsDictionary was nil for credit card, we should not pass "nil" as value for the key to dictionary. So checking settingsDictionary before adding to component.
    
    if (settingsDictionary != nil)
    {
        //Set the filtered settings to component and return the component
        [component  setObject:settingsDictionary forKey:SETTINGS];
    }
    
    return component;
}

//Filter camera settings from default settings for a given component
-(NSMutableDictionary *) filterCameraSettingsForComponent:(NSString *)componentType fromDefaultSettings:(NSMutableDictionary *)defaultSettings
{
    if([componentType isEqualToString:COMP_CUSTOM])
    {
        //if component type is custom return all camera settings
    }
    else if([componentType isEqualToString:COMP_IDCARD] || [componentType isEqualToString:COMP_BILLPAY] || [componentType isEqualToString:COMP_CHECKDEPOSIT] || [componentType isEqualToString:COMP_CREDITCARD])
    {
        if([componentType isEqualToString:COMP_IDCARD] || [componentType isEqualToString:COMP_BILLPAY])
        {
            [defaultSettings removeObjectForKey:FRAMEASPECTRATIO];
        }
        [defaultSettings removeObjectForKey:CAPTURETYPE];
    }
    
    return defaultSettings;
}

//Filter RTTI settings from default settings
-(NSMutableDictionary *) filterRTTISettingsForComponent:(NSString *)componentType fromDefaultSettings:(NSMutableDictionary *)defaultSettings
{
    
    if([componentType isEqualToString:COMP_CUSTOM])
    {
        
    }
    else if([componentType isEqualToString:COMP_IDCARD])
    {
        [defaultSettings removeObjectForKey:HIGHLIGHTDATA];
        [defaultSettings removeObjectForKey:SHOWALLFIELDS];
        [defaultSettings removeObjectForKey:HIGHLIGHTSWITCH];
        [defaultSettings removeObjectForKey:CUSTOMFIELDKEYVALUE];
    }
    else if([componentType isEqualToString:COMP_CHECKDEPOSIT]||[componentType isEqualToString:COMP_BILLPAY])
    {
        [defaultSettings removeObjectForKey:SHOWALLFIELDS];
        [defaultSettings removeObjectForKey:CUSTOMFIELDKEYVALUE];
    }
    return defaultSettings;
}

//Filter EVRS settings from default settings for a given component
-(NSMutableDictionary *) filterEVRSSettingsForComponent:(NSString *)componentType fromDefaultSettings:(NSMutableDictionary *)defaultSettings
{
    if ([componentType isEqualToString:COMP_CHECKDEPOSIT] ||[componentType isEqualToString:COMP_BILLPAY]||[componentType isEqualToString:COMP_IDCARD]) {
        [defaultSettings removeObjectForKey:DOPROCESS];
    }
    return defaultSettings;
}

-(NSMutableDictionary *) filterAdvancedSettingsForComponent:(NSInteger)componentType fromDefaultSettings:(NSMutableDictionary *)defaultSettings
{
    
    
    return defaultSettings;
}



@end
