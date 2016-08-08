//
//  CCManager.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CustomComponentManager.h"

#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibLogistics/kfxLogistics.h>
#import <kfxLibUtilities/kfxUtilities.h>
#import <kfxLibUIControls/kfxUIControls.h>
#import "CustomComponentInstructionsViewController.h"

#import "CaptureViewController.h"
#import "ExhibitorViewController.h"
#import "ComponentSettingsViewController.h"
#import "ImageProcessor.h"
#import "ExtractionManager.h"

#import "CustomComponentSummaryViewController.h"

#import "AppStateMachine.h"

static CustomComponentManager *billPayManager = nil;
static NSString * sessionKey = nil;

@interface CustomComponentManager ()<CustomComponentInstructionsProtocol,CaptureViewControllerProtocol,ExhibitorProtocol,ImageProcessorProtocol,ExtractionManagerProtocol,CustomComponentSummaryProtocol,UIAlertViewDelegate>
@property(nonatomic, assign)UINavigationController *navigationController;
@property(nonatomic,strong) AppStateMachine *appStateMachine;
@property(nonatomic,assign) Component *componentObject;
@property(nonatomic,strong) ImageProcessor *imageProcessor;
@property(nonatomic,strong) NSMutableArray *processedResults,*backupResults;
@property(nonatomic) BOOL isFromPreview,isUseButtonClicked,isRetakeImage;
@property(nonatomic) NSInteger extractedStatusCode;
@property(nonatomic,strong)kfxKEDImage *capturedImage_Processed,*capturedImage_Raw;
@property(nonatomic,strong)NSError *extractionError;
@property(nonatomic,strong) ExtractionManager *extractionManager;
@property (assign) BOOL fromImageSelectedMethod;
@property (nonatomic,strong) NSMutableArray *coloredAreas;
@end

@implementation CustomComponentManager
@synthesize navigationController;
@synthesize appStateMachine;
@synthesize componentObject;
@synthesize imageProcessor;
@synthesize processedResults,backupResults;
@synthesize isFromPreview,isUseButtonClicked,isRetakeImage;
@synthesize extractedStatusCode;
@synthesize capturedImage_Processed,capturedImage_Raw;
@synthesize extractionError;
@synthesize extractionManager;
#pragma mark
#pragma mark BillPayInsDelegate Method

/*
 +(id)sharedInstance{
 
 @synchronized(self){
 
 if(billPayManager == nil){
 
 billPayManager = [[BillPayManager alloc] init];
 }
 
 }
 
 return billPayManager;
 
 }
 */

-(void)unloadManager{
    self.appStateMachine = nil;
    self.imageProcessor.delegate = nil;
    self.imageProcessor = nil;
    self.processedResults = nil;
    self.backupResults = nil;
    if (self.self.capturedImage_Processed) {
        [self.self.capturedImage_Processed clearImageBitmap];
        self.self.capturedImage_Processed = nil;
    }
    
    if (self.capturedImage_Raw) {
        [self.capturedImage_Raw clearImageBitmap];
        self.capturedImage_Raw = nil;
    }
    
    self.extractionError = nil;
    self.extractionManager.delegate = nil;
    self.extractionManager = nil;
    
    [self.appStateMachine cleanUpDisk];
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    
    [stats endSession:TRUE withDescription:@"Complete"];

}

-(void)loadCustomComponentManager:(UINavigationController*)appNavController andComponent:(Component*)currentComponent{
    
    //Configuring App's State
    appStateMachine = [AppStateMachine sharedInstance];
    
    appStateMachine.isFront = YES;
    appStateMachine.module = CUSTOM_COMPONENT;
    appStateMachine.appState = NOOP;
    navigationController = appNavController;
    componentObject = currentComponent;
    
    [self showInstructions:navigationController];
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    sessionKey = [[NSUUID UUID] UUIDString];
    
    [stats beginSession: sessionKey withCategory:@"MobileID"];

    
}

#pragma mark Load BillPay instructions

-(void)showInstructions:(UINavigationController*)appNavController{
    
    CustomComponentInstructionsViewController *ccInsVC = [[CustomComponentInstructionsViewController alloc] initWithComponent:componentObject];
    ccInsVC.delegate = self;
    [appNavController pushViewController:ccInsVC animated:YES];
}

#pragma mark BillPay Instructions Delegate Methods

