//
//  OnDeviceExtractor.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 26/09/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import "OnDeviceExtractor.h"
#import <kfxLibEngines/kfxEngines.h>

//kfxKOEIDExtractor* idExtractor;

@interface OnDeviceExtractor ()
{
    
}

@property (nonatomic,strong)kfxKOEIDExtractor* idExtractor;

@end

@implementation OnDeviceExtractor


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _idExtractor = [[kfxKOEIDExtractor alloc] init];
    }
    return self;
}

-(void)dealloc
{
    _idExtractor = nil;
}


#pragma mark
#pragma Extraction methods and public APIs

//method to extract data from front and back images
- (void)extractFieldsFrontImage:(kfxKEDImage*)frontImage backImage:(kfxKEDImage*)backImage region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL*)serverUrl
{
    [self extractData:frontImage backImage:backImage region:region url:serverUrl];
}


-(void)extractFieldsFrontImage:(kfxKEDImage *)frontImage barcode:(NSString *)barcode region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL *)serverUrl
{
    [self extractDataForBarcode:frontImage barcode:barcode region:region url:serverUrl];
    
}


-(BOOL)isLocalVersionAvailable:(kfxKOEIDRegion)region
{
    NSString* localModelVersion = [self getLocalVersionForRegion:region];
    
    if(localModelVersion != nil)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
    return NO;
    
}

- (void)cancelExtraction
{
    self.idExtractor.delegate = nil;
    [self.idExtractor cancelExtraction];
}


#pragma mark
#pragma mark internal

-(NSString*)getLocalVersionForRegion : (kfxKOEIDRegion)region
{
    KFXBundleCacheProvider *cacheProvider = [[KFXBundleCacheProvider alloc]init];
   
    NSString* localModelVersion = [cacheProvider latestVersionForProject:[KFXIDExtractionParameters projectNameForRegion:region]];
    return localModelVersion;
}

-(void)extractData : (kfxKEDImage*)frontImage backImage : (kfxKEDImage*)backImage region: (kfxKOEIDRegion)region url:(NSURL *)serverUrl;
{
    KFXServerProjectProvider *kfxServerProjectProvider = [[KFXServerProjectProvider alloc]initWithURL:serverUrl];
    _idExtractor = [[kfxKOEIDExtractor alloc] initWithProjectProvider:kfxServerProjectProvider];
    self.idExtractor.delegate = self;
    KFXIDExtractionParameters* parameters = [[KFXIDExtractionParameters alloc] initWithFrontImage:frontImage backImage:backImage region:region];
    [self.idExtractor extract:parameters];
}

-(void)extractDataForBarcode : (kfxKEDImage*)frontImage barcode : (NSString*)barcode region: (kfxKOEIDRegion)region url:(NSURL *)serverUrl;
{
    KFXServerProjectProvider *kfxServerProjectProvider = [[KFXServerProjectProvider alloc]initWithURL:serverUrl];
    _idExtractor = [[kfxKOEIDExtractor alloc] initWithProjectProvider:kfxServerProjectProvider];
    self.idExtractor.delegate = self;
    KFXIDExtractionParameters* parameters = [[KFXIDExtractionParameters alloc] initWithFrontImage:frontImage barcode:barcode region:region];
    [self.idExtractor extract:parameters];
}

#pragma mark
#pragma mark utilities
-(NSString *)getProperErrorMessageErrorCode:(int)errorCode
{
    NSString* message = [kfxError findErrMsg:errorCode];
    NSString* description = [kfxError findErrDesc:errorCode];
    NSArray* split = [message componentsSeparatedByString:@": "];
    NSString * strMessage = @"";
    
    if (split.count == 2){
        strMessage = [NSString stringWithFormat:@"%@\n\n%@", [split objectAtIndex:1], description];
    }
    else if (split.count > 2){
        NSString* info = @"";
        for (int i = 1; i < split.count ; i++)
        {
            info = [NSString stringWithFormat:@"%@ %@", info, [split objectAtIndex:i]];
        }
        strMessage = [NSString stringWithFormat:@"%@\n\n%@", info, description];
    }
    else{
        strMessage = [NSString stringWithFormat:@"%@\n\n%@", message, description];
    }
    
    return strMessage;
}

#pragma mark- kfxKOEIDExtractorDelegate Implementation

-(void)extractionResult:(KFXIDExtractionResult *)result frontError:(NSError *)frontError backError:(NSError *)backError{
    self.idExtractor.delegate = nil;
    int frontErr = (int)frontError.code;
    int backErr = (int)backError.code;
    
    for(id obj in result.fields){
        NSLog(@"name is %@",[(kfxKOEDataField*)obj name]);
        NSLog(@"name is %@",[(kfxKOEDataField*)obj value]);
    }
    
    if ((!frontErr) || (!backErr && result.isBarcodeRead)){
        if(self.delegate && [self.delegate respondsToSelector:@selector(didExtractData:withResults:)]){
            // convert kfxData object to our local Driver object Format
            [self.delegate didExtractData:KMC_SUCCESS withResults:result.fields];
        }
        
    }
    else{
        NSString *message =  [self getProperErrorMessageErrorCode:frontErr];
        NSDictionary *error = [NSDictionary dictionaryWithObjectsAndKeys:frontError,FRONT_IMAGE_ERROR,backError,BACK_IMAGE_ERROR,nil];

        NSError *errorInfo = [NSError errorWithDomain:message code:frontError.code userInfo:error];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(didFailToExtractData:responseCode:)])
        [self.delegate didFailToExtractData:errorInfo responseCode:frontErr];
    }
}


#pragma mark
#pragma mark ODE model downloads

-(void)bulkDownloadLocalExtractionAssetsForRegion : (kfxKOEIDRegion)region onServer:(NSURL*)serverUrl completionHandler:(void(^)(NSError* error))completionHandler
{
    NSString* project = [KFXIDExtractionParameters projectNameForRegion:region];
    KFXServerProjectProvider *kfxServerProjectProvider = [[KFXServerProjectProvider alloc]initWithURL:serverUrl ];
    [kfxServerProjectProvider loadAllVariantsForProject:project completionHandler:completionHandler];
}


-(void)checkForModelUpdates : (kfxKOEIDRegion)region onServer:(NSURL*)serverUrl completionHandler: (void (^)(BOOL isUpdateAvailable,NSError* error ))completionHandler
{
    
    [self determineVersionUpdates:region url:serverUrl completionHandler:completionHandler];
}

#pragma mark
#pragma mark Internal

//call this method to determine the versions available

-(void)determineVersionUpdates : (kfxKOEIDRegion)region url:(NSURL*)serverUrl completionHandler:(void (^)(BOOL isUpdateAvailable, NSError* error ))completionHandler
{
    NSString* project = [KFXIDExtractionParameters projectNameForRegion:kfxKOEIDRegion_US];
    NSString* localModelVersion  = [self getLocalVersionForRegion:region];
    
    __block NSString*  serverVersion;
    __block BOOL  isUpdateAvailable = NO;
    KFXServerProjectProvider *kfxServerProjectProvider = [[KFXServerProjectProvider alloc]initWithURL:serverUrl ];
    [kfxServerProjectProvider getHighestVersion:project sdkVersion:[AppUtilities getSDKVersion] completionHandler:^(NSString* version, NSError* error) {
        
        if(error.code == KMC_SUCCESS)
        {
            serverVersion = version;
            ![serverVersion isEqualToString:localModelVersion] ? isUpdateAvailable = YES :NO;
        }
        
        completionHandler(isUpdateAvailable,error);
        
    }];
}

@end
