//
//  ChecksHistory.h
//  KofaxMobileDemo
//
//  Created by kaushik on 13/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChecksHistory : NSManagedObject

@property (nonatomic, retain) NSString * amount;
@property (nonatomic, retain) NSData * backImageFilePath;
@property (nonatomic, retain) NSDate * checkDate;
@property (nonatomic, retain) NSString * checkNumber;
@property (nonatomic, retain) NSData * frontImageFilePath;
@property (nonatomic, retain) NSString * micrCode;
@property (nonatomic, retain) NSDate * payDate;
@property (nonatomic, retain) NSString * payeeName;

@end
