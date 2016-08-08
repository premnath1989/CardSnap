//
//  DLData.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 05/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DLData : NSObject
{
    
}

//These are parsed results
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSString * firstName;
@property (nonatomic,strong) NSString * lastName;
@property (nonatomic,strong) NSString *middleName;
@property (nonatomic,strong) NSString * street;
@property (nonatomic,strong) NSString * city;
@property (nonatomic,strong) NSString * state;
@property (nonatomic,strong) NSString * country;
@property (nonatomic,strong) NSString * zipCode;
@property (nonatomic,strong) NSString * dob;
@property (nonatomic,strong) NSString * drivinglicenseID;
@property (nonatomic,strong) NSString * drivingLicenseNumber;
@property (nonatomic,strong) NSString * gender;
@property (nonatomic,strong) NSString*  issueDate;
@property (nonatomic,strong) NSString *expirationDate;
@property (nonatomic,strong) UIImage *imgDriverPhoto;
@property (nonatomic,strong) UIImage *imgDriverSignature;

//this one is user picked region
@property (nonatomic,strong) NSString* userPickedregion;


-(void)mergeDataWithObject:(DLData*)newData;

@end
