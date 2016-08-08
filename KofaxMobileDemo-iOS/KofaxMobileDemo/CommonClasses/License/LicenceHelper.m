//
//  LicenceHelper.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 25/09/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "LicenceHelper.h"
#import "CertificatePinningManager.h"

typedef enum {
    ACQUIRE_LICENCE_INPROGRESS = 0,
    ACQUIRE_LICENCE_COMPLETED = 1,
    ACQUIRE_LICENCE_FAILED = 2,
    ACQUIRE_LICENCE_NO_MORE_LICENCE = 3,
} kfxKUTAcquireLicence;

@interface LicenceHelper ()<kfxKUTAcquireVolumeLicenseDelegate, kfxKUTCertificateValidatorDelegate>
{
    
}
@end

kfxKUTLicensing *licenseConfig;
kfxKUTAcquireLicence acquireProcessingStatus;
kfxKUTAcquireLicence acquireOnDeviceExtractionStatus;
kfxKUTAcquireLicence acquireImageCaptureStatus;
kfxKUTAcquireLicence acquireBarcodeStatus;

kfxKUTLicenseFeature currentFeature;

@implementation LicenceHelper

// Creating a singleton instance of LicenceHelper class
+(id)sharedInstance{
    
    static LicenceHelper *licence = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        licence = [[LicenceHelper alloc] init];
        if (licenseConfig==nil) {
            licenseConfig = [[kfxKUTLicensing alloc] init];
        }
    });
    return licence;
}

/* 
 
 This method is used to set the SDK license .
 For a valid license  we recive KMC_SUCCESS and error for invalid license 
 
*/

-(int)setMobileSDKLicence:(NSString*) license{
    return [licenseConfig setMobileSDKLicense:license];
}

/* 
 
 This method is used to set the SDK server url path.
 
*/

-(void)setMobileSDKLicenceServer:(NSString*) url type:(kfxKUTLicenseServerType) serverType{
    [licenseConfig setMobileSDKLicenseServer:url type:serverType];
}

/*
 
 This method is used to return the remaining days for license expiration
 
*/

-(int)getDaysRemaining{
    return licenseConfig.daysRemaining;
}

/*
 
 This method is used to check , if the SDK  License is valid for specific feature .
 
 Ex: LIC_BARCODE_CAPTURE  to check if the SDK has valid license to scan barcode image .
 
 Therefore before capturing an image or scanning barcode or processing or on device extraction , this method should be invoked.
 
 */


-(int)isSdkLicensed:(kfxKUTLicenseFeature)feature{
    return [kfxKUTLicensing isSdkLicensed:feature];
}

/*
 This method is used to pre-allocate license for specific feature before in hand .
 
 */
- (void) acquireVolumeLicenses: (kfxKUTLicenseFeature) licenseType withCount: (int) count{
    licenseConfig.delegate = self;
    licenseConfig.certificateValidatorDelegate = self;
    [licenseConfig acquireVolumeLicenses:licenseType withCount:count];
}


/*
 This method will return the number of valid license for a specific feature .
 */
- (int)getRemainingLicenseCount:(kfxKUTLicenseFeature) licType{
   return [licenseConfig getRemainingLicenseCount:licType];
}

/*
 
 This method is used to check whether we can invoke the specified  offline feature  or not 
 
*/


-(BOOL)canProceedForFeature:(kfxKUTLicenseFeature)licType{
    currentFeature = licType;
    
    NSInteger availableCount = [self getRemainingLicenseCount:licType];
    if (availableCount>=10) {
        return true;
    }
    else if (availableCount<10 && availableCount!=0) {
        
        if (self.isAutoFetchActive && [self canAcqureLicence:licType]){
            [self acquireVolumeLicenses:licType withCount:_requestLicenceCount];
            return true;
        }else{
            return false;
        }
    }
    return false;
}

