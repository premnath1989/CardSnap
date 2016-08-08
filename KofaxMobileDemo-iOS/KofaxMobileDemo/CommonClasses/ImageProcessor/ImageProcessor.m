//
//  ImageProcessor.m
//  BankRight
//
//  Created by kaushik on 04/08/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ImageProcessor.h"
#import "AppStateMachine.h"
#import "LicenceHelper.h"

@interface ImageProcessor() <kfxKIPDelegate,kfxKCLDelegate>{
    
    
}

@property (nonatomic, strong) kfxKCLImageClassifier *classifier;
@property (nonatomic,strong)  kfxKENImageProcessor *imageProcessor;
@end

@implementation ImageProcessor

-(void)processImage:(kfxKEDImage*)inputImage withProfile:(kfxKEDImagePerfectionProfile*)imgPerfectionProfile{
    
    if(!self.imageProcessor)
        self.imageProcessor = [kfxKENImageProcessor instance];
    self.imageProcessor.delegate = self;
    self.imageProcessor.imagePerfectionProfile = imgPerfectionProfile;
    self.imageProcessor.processedImageMimetype = inputImage.imageMimeType;
    self.imageProcessor.processedImageRepresentation = IMAGE_REP_BITMAP;   //We are using same shared instance for image processing, so once check has been processed then it's data (image file path & image) will be saved in this shared instance. And then if we try to process bill pay or custom component then it will give an error because file path has been saved in this object, So to avoid this error we will give image represention as bitmap then it will not check file path.
    
    int status = [self.imageProcessor processImage:inputImage];
    if (status != KMC_SUCCESS) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(processingSucceeded:withOutputImage:)])
            [self.delegate processingSucceeded:NO withOutputImage:nil];
    }
}

-(void)processImage:(kfxKEDImage*)inputImage withProfile:(kfxKEDImagePerfectionProfile*)imgPerfectionProfile withFileName:(NSString *)strFilePath mimeType:(KEDImageMimeType)mimeType
{
    
    if(!self.imageProcessor)
        self.imageProcessor = [kfxKENImageProcessor instance];
    self.imageProcessor.delegate = self;
    self.imageProcessor.imagePerfectionProfile = imgPerfectionProfile;
    
    self.imageProcessor.processedImageMimetype = mimeType;
    
    if(strFilePath != nil)
    {
        self.imageProcessor.processedImageRepresentation = IMAGE_REP_BOTH;
        [self.imageProcessor specifyProcessedImageFilePath:strFilePath];
    }
    else {
        
        self.imageProcessor.processedImageRepresentation = IMAGE_REP_BITMAP;
    }
    
    
    
    int status = [self.imageProcessor processImage:inputImage];
    NSString * message = [kfxError findErrMsg:status];
    NSString * description = [kfxError findErrDesc:status];
    NSLog(@"message %@",message);
    NSLog(@"description %@",description);
    
    if (status != KMC_SUCCESS) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(processingSucceeded:withOutputImage:)])
            [self.delegate processingSucceeded:NO withOutputImage:nil];
    }
}

-(void)cancelProcessing
{
    [self.imageProcessor cancelProcessing];
}

-(void)performQuickAnalysisOnImage:(kfxKEDImage*)inputImage
{
    kfxKENImageProcessor *imageProcessor = [kfxKENImageProcessor instance];
    imageProcessor.delegate = self;
    int status=[imageProcessor doQuickAnalysis:inputImage andGenerateImage:NO];
    if (status != KMC_SUCCESS) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(quickAnalysisResponse:)])
            [self.delegate quickAnalysisResponse:nil];
    }
}

/**
 Method to classify the initially processed DL based on the found state.\n
 The state is identified using the SDK API method  "classifyImage". \n
 The pre-classification steps include loading the model file and configuration file (if not already loaded).
 @param processedImage : an image reference to the processed image after initial processing.
 */
-(void)classifyLicenseWithImage:(kfxKEDImage*)processedImage
{
    
    //    if(!queue_Operation)
    //        return;
    
    self.classifier = [kfxKCLImageClassifier instance];
    self.classifier.delegate=self;
    
    NSBundle* myBundle = [NSBundle mainBundle];
    NSString* cfgFileName = [myBundle pathForResource:@"driverslicense_config" ofType:@"xml"];
    NSString *modelFileName = [myBundle pathForResource:@"driverslicense_model" ofType:@"xml"];
    
    self.classifier.maxNumberOfResults=3;
    
    int cfgFileError = [self.classifier loadConfigurationFile:cfgFileName];
    if (cfgFileError == KMC_GN_FILE_NOT_FOUND){
        
        // Config file not loaded.
    }
    
    
    int modelFileError = [self.classifier loadModel:modelFileName];
    if (modelFileError == KMC_GN_FILE_NOT_FOUND)
    {
        
        // Model file not loaded.
    }
    
    int classificationOutput = [self.classifier classifyImage:processedImage];
    if (classificationOutput == KMC_SUCCESS)
    {
        
        // Proper classification done id.
    }
}

#pragma mark Image Processing Delegate Methods


/**
 Delegate method called when the DL front classification is completed by the SDK API "classifyImage" method.
 */


-(void)imageClassifier:(kfxKCLImageClassifier *)imageClassifier status:(int)status statusMsg:(NSString *)statusMsg image:(kfxKEDImage *)image
{
    if(status == KMC_SUCCESS)
    {
        NSMutableArray *classifyResultsArray = [image classificationResults];
        //NSLog(@"array is %@",classifyResultsArray);
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(classificationSucceded:withClassification:Image:)])
            [self.delegate classificationSucceded:YES withClassification:[classifyResultsArray objectAtIndex:0] Image:image];
        
    }
    else
    {
        //throw error
    }
    
    
}

- (void)imageOut:(int)status withMsg: (NSString*) errorMsg andOutputImage: (kfxKEDImage*) kfxImage{
    
    
    if(status == KMC_SUCCESS){
        if(self.delegate && [self.delegate respondsToSelector:@selector(processingSucceeded:withOutputImage:)])
            [self.delegate processingSucceeded:YES withOutputImage:kfxImage];
    }
    else{
        if(self.delegate && [self.delegate respondsToSelector:@selector(processingSucceeded:withOutputImage:)])
            [self.delegate processingSucceeded:NO withOutputImage:nil];
    }
    
}

- (void)processProgress: (int) status withMsg: (NSString*) errorMsg imageID: (NSString*) imageID andProgress: (int) percent{
    
    NSLog(@"percentage = %d\n",percent);
    
}
//Use this method to specify the image upon which you want to perform a quick analysis. The image processor will check image quality and determine the page edges of a document in the image.
- (void) analysisComplete: (int)  status
                  withMsg: (NSString *)  errorMsg
           andOutputImage: (kfxKEDImage *)  kfxImage {
    
    kfxKEDQuickAnalysisFeedback *feedback = kfxImage.imageQuickAnalysisFeedback;
    if(self.delegate && [self.delegate respondsToSelector:@selector(quickAnalysisResponse:)])
        [self.delegate quickAnalysisResponse:feedback];
    
}


- (void)analysisProgress: (int) status withMsg: (NSString*) errorMsg imageID: (NSString*) imageID andProgress: (int) percent{
    
    
}

@end