-(void)instructionContinueButtonClicked{
    
    [self showCamera];
    isFromPreview = NO;
}
-(void)instructionsBackButtonClicked{
    [navigationController popViewControllerAnimated:YES];
}
-(void)instructionSettingsChange:(BOOL)boolValue{
    [self.componentObject.componentGraphics.graphicsDictionary setValue:[NSNumber numberWithBool:boolValue] forKey:SHOWINSTRUCTIONSCREEN];
}

-(void)instructionSettingsButtonClicked{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [navigationController pushViewController:componentSettingsController animated:YES];
}

#pragma mark Camera methods

-(void)showCamera{
    CaptureSettings* captureSettings = [[CaptureSettings alloc] init];
    captureSettings.showGallery = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
     captureSettings.showAutoTorch = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:AUTOTORCH ] boolValue];
    captureSettings.useVideoFrame = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTURETYPE ] boolValue];
    if ([[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTURETYPE ] boolValue]) {
        captureSettings.showFlashOptions = NO;
    }else{
        captureSettings.showFlashOptions = YES;
    }
    captureSettings.hideCaptureButton = NO;
    captureSettings.captureExperience = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE ] intValue];
    
    captureSettings.moveCloserMessage = Klm([componentObject.texts.cameraText valueForKey:MOVECLOSER]);
    captureSettings.holdSteadyMessage = Klm([componentObject.texts.cameraText valueForKey:HOLDSTEADY]);
    captureSettings.cancelButtonText = Klm([componentObject.texts.cameraText valueForKey:CANCELBUTTON]);
    captureSettings.userInstruction = Klm([componentObject.texts.cameraText valueForKey:USERINSTRUCTIONFRONT]);
    captureSettings.centerMessage = Klm([componentObject.texts.cameraText valueForKey:CENTERMESSAGE]);
    captureSettings.zoomOutMessage = Klm([componentObject.texts.cameraText valueForKey:ZOOMOUTMESSAGE]);
    captureSettings.capturedMessage = Klm([componentObject.texts.cameraText valueForKey:CAPTUREDMESSAGE]);
    captureSettings.holdParallelMessage = Klm([componentObject.texts.cameraText valueForKey:HOLDPARALLEL]);
    captureSettings.orientationMessage = Klm([componentObject.texts.cameraText valueForKey:ORIENTATION]);

    //Setting default values for zoomMinFillFraction(0.2) and zoomMaxFillFraction(1.5)
    captureSettings.zoomMinFillFraction = 0.2;
    captureSettings.zoomMaxFillFraction = 1.5;
    
    if (captureSettings.cancelButtonText.length == 0)
        captureSettings.cancelButtonText = Klm(@"Cancel");
    
    captureSettings.manualCaptureTime = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
    captureSettings.edgeDetection = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:EDGEDETECTION]intValue];
    captureSettings.doShowGuidingDemo = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue];


    captureSettings.centerShiftValue = 0;
    
    captureSettings.doContinuousCapture = YES;
    captureSettings.staticFramePaddingPercent = 0;
    
    if (![[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE]boolValue]) {
        captureSettings.stabilityThresholdEnabled = YES;
        captureSettings.rollThresholdEnabled = YES;
        captureSettings.pitchThresholdEnabled = YES;
        captureSettings.focusConstraintEnabled = YES;
        
        captureSettings.stabilityThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:STABILITYDELAY]intValue];
        captureSettings.rollThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:ROLLTHRESHOLD]intValue];
        captureSettings.pitchThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:PITCHTHRESHOLD]intValue];
        
        captureSettings.longAxisThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]intValue];
        captureSettings.shortAxisThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]intValue];

        float aspectRatio = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS] valueForKey:FRAMEASPECTRATIO] floatValue];
        
        if(aspectRatio <= 0){
            captureSettings.staticFrameAspectRatio = 0;
            captureSettings.hideStaticFrame = true;
            captureSettings.userInstruction = @"";
        }
        else{
            captureSettings.staticFrameAspectRatio = aspectRatio;
        }
        
    }else{
        
        captureSettings.showPageDetectBorders = NO;
        captureSettings.stabilityDelay = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:STABILITYDELAY]intValue];
        captureSettings.pitchValue = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:PITCHTHRESHOLD]intValue];
        captureSettings.rollValue = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:ROLLTHRESHOLD]intValue];
    }
    
    appStateMachine.appState = CAPTURING;

    if ([componentObject.subType length] && [componentObject.subType isEqualToString:@"Passport"]) {
        [captureSettings setTutorialSampleImage:[UIImage imageNamed:@"Passport_sample.png"]];
    }
    CaptureViewController* captureScreen = [[CaptureViewController alloc] initWithCaptureSettings:captureSettings];
    captureScreen.delegate = self;
    isRetakeImage = NO;
    [navigationController pushViewController:captureScreen animated:YES];
}