-(BOOL)canAcqureLicence:(kfxKUTLicenseFeature)licType
{
    BOOL status = false;
    
    if (licType == LIC_IMAGE_PROCESSING && acquireProcessingStatus != ACQUIRE_LICENCE_NO_MORE_LICENCE&&acquireProcessingStatus!= ACQUIRE_LICENCE_INPROGRESS) {
        acquireProcessingStatus = ACQUIRE_LICENCE_INPROGRESS;
        status  = true;
    }
    else if (licType == LIC_IMAGE_CAPTURE && acquireImageCaptureStatus != ACQUIRE_LICENCE_NO_MORE_LICENCE && acquireImageCaptureStatus != ACQUIRE_LICENCE_INPROGRESS){
        acquireImageCaptureStatus = ACQUIRE_LICENCE_INPROGRESS;
        status  = true;
    }
    else if (licType == LIC_BARCODE_CAPTURE && acquireBarcodeStatus != ACQUIRE_LICENCE_NO_MORE_LICENCE && acquireBarcodeStatus != ACQUIRE_LICENCE_INPROGRESS){
        acquireBarcodeStatus = ACQUIRE_LICENCE_INPROGRESS;
        status  = true;
    }
    else if (licType == LIC_ON_DEVICE_EXTRACTION && acquireOnDeviceExtractionStatus != ACQUIRE_LICENCE_NO_MORE_LICENCE && acquireOnDeviceExtractionStatus != ACQUIRE_LICENCE_INPROGRESS){
        acquireOnDeviceExtractionStatus = ACQUIRE_LICENCE_INPROGRESS;
        status  = true;
    }
    return status;
}

#pragma mark- AcquireVolumeLicenseDelegate Implementation


- (void)acquireVolumeLicenseDone:(int) licAcquired error: (NSError*) error{

    NSLog(@"Error in Acquire : %@",error);
    
    // error handling here
    //TODO: Does not have all error response code need to implement
    if (error!=nil) {
        
    }
    else if (currentFeature == LIC_IMAGE_PROCESSING) {
        if (licAcquired > 0) {
            acquireProcessingStatus = ACQUIRE_LICENCE_COMPLETED;
        }
        else{
            acquireProcessingStatus = ACQUIRE_LICENCE_NO_MORE_LICENCE;
        }
    }
    else if (currentFeature == LIC_IMAGE_CAPTURE){
        if (licAcquired > 0) {
            acquireImageCaptureStatus = ACQUIRE_LICENCE_COMPLETED;
        }
        else{
            acquireImageCaptureStatus = ACQUIRE_LICENCE_NO_MORE_LICENCE;
        }
    }
    else if (currentFeature == LIC_BARCODE_CAPTURE){
        if (licAcquired > 0) {
            acquireBarcodeStatus = ACQUIRE_LICENCE_COMPLETED;
        }
        else{
            acquireBarcodeStatus = ACQUIRE_LICENCE_NO_MORE_LICENCE;
        }
    }
    else if (currentFeature == LIC_ON_DEVICE_EXTRACTION){
        if (licAcquired > 0) {
            acquireOnDeviceExtractionStatus = ACQUIRE_LICENCE_COMPLETED;
        }
        else{
            acquireOnDeviceExtractionStatus = ACQUIRE_LICENCE_NO_MORE_LICENCE;
        }
    }
    
    if (self.licenceDelegate!=nil && [self.licenceDelegate respondsToSelector:@selector(acquireVolumeLicenseDone:error:)]) {
        [self.licenceDelegate acquireVolumeLicenseDone:licAcquired error:error];
    }
}

- (void)certificateValidatorForURLSession:(NSURLSession*)session
                      didReceiveChallenge:(NSURLAuthenticationChallenge*)challenge
                        completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential* credential))completionHandler

{
    if (![[CertificatePinningManager sharedInstance] handleURLSession:session didReceiveChallenge:challenge completionHandler:completionHandler])
    {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
