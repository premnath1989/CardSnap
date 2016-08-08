//
//  OnDeviceExtractor.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 26/09/15.
//  Copyright (c) 2016 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <kfxLibEngines/kfxEngines.h>
#import "BaseServer.h"

typedef enum
{
    LOCAL,
    SERVER,
} assetProvider;

@interface OnDeviceExtractor : BaseServer <kfxKOEIDExtractorDelegate>


//This API is to extract the data from the given images
/**
 Parameters: 
 frontImage : the captured/processed frontImage
 backImage : the captured/processed backImage can be nil
 region: the region of the ID to be extracted
 modelsType and url are needed only for assets/models of ODE not used for extraction on Device
 modelsType : the type used for the ODE model files set LOCAL if the project is built with local assets or SERVER if asets will be downloaded from Server
 url : the url used to download the assets. This method takes care of On-Demand downloading of variants if something went wrong in bulk download of assets. This should not be nil if modelsType is Server 
 
 */
- (void)extractFieldsFrontImage:(kfxKEDImage*)frontImage backImage:(kfxKEDImage*)backImage region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL*)serverUrl;

-(void)extractFieldsFrontImage:(kfxKEDImage *)frontImage barcode:(NSString *)barcode region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL *)serverUrl;

//This API determines the local version of the assets of a region and returns true if they are available
-(BOOL)isLocalVersionAvailable:(kfxKOEIDRegion)region;

- (void)cancelExtraction;


//API to download the model files all at once in a bulk
-(void)bulkDownloadLocalExtractionAssetsForRegion : (kfxKOEIDRegion)region onServer:(NSURL*)serverUrl completionHandler:(void(^)(NSError *error))completionHandler;

//API to check if the current model version of the assets is latest
-(void)checkForModelUpdates : (kfxKOEIDRegion)region onServer:(NSURL*)serverUrl completionHandler: (void (^)(BOOL isUpdateAvailable,NSError* error ))completionHandler;



@end