#pragma mark Capture Manager Delegate Methods

-(void) imageSelected:(kfxKEDImage *)capturedImage
{
    _fromImageSelectedMethod = YES;
    [self processImageBasedOnSettingsWithImage:capturedImage];
}
-(void)imageCaptured:(kfxKEDImage*)capturedImage{
    _fromImageSelectedMethod = NO;
    [self processImageBasedOnSettingsWithImage:capturedImage];
}

// Processing image independent of captured/selected

- (void)processImageBasedOnSettingsWithImage:(kfxKEDImage*)image{
    capturedImage_Raw = image;
    appStateMachine.appState = CAPTURED;
    isUseButtonClicked = NO;
    if ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS]valueForKey:DOPROCESS] boolValue] == 0 || [[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS]valueForKey:DOPROCESS] boolValue] == NO) {
        self.capturedImage_Processed = image;
        
        //setting mimetype for captured image before going for extraction, we should set mimetype for extraction otherwise it will throw an error.
        
        if ([image imageMimeType] == MIMETYPE_UNKNOWN) {
            if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS]valueForKey:MODE] integerValue]==0){
                image.imageMimeType = MIMETYPE_TIF;
            }
            else {
                image.imageMimeType = MIMETYPE_JPG;
            }
        }
        [self extractData:image];
    }else if ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS ] valueForKey:DOQUICKANALYSIS]boolValue]) {
        [AppUtilities addActivityIndicator];
        if (!imageProcessor)
            imageProcessor = [[ImageProcessor alloc] init];
        imageProcessor.delegate = self;
        [imageProcessor performQuickAnalysisOnImage:image];
    }else{
        if (![AppUtilities isLowerEndDevice]) {
            [self processCapturedImage];
        }
    }
    [self showPreview:image];
}

