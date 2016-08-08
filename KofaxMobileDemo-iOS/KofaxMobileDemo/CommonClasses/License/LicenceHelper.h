//
//  LicenceHelper.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 25/09/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <kfxLibUtilities/kfxUtilities.h>

@protocol LicenceHelperDelegate <NSObject>

- (void)acquireVolumeLicenseDone:(int) licAcquired error: (NSError*) error;
@end

@interface LicenceHelper : NSObject<kfxKUTAcquireVolumeLicenseDelegate>
@property (nonatomic,assign) id licenceDelegate;
@property (readonly) int daysRemaining;
@property (nonatomic,assign) int requestLicenceCount;
@property (nonatomic,assign) BOOL isAutoFetchActive;

+(id)sharedInstance;

// set SDK licence here
// This method will return either KMC_SUCCESS or error if licence is not valid
-(int)setMobileSDKLicence:(NSString*) license;
// set SDK  server licence here for maintaining extraction volume count availability
-(void)setMobileSDKLicenceServer:(NSString*) url type:(kfxKUTLicenseServerType) serverType;

// it will return number of days before the licence expires
-(int)getDaysRemaining;



/*
 This method will return the number of valid license for a specific feature .
 */
- (int)getRemainingLicenseCount:(kfxKUTLicenseFeature) licType;


/*
 
 Here you can check , If SDK is licenced for specific feature only
 for example kfxKUTLicenseFeature can we LIC_IMAGE_PROCESSING or LIC_IMAGE_CAPTURE or LIC_BARCODE_CAPTURE or LIC_ON_DEVICE_EXTRACTION
 before processing , On Device Extraction , Barcode Scan or Capturing an image call this method to check whether this is available for this licence or not.
 
 */
// it will return number of days before the licence expires
-(int)isSdkLicensed:(kfxKUTLicenseFeature)feature;

// Method to check whether we can proceed for offline feature or show alert No available offline count
//@return
// true : can proceed for offline feature since offline volume is vailable.
// false :  can not proceed offline feature. show alert
-(BOOL)canProceedForFeature:(kfxKUTLicenseFeature)licType;


/*
 This method is used to allocates the volume for offline operation.
 
 */
- (void) acquireVolumeLicenses: (kfxKUTLicenseFeature) licenseType withCount: (int) count;

@end
