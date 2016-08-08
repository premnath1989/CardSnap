//
//  JSONEngine.h
//  Kofax Mobile Demo
//
//  Created by Mahendra on 13/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

@interface JSONEngine : NSObject
{
    
}

//This method parses the imported
-(NSDictionary*)parseJSONData : (NSData*)profileData;

//This method creates a JSON file from the settings and returns JSON as data
-(NSData*)createJSONForProfile : (Profile*)profile;

@end
