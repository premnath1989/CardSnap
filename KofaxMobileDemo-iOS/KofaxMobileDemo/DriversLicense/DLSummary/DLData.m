//
//  DLData.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 05/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "DLData.h"

@implementation DLData

-(id)init
{
    if(self = [super init])
    {
        
    }
    
    return self;
}

-(void)setDefaultValues
{
    self.drivinglicenseID = @"";
    self.dob = @"";
    self.name = @"";
    self.firstName = @"";
    self.lastName = @"";
    self.street = @"";
    self.gender = @"";
    self.zipCode = @"";
    self.state = @"";
    self.city = @"";
    self.drivingLicenseNumber = @"";
    self.imgDriverPhoto = nil;
    self.imgDriverSignature = nil;

}

-(void)mergeDataWithObject:(DLData*)newData
{
    if([newData.name length])
        self.name = newData.name;
    if([newData.firstName length])
        self.firstName = newData.firstName;
    if([newData.lastName length])
        self.lastName = newData.lastName;
    if([newData.street length])
        self.street = newData.street;
    if([newData.dob length])
        self.dob = newData.dob;
    if([newData.gender length])
        self.gender = newData.gender;
    if([newData.state length])
        self.state = newData.state;
    if([newData.zipCode length])
        self.zipCode = newData.zipCode;
    if([newData.drivinglicenseID length])
        self.drivinglicenseID = newData.drivinglicenseID;
    if([newData.city length])
        self.city = newData.city;
    if ([newData.drivingLicenseNumber length])
        self.drivingLicenseNumber = newData.drivingLicenseNumber;
    if(newData.imgDriverPhoto!=nil)
        self.imgDriverPhoto = newData.imgDriverPhoto;
    if(newData.imgDriverSignature!=nil)
        self.imgDriverSignature = newData.imgDriverSignature;
    
}

@end