-(void)cancelCamera{
    
    if(appStateMachine.appState == PROCESSING){
        
        return;
    }
    
    if (isRetakeImage) {
        ExhibitorViewController *exhibitorObj = [[ExhibitorViewController alloc]initWithNibName:EXHIBITORVIEWCONTROLLER bundle:nil];
        exhibitorObj.inputImage = self.capturedImage_Processed;
        exhibitorObj.leftButtonTitle = Klm([componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
        exhibitorObj.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:CANCELBUTTON]);
        
        if (exhibitorObj.leftButtonTitle.length==0)
            exhibitorObj.leftButtonTitle = Klm(@"Retake");
        
        if (exhibitorObj.rightButtonTitle.length == 0)
            exhibitorObj.rightButtonTitle = Klm(@"Cancel");
        
        exhibitorObj.isCancelButtonShow = YES;
        exhibitorObj.delegate = self;
        
        if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTSWITCH] boolValue])
        {
            
            if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTDATA] boolValue]){
                if(self.coloredAreas && [self.coloredAreas count] > 0){
                    [exhibitorObj setColoredAreas:self.coloredAreas];
                }
            }
            else{
                [exhibitorObj setColoredAreas:nil];
            }
        }
        
        [navigationController pushViewController:exhibitorObj animated:NO];
        //[self showPreview:appStateMachine.front_processed];
    }else{
        extractionError = nil;
        extractionManager = nil;
        imageProcessor = nil;
        processedResults = nil;
        self.backupResults = nil;
        [navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    appStateMachine.appState = NOOP;
}

#pragma mark Preview methods

-(void)showPreview:(kfxKEDImage*)capturedImage{
    ExhibitorViewController *exhibitorObj = [[ExhibitorViewController alloc]initWithNibName:EXHIBITORVIEWCONTROLLER bundle:nil];
    exhibitorObj.inputImage = capturedImage;
    exhibitorObj.delegate = self;
    if(!_fromImageSelectedMethod){
        [exhibitorObj removeNavigationBarItems];
        exhibitorObj.leftButtonTitle = Klm([componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
        exhibitorObj.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:FRONTUSEBUTTON]);
        
        if (exhibitorObj.leftButtonTitle.length==0)
            exhibitorObj.leftButtonTitle = Klm(@"Retake");
        
        if (exhibitorObj.rightButtonTitle.length == 0)
            exhibitorObj.rightButtonTitle = Klm(@"Use");
        }
    else {
        
        exhibitorObj.showTopBar = YES;
        exhibitorObj.leftButtonTitle = @"";
        exhibitorObj.rightButtonTitle=@"";
    }
    
    
    
    [navigationController pushViewController:exhibitorObj animated:YES];
    
}

#pragma mark Exhibitor Delegate Methods

-(void)useSelectedPhotoButtonClicked{
    
    [self useButtonClicked];
    
}
-(void)albumButtonClicked
{
    // album button clicked
    [self retakeButtonClicked];
    
}
-(void)useButtonClicked{
    
    if ([AppUtilities isConnectedToNetwork]) {
        isUseButtonClicked = YES;
        [AppUtilities addActivityIndicator];
        if (appStateMachine.appState == EXTRACTED) {
            if (extractedStatusCode==200) {
                [AppUtilities removeActivityIndicator];
                [self showSummaryScreen:processedResults withImage:self.capturedImage_Processed andAnimation:YES];
            }else if(extractionError.code == -1009 || self.extractedStatusCode == 0){
                [self extractData:self.capturedImage_Processed];
            }else if(extractionError){
                [AppUtilities removeActivityIndicator];
                NSString *errorMessage;
                if (extractionError.code == -1001) {
                    errorMessage = Klm(@"The Request timed out.");
                }else{
                    errorMessage = Klm([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?@"The KTA server may be offline or does not exist.":@"The RTTI server may be offline or does not exist.");
                }
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:errorMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                alert.tag = EXTRACTION_FAILED_TAG;
                [alert show];
            }else{
                [AppUtilities removeActivityIndicator];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Couldn’t read the Document.") delegate:self cancelButtonTitle:Klm(@"OK")otherButtonTitles:nil];
                alertView.tag = EXTRACTION_FAILED_TAG;
                [alertView show];
            }
        }else if(appStateMachine.appState == PROCESSED){
            [self extractData:self.capturedImage_Processed];
        }else if(appStateMachine.appState == CAPTURED){
            [self processCapturedImage];
        }
    }else{
        UIAlertView* networkError = [[UIAlertView alloc] initWithTitle:Klm(@"Extraction failed") message:@"Document extraction cannot be performed because the app cannot connect to the network." delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
        [networkError show];
    }
}
-(void)retakeButtonClicked{
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    kfxKUTAppStatsSessionEvent * evt = [[kfxKUTAppStatsSessionEvent alloc] init];
    evt.type = @"RETAKE";
    
    [stats logSessionEvent:evt];
    
    if (isFromPreview) {
        isRetakeImage = YES;
        [self discardCapturedImage:NO];
    }else{
        isRetakeImage = NO;
        [self discardCapturedImage:YES];
    }
}

-(void)cancelButtonClicked{
    
    [self showSummaryScreen:self.backupResults withImage:self.self.capturedImage_Processed andAnimation:NO];

   
}

-(kfxKEDImagePerfectionProfile*)getProcessingProfile{
    
    kfxKEDImagePerfectionProfile * kPerfectionProf=nil;
    NSString * opStr = [AppUtilities getEVRSImagePerfectionStringFromSettings:[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] ofComponentType:CUSTOM isFront:appStateMachine.isFront withScaleSize:CGSizeZero withFrontImageWidth:nil];
    
    kPerfectionProf = [[kfxKEDImagePerfectionProfile alloc]initWithName:STATICPERFECTIONPROFILE andOperations:opStr];
    
    return kPerfectionProf;
}


#pragma mark Processor methods

-(void)processCapturedImage{
    
    if (!imageProcessor)
        imageProcessor = [[ImageProcessor alloc] init];
    imageProcessor.delegate = self;
    
    if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS]valueForKey:MODE] integerValue]==0){
        
        capturedImage_Raw.imageMimeType = MIMETYPE_TIF;
    }
    else {
        
        capturedImage_Raw.imageMimeType = MIMETYPE_JPG;
        
    }
    
    appStateMachine.appState = PROCESSING;
    
    [imageProcessor processImage:capturedImage_Raw withProfile:[self getProcessingProfile]];
    
    
}
-(void)discardCapturedImage:(BOOL)animation{
    
    if (appStateMachine.appState==PROCESSING) {
        [imageProcessor cancelProcessing];
    }else if(appStateMachine.appState == EXTRRACTING){
        [extractionManager cancelExtraction];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        CaptureViewController * capVC = nil;
        UIViewController *aViewController = ([self.navigationController.viewControllers count] >= 2) ?[navigationController.viewControllers objectAtIndex:navigationController.viewControllers.count-2]:nil;
        
        if(aViewController && [aViewController isKindOfClass:[CaptureViewController class]]){
            
            capVC = (CaptureViewController*)aViewController;
            
            if(_fromImageSelectedMethod)
                capVC.loadAlbum = YES;
            else
                capVC.loadAlbum=NO;
            
            [navigationController popViewControllerAnimated:animation];
            appStateMachine.appState = CAPTURING;
            isUseButtonClicked = NO;
        }
    });
}

