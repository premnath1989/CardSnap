//
//  RTTIManager.h
//  BankRight
//
//  Created by kaushik on 04/08/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <kfxLibEngines/kfxEngines.h>
#import "OnDeviceExtractor.h"

typedef enum ServerType{
    
    RTTI =0,
    KTA,
    ON_DEVICE_EXTRACTION
}ServerType;


@protocol ExtractionManagerProtocol <NSObject>
@optional
-(void)extractionSucceeded:(NSInteger)statusCode withResults:(NSData*)results;
-(void)extractionFailedWithError:(NSError*)error responseCode:(NSInteger)responseCode;

@end

@interface ExtractionManager : NSObject
{
    
}

//the server type needed to communicate Default is RTTI (0)
@property(nonatomic)ServerType serverType;


-(void)extractDataForImage:(kfxKEDImage*)processedImage URL:(NSURL*)serverURL withMimeType :(KEDImageMimeType) MIME_TYPE;
-(void)cancelExtraction;

- (void)extractFieldsOnDeviceFrontImage:(kfxKEDImage*)frontImage backImage:(kfxKEDImage*)backImage region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL*)serverUrl;

-(void)extractFieldsFrontImage:(kfxKEDImage *)frontImage barcode:(NSString *)barcode region:(kfxKOEIDRegion)region modelsType:(assetProvider)type url:(NSURL *)serverUrl;

//This API determines the local version of the assets of a region and returns true if they are available
-(BOOL)isLocalVersionAvailable:(kfxKOEIDRegion)region;


//This method makes a mulit-part request to the RTTI server Send front and back images and the server URL Required parameters can be passed as a dictionary and all the keys and values are added as parameters The same method can be used to send even one image





//This method makes a mulit-part request to the RTTI server Send's the processed and unprocessed images and the server URL Required parameters can be passed as a dictionary and all the keys and values are added as parameters The same method can be used to send even one image. saveoriginalimages can be nil if you dont want to save the original images

-(void)extractImagesData:(NSArray*)processedImagesArray saveOriginalImages:(NSArray*)originalImagesArray withURL:(NSURL*)url withParams: (NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE;

-(void)extractImagesDataWithProcessNameSync:(NSArray*)processedImagesArray saveOriginalImages:(NSArray*)originalImagesArray withURL:(NSURL*)url withParams: (NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE;

-(int)extractImageFiles : (NSArray*)processedImageFiles saveOriginalImages: (NSArray*)originalImageFiles withURL:(NSURL*)url withParams:(NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE;

-(int)extractImageFilesWithProcessSync : (NSArray*)processedImageFiles saveOriginalImages: (NSArray*)originalImageFiles withURL:(NSURL*)url withParams:(NSDictionary*)paramsDict withMimeType :(KEDImageMimeType) MIME_TYPE;



@property id <ExtractionManagerProtocol> delegate;


@property(nonatomic,strong) NSMutableDictionary *extractionResults;



@end
