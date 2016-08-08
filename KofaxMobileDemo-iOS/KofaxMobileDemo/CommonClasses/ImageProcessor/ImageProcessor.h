//
//  ImageProcessor.h
//  BankRight
//
//  Created by kaushik on 04/08/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibLogistics/kfxLogistics.h>
#import <kfxLibUtilities/kfxUtilities.h>


@protocol ImageProcessorProtocol <NSObject>

@optional
-(void)processingSucceeded:(BOOL)status withOutputImage:(kfxKEDImage*)processedImage;
-(void)classificationSucceded : (BOOL)status withClassification: (kfxKEDClassificationResult*)classificationResult Image:(kfxKEDImage*)classifiedImage;
-(void)quickAnalysisResponse:(kfxKEDQuickAnalysisFeedback*)feedback;

@end

@interface ImageProcessor : NSObject

@property id<ImageProcessorProtocol>delegate;

-(void)processImage:(kfxKEDImage*)inputImage withProfile:(kfxKEDImagePerfectionProfile*)inputProfile;
-(void)processImage:(kfxKEDImage*)inputImage withProfile:(kfxKEDImagePerfectionProfile*)imgPerfectionProfile withFileName:(NSString *)strFilePath mimeType:(KEDImageMimeType)mimeType;
-(void)cancelProcessing;

-(void)classifyLicenseWithImage:(kfxKEDImage*)processedImage;

-(void)performQuickAnalysisOnImage:(kfxKEDImage*)inputImage;
@end