#pragma mark Image Processor Delegate Methods

-(void)processingSucceeded:(BOOL)status withOutputImage:(kfxKEDImage*)processedImage{
    
    if(status){
        
        appStateMachine.appState = PROCESSED;
        
        self.capturedImage_Processed = processedImage;
        
        if (processedImage.imageFileOutputColor == KED_BITDEPTH_BITONAL)
        {
            self.capturedImage_Processed.imageMimeType = MIMETYPE_TIF;
            
        } else {
            self.capturedImage_Processed.imageMimeType = MIMETYPE_JPG;
        }
        
        if(self.isUseButtonClicked){
            
            [self extractData:self.capturedImage_Processed];
            
        }
        
        
    }else{
        [AppUtilities removeActivityIndicator];
        appStateMachine.appState = CAPTURED;
    }}

-(void)quickAnalysisResponse:(kfxKEDQuickAnalysisFeedback *)feedback{
    [AppUtilities removeActivityIndicator];
    if (feedback) {
        NSLog(@"feedback : %d, %d, %d", feedback.isBlurry, feedback.isOverSaturated, feedback.isUnderSaturated);
        
        NSString *blurFeedback=@"";
        NSString *overSaturatedFeedback=@"";
        NSString *underSaturatedFeedback=@"";
        
        
        if(feedback.isBlurry) {
            blurFeedback=Klm(@"blurred");
        }
        if(feedback.isOverSaturated)
        {
            if(feedback.isBlurry)
                overSaturatedFeedback = Klm(@"and over-saturated");
            else
                overSaturatedFeedback = Klm(@"over-saturated");
        }
        
        if(feedback.isUnderSaturated)
        {
            if(feedback.isBlurry)
                underSaturatedFeedback = Klm(@"and under saturated");
            else
                underSaturatedFeedback = Klm(@"under saturated");
        }
        NSString *quickFeedback = [NSString stringWithFormat:@"%@ %@ %@ %@", Klm(@"The captured image is"), blurFeedback, overSaturatedFeedback, underSaturatedFeedback];
        NSLog(@"The captured image is %@ %@ %@", blurFeedback, overSaturatedFeedback, underSaturatedFeedback);
        if(feedback.isBlurry || feedback.isOverSaturated || feedback.isUnderSaturated){
            [self performSelectorOnMainThread:@selector(addQuickAnalysisALert:) withObject:quickFeedback waitUntilDone:YES];
        }
//        if (![AppUtilities isLowerEndDevice]) {
//            [self processCapturedImage];
//        }
        
        
    }else{
        appStateMachine.appState = CAPTURED;
    }
}


#pragma mark Data Extraction Method

