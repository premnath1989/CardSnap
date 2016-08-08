//
//  JSONEngine.m
//  Kofax Mobile Demo
//
//  Created by Mahendra on 13/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "JSONEngine.h"
@implementation JSONEngine

-(NSDictionary*)parseJSONData : (NSData*)profileData
{
    NSError* error;
    if(profileData)
        return [NSJSONSerialization JSONObjectWithData:profileData options:NSJSONReadingAllowFragments error:&error];
    return nil;
}


-(NSData*)createJSONForProfile : (Profile*)profile
{
    NSMutableDictionary *themes = [[NSMutableDictionary alloc]init];
    [themes setValue:profile.theme.themeColor forKey:COLOR];
    [themes setValue:profile.theme.titleColor forKey:TITLECOLOR];
    [themes setValue:profile.theme.buttonColor forKey:BUTTONCOLOR];
    [themes setValue:profile.theme.buttonTextColor forKey:BUTTONTEXTCOLOR];
    [themes setValue:profile.theme.buttonBorder forKey:BUTTONCOLORSTYLE];
    [themes setValue:profile.theme.buttonStyle forKey:BUTTONCORNERSTYLE];
    // NSDictionary* themes = @{COLOR:profile.theme.themeColor,TITLECOLOR:profile.theme.titleColor,BUTTONCOLOR:profile.theme.buttonColor,BUTTONTEXTCOLOR:profile.theme.buttonTextColor,BUTTONCOLORSTYLE:profile.theme.buttonBorder,BUTTONCORNERSTYLE:profile.theme.buttonStyle};
    NSMutableDictionary *graphics = [[NSMutableDictionary alloc]init];
    [graphics setValue:profile.graphics.logoImage forKey:LOGO];
    [graphics setValue:profile.graphics.homeScreenBackgroundImage forKey:HOMESCREENBACKGROUND];
    [graphics setValue:profile.graphics.loginScreenBackgroundImage forKey:LOGINSCREENBACKGROUND];
    // NSDictionary *graphics =@{LOGO:profile.graphics.logoImage,HOMESCREENBACKGROUND:profile.graphics.homeScreenBackgroundImage,LOGINSCREENBACKGROUND:profile.graphics.loginScreenBackgroundImage};
    NSMutableDictionary *credentials = [[NSMutableDictionary alloc]init];
    [credentials setValue:profile.userName forKey:USERNAME];
    [credentials setValue:profile.passWord forKey:PASSWORD];
    [credentials setValue:profile.loginURL forKey:LOGINURL];
    //NSDictionary* credentials = @{USERNAME : profile.userName,PASSWORD : profile.passWord,LOGINURL:profile.loginURL};
    NSMutableDictionary *metadata = [[NSMutableDictionary alloc]init];
    [metadata setValue:profile.name forKey:NAME];
    [metadata setValue:[NSNumber numberWithInt:profile.profileID] forKey:ID];
    [metadata setValue:profile.appTitle forKey:APPTITLE];
    [metadata setValue:[NSNumber numberWithInt:profile.numberOfComponents] forKey:NUMBEROFCOMPONENTS];
    [metadata setValue:profile.footer forKey:FOOTER];
    [metadata setValue:[NSNumber numberWithBool:profile.isLoginRequired] forKey:LOGINREQUIRED];
    [metadata setValue:credentials forKey:CREDENTIALS];
    [metadata setValue:themes forKey:THEME];
    [metadata setValue:graphics forKey:GRAPHICS];
    
    // NSDictionary* metadata = @{NAME : profile.name,ID : [NSNumber numberWithInt:profile.profileID],APPTITLE :  profile.appTitle,NUMBEROFCOMPONENTS: [NSNumber numberWithInt:profile.numberOfComponents],FOOTER: profile.footer,LOGINREQUIRED: [NSNumber numberWithBool:profile.isLoginRequired],CREDENTIALS: credentials,THEME:themes,GRAPHICS:graphics};
    
    NSMutableArray* jsonComponents = [[NSMutableArray alloc] init];
    
    for(int i=0;i< profile.componentArray.count;i++)
    {
        Component* componentObject = [profile.componentArray objectAtIndex:i];
        
        NSMutableDictionary *textsDict = [[NSMutableDictionary alloc]init];
        [textsDict setValue:componentObject.texts.previewText forKey:PREVIEW];
        [textsDict setValue:componentObject.texts.summaryText forKey:SUMMARY];
        [textsDict setValue:componentObject.texts.cameraText forKey:CAMERA];
        
        //NSDictionary* textsDict = @{PREVIEW:componentObject.texts.previewText,SUMMARY:componentObject.texts.summaryText,CAMERA:componentObject.texts.cameraText};
        
        NSMutableDictionary *component = [[NSMutableDictionary alloc]init];
        [component setValue:componentObject.typeString forKey:TYPE];
        [component setValue:componentObject.submit forKey:SUBMITTO];
        [component setValue:textsDict forKey:SCREENTEXTS];
        [component setValue:componentObject.settings.settingsDictionary forKey:SETTINGS];
        [component setValue:componentObject.componentGraphics.graphicsDictionary forKey:COMPONENTGRAPHICS];
        
       //Get the path of the localized strings
        NSString *stringsPath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:stringsPath];
        //Get the keys of the "component name" from the localised strings list
        NSArray* arrayOfKeys = [dictionary allKeysForObject:componentObject.name];
    
        NSString *keyForValue;
        if(arrayOfKeys && [arrayOfKeys count]){
            //Get the key for component name
            keyForValue=[arrayOfKeys firstObject];
            //Update the component object name with the key
            componentObject.name=keyForValue;
            
        }
        [component setValue:componentObject.name forKey:COMPONENTNAME];
        
        if ([componentObject.name isEqualToString:@"Passport"]) { //Only passport component contains subtype key others won't have.
            [component setValue:@"Passport" forKey:@"subtype"];
        }
        
        [jsonComponents addObject:component];
    }
    
    //    NSDictionary *themes = @{@"color":profile.theme.themeColor,@"titlecolor":profile.theme.titleColor,@"buttoncolor":profile.theme.buttonColor,@"buttontextcolor":profile.theme.buttonTextColor,@"buttonborder":profile.theme.buttonBorder,@"buttonstyle":profile.theme.buttonStyle};
    
    NSDictionary* json = @{METADATA:metadata,COMPONENTS:jsonComponents};
    
    NSError* error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:NSJSONWritingPrettyPrinted error:&error];
    return jsonData;
}


@end