-(void)extractData:(kfxKEDImage*)processedImage{
   
    extractionError = nil;
    extractedStatusCode = 0;
    appStateMachine.appState = EXTRRACTING;
    NSString *serverUrl = [NSString stringWithFormat:@"%@",[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL]];
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    

    
    if (!extractionManager)
        extractionManager = [[ExtractionManager alloc] init];
    
    extractionManager.delegate = self;
    
    
    
    if ([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]) {
        
        //Sending for extraction if server type is KTA
        self.extractionManager.serverType = KTA;
        
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPROCESSNAME] forKey:PROCESS_IDENTITY_NAME];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAIDTYPE] forKey:PROCESS_ID_TYPE];
        [parameters setValue:@"" forKey:DOCUMENT_NAME];
        [parameters setValue:@"" forKey:DOCUMENT_GROUP_NAME];
        
        //We need to send login credentials to the server if the server type is KTA.
        NSString *serverUrl = [NSString stringWithFormat:@"%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]];
        
        [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAUSERNAME] forKey:USERNAME];
        [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPASSWORD] forKey:PASSWORD];
        
     [extractionManager extractImagesDataWithProcessNameSync:[[NSMutableArray alloc]initWithObjects:processedImage, nil]saveOriginalImages:nil withURL:[NSURL URLWithString:serverUrl] withParams:parameters withMimeType:processedImage.imageMimeType];
        
        
        
    }else{
        
        NSArray *arrDivideURL = [serverUrl componentsSeparatedByString:@"?"];
        if(arrDivideURL.count>1){
            
            serverUrl = [arrDivideURL objectAtIndex:0];
            NSString *strClass = [arrDivideURL objectAtIndex:1];
            NSArray *arrClass = [strClass componentsSeparatedByString:@"="];
            if(arrClass.count>1)
                [parameters setValue:[arrClass objectAtIndex:1] forKey:[arrClass objectAtIndex:0]];
        }
      
        
        if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue])
            [parameters setValue:[NSString stringWithFormat:@"%d",1] forKey:@"ProcessCount"];
        
        if (sessionKey != nil)
        {
            [parameters setValue:sessionKey forKey:@"SessionKey"];
        }
        
        // Adding IP Profile specific to passport when processing at device side is off
        if (![[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS]valueForKey:DOPROCESS] boolValue]) {
            [parameters setValue:PASSPORT_PROFILE forKey:IP_PROFILE];
        }

        //Sending for extraction if server type is RTTI
        self.extractionManager.serverType = RTTI;
        NSString *serverUrl = [NSString stringWithFormat:@"%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL]];
        
         [extractionManager extractImagesData:[[NSMutableArray alloc]initWithObjects:processedImage, nil]saveOriginalImages:[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH]boolValue]?[[NSMutableArray alloc]initWithObjects:capturedImage_Raw, nil]:nil withURL:[NSURL URLWithString:serverUrl] withParams:parameters withMimeType:processedImage.imageMimeType];
    }
    
    
   
    
    parameters = nil;
}

#pragma mark RTTI Manager Delegate Methods

-(void)extractionSucceeded:(NSInteger)statusCode withResults:(NSData *)results{
    
    appStateMachine.appState = EXTRACTED;
    self.extractedStatusCode = statusCode;
    
    if (statusCode==REQUEST_SUCCESS) {
        //[self storeImages];
        extractionError = nil;
        NSDictionary *result;
        NSArray *arrresponse;
        
        id response = [NSJSONSerialization JSONObjectWithData:results options:NSJSONReadingAllowFragments error:nil];
        
        if([response isKindOfClass:[NSDictionary class]]) {
            
            arrresponse = [NSArray arrayWithObject:(NSDictionary *)response];
        }
        else {
            
            arrresponse = (NSArray *)response;
        }
        
        if(arrresponse.count>0)
                result=[response objectAtIndex:0];
        
        processedResults = [[result valueForKey:STATICSERVERFIELDS] mutableCopy];
        

        [self fillColorAreasArray];
        
        if (isUseButtonClicked) {
            [AppUtilities removeActivityIndicator];
            [self showSummaryScreen:processedResults withImage:self.capturedImage_Processed andAnimation:YES];
        }
    }else{
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
        extractionError = [NSError errorWithDomain:[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL] code:statusCode userInfo:userInfo];
        if (isUseButtonClicked) {
            [AppUtilities removeActivityIndicator];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Couldn’t read the Document." delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            alertView.tag = EXTRACTION_FAILED_TAG;
            [alertView show];
        }
    }
}

-(void)extractionFailedWithError:(NSError *)error responseCode:(NSInteger)responseCode
{
    appStateMachine.appState = EXTRACTED;
    extractionError = error;
    NSString *errorMessage;
    
    if(responseCode == REQUEST_FAILURE)
    {
        errorMessage = Klm(@"Could not read the document.");
    }
    else if (extractionError.code == REQUEST_TIMEDOUT) {
        errorMessage = Klm(@"The Request timed out.");
    }else if(extractionError.code == NONETWORK){
        errorMessage = Klm(@"Document extraction cannot be performed because the app cannot connect to the network.");
    }else if (extractionError.code > 0){
        
        errorMessage = [kfxError findErrMsg:extractionError.code];
        
    }else{
         errorMessage = Klm([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?@"The KTA server may be offline or does not exist.":@"The RTTI server may be offline or does not exist.");
    }
    if (isUseButtonClicked) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [AppUtilities removeActivityIndicator];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:errorMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            alert.tag = EXTRACTION_FAILED_TAG;
            [alert show];
                           
        });

    }
}

#pragma mark Summary Screen
-(void)showSummaryScreen:(NSArray*)results withImage:(kfxKEDImage*)image andAnimation:(BOOL)animation{
    
    CustomComponentSummaryViewController *ccSummary;
    
    if([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
        
        ccSummary = [[CustomComponentSummaryViewController alloc] initWithComponent:componentObject kedImage:image andRawImage:animation?capturedImage_Raw:nil andResults:results];
    }
    else {
        
        ccSummary = [[CustomComponentSummaryViewController alloc] initWithComponent:componentObject kedImage:image andRawImage:nil andResults:results];
    }
    ccSummary.extractedError = extractionError;
    ccSummary.delegate = self;
    [navigationController pushViewController:ccSummary animated:animation];
}

#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==111) {
        capturedImage_Raw = nil;
        self.capturedImage_Processed = nil;
        [appStateMachine cleanUpDisk];
        [navigationController popToRootViewControllerAnimated:YES];
    }else if(alertView.tag==222){
        if (buttonIndex==0) {
            [self retakeButtonClicked];
        }else if(buttonIndex==1){
            [self useButtonClicked];
        }
    }else if(alertView.tag==333){
        if (buttonIndex==0) {
            capturedImage_Raw = nil;
            self.capturedImage_Processed = nil;
            [appStateMachine cleanUpDisk];
            [navigationController popToRootViewControllerAnimated:NO];
        }
    }else if(alertView.tag == EXTRACTION_FAILED_TAG){
        [self showSummaryScreen:nil withImage:self.capturedImage_Processed andAnimation:YES];
    }
}

#pragma mark Bill Pay Summary Delegate Method

-(void)summarySubmitButtonClicked{
    // do any clean up
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:Klm([componentObject.texts.summaryText valueForKey:SUBMITALERTTEXT]) delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
    alert.tag = 111;
    [alert show];
}

-(void)summarySettingsButtonClicked{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [navigationController pushViewController:componentSettingsController animated:YES];
}

-(void)summaryPreviewButtonClicked:(NSMutableArray*)results{
    
    _fromImageSelectedMethod = NO;
    ExhibitorViewController *exhibitorController = nil;
    CaptureViewController *captureController = nil;
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[ExhibitorViewController class]]) {
            
            exhibitorController = (ExhibitorViewController*)aViewController;
            exhibitorController.inputImage = self.self.capturedImage_Processed;
            isFromPreview = YES;
            exhibitorController.isCancelButtonShow = YES;
            [exhibitorController removeNavigationBarItems];
            exhibitorController.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:CANCELBUTTON]);
            exhibitorController.leftButtonTitle = Klm([componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
            
            if (exhibitorController.leftButtonTitle.length==0)
                exhibitorController.leftButtonTitle = Klm(@"Retake");
            
            if (exhibitorController.rightButtonTitle.length == 0)
                exhibitorController.rightButtonTitle = Klm(@"Cancel");
            
        }else if ([aViewController isKindOfClass:[CaptureViewController class]]) {
            captureController = (CaptureViewController*)aViewController;
        }
    }
    [self updateCameraSettings:captureController.settings];
    self.backupResults = results;
    
    if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTSWITCH] boolValue])
    {
        
        if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTDATA] boolValue]){
            
            if((![[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:USEBANKRIGHTSETTINGS] boolValue] &&
                [[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:AUTOROTATE] boolValue]) ||
               ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:USEBANKRIGHTSETTINGS] boolValue])){
                
                if(self.coloredAreas && [self.coloredAreas count] > 0){
                    [exhibitorController setColoredAreas:self.coloredAreas];
                }
            }
            else{
                [exhibitorController setColoredAreas:nil];
            }
        }
        else{
            [exhibitorController setColoredAreas:nil];
        }
    }

    
    [navigationController popViewControllerAnimated:NO];
}

-(void)summaryCancelButtonClicked{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm([componentObject.texts.summaryText valueForKey:SUBMITCANCELALERTTEXT]) delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Yes"), Klm(@"No"), nil ];
    alert.tag = 333;
    [alert show];
}


-(void)addQuickAnalysisALert:(NSString*)quickFeedback
{
    UIAlertView * quickAlert = [[UIAlertView alloc] initWithTitle:Klm(@"Quick Analysis Feedback") message:quickFeedback delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Retake"), Klm(@"Use"), nil ];
    quickAlert.tag = 222;
    [quickAlert show];
    
}

-(void)updateCameraSettings:(CaptureSettings*)captureSettings{
    captureSettings.useVideoFrame = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTURETYPE ] boolValue];
    if ([[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTURETYPE ] boolValue]) {
        captureSettings.showFlashOptions = NO;
    }else{
        captureSettings.showFlashOptions = YES;
    }
    captureSettings.hideCaptureButton = NO;
    captureSettings.captureExperience = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE ] intValue];
    
    captureSettings.showAutoTorch = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:AUTOTORCH ] boolValue];

    captureSettings.showGallery = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
        
    captureSettings.moveCloserMessage = Klm([componentObject.texts.cameraText valueForKey:MOVECLOSER]);
    captureSettings.holdSteadyMessage = Klm([componentObject.texts.cameraText valueForKey:HOLDSTEADY]);
    captureSettings.cancelButtonText = Klm([componentObject.texts.cameraText valueForKey:CANCELBUTTON]);
    captureSettings.userInstruction = Klm([componentObject.texts.cameraText valueForKey:USERINSTRUCTIONFRONT]);
    captureSettings.centerMessage = Klm([componentObject.texts.cameraText valueForKey:CENTERMESSAGE]);
    captureSettings.zoomOutMessage = Klm([componentObject.texts.cameraText valueForKey:ZOOMOUTMESSAGE]);
    captureSettings.capturedMessage = Klm([componentObject.texts.cameraText valueForKey:CAPTUREDMESSAGE]);
    captureSettings.holdParallelMessage = Klm([componentObject.texts.cameraText valueForKey:HOLDPARALLEL]);
    captureSettings.orientationMessage = Klm([componentObject.texts.cameraText valueForKey:ORIENTATION]);
    
    captureSettings.zoomMinFillFraction = 0.65;
    captureSettings.zoomMaxFillFraction = 1.5;
    

    if (captureSettings.cancelButtonText.length == 0)
        captureSettings.cancelButtonText =Klm(@"Cancel");
    
    captureSettings.manualCaptureTime = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
    captureSettings.edgeDetection = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:EDGEDETECTION]intValue];

    captureSettings.centerShiftValue = 0;
    
    captureSettings.doContinuousCapture = YES;
    captureSettings.staticFramePaddingPercent = 0;
    
     if ([[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE]intValue] == 0){
        captureSettings.stabilityThresholdEnabled = YES;
        captureSettings.rollThresholdEnabled = YES;
        captureSettings.pitchThresholdEnabled = YES;
        captureSettings.focusConstraintEnabled = YES;
        
        captureSettings.stabilityThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:STABILITYDELAY]intValue];
        captureSettings.rollThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:ROLLTHRESHOLD]intValue];
        captureSettings.pitchThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:PITCHTHRESHOLD]intValue];
        
        captureSettings.longAxisThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]intValue];
        captureSettings.shortAxisThreshold = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]intValue];

        float aspectRatio = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS] valueForKey:FRAMEASPECTRATIO] floatValue];
        
        if(aspectRatio <= 0){
            captureSettings.staticFrameAspectRatio = 0;
            captureSettings.hideStaticFrame = true;
        }
        else{
            captureSettings.staticFrameAspectRatio = aspectRatio;
        }
        
        
    }
    appStateMachine.appState = CAPTURING;
}

-(void)storeImages{
    
    if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS]valueForKey:MODE] integerValue] == 0){
        
        [appStateMachine storeImage:self.capturedImage_Processed withType:FRONT_PROCESSED mimeType:MIMETYPE_TIF];

    }
    else {
        
        [appStateMachine storeImage:self.capturedImage_Processed withType:FRONT_PROCESSED mimeType:MIMETYPE_JPG];

    }
}

-(void)fillColorAreasArray{
    
    if(!processedResults || [processedResults count] == 0){
        return;
    }
    self.coloredAreas = [AppUtilities getRectDictsFromResults:processedResults];
}

@end
