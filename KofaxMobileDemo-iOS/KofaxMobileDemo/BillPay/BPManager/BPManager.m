//
//  BPManager.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BPManager.h"

#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibLogistics/kfxLogistics.h>
#import <kfxLibUtilities/kfxUtilities.h>
#import "BPInstructionsViewController.h"

#import "PersistenceManager.h"

#import "CaptureViewController.h"
#import "ExhibitorViewController.h"
#import "ComponentSettingsViewController.h"
#import "ImageProcessor.h"
#import "ExtractionManager.h"

#import "BPSummaryViewController.h"

#import "AppStateMachine.h"
#import "BPCountryViewController.h"

static BPManager *billPayManager = nil;
static NSString * sessionKey = nil;

@interface BPManager ()<BPCountryProtocol,BPInstructionsProtocol,CaptureViewControllerProtocol,ExhibitorProtocol,ImageProcessorProtocol,ExtractionManagerProtocol,BPSummaryProtocol,UIAlertViewDelegate>
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
@property (nonatomic,strong)NSMutableArray *coloredAreas;

@property (nonatomic,strong) NSString *xCountry;
@end

@implementation BPManager
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
#pragma mark Exposed Methods

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

-(void)loadBillPayManager:(UINavigationController*)appNavController andComponent:(Component*)currentComponent{
    
    //Configuring App's State
    appStateMachine = [AppStateMachine sharedInstance];
    
    appStateMachine.isFront = YES;
    appStateMachine.module = BILL_PAY;
    appStateMachine.appState = NOOP;
    navigationController = appNavController;
    componentObject = currentComponent;
    
    self.xCountry = [[NSString alloc] init];
    
//    [self showCountriesList:navigationController];
    [self countryForBPSelected:@""];
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    sessionKey = [[NSUUID UUID] UUIDString];
    
    [stats beginSession: sessionKey withCategory:@"BillPay"];
}

-(void)unloadBillPayManager
{
    [self clearProcessedImage];
    [self clearRawImage];
    
    self.appStateMachine = nil;
    self.imageProcessor.delegate = nil;
    self.imageProcessor = nil;
    self.extractionManager.delegate = nil;
    self.extractionManager = nil;
    self.processedResults = nil;
    self.backupResults = nil;
    self.extractionError = nil;
    self.xCountry = nil;
    
    [self.appStateMachine cleanUpDisk];
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    
    [stats endSession:TRUE withDescription:@"Complete"];
    sessionKey = nil;
}
#pragma mark BillPay Countries List

-(void)showCountriesList:(UINavigationController*)appNavController{
    
    BPCountryViewController *bpCountrySelectionVC = [[BPCountryViewController alloc] init];
    bpCountrySelectionVC.delegate = self;
    [appNavController pushViewController:bpCountrySelectionVC animated:YES];

}

#pragma mark BillPay Countries List Delegate methods

-(void)countryForBPSelected : (NSString*)bpCountry{
    
    self.xCountry = bpCountry;
    [self showInstructions:navigationController];
}
-(void)countrySelectionCancelled{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)countrySettingsClicked{
 
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:self.componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [self.navigationController pushViewController:componentSettingsController animated:YES];

}


#pragma mark Load BillPay instructions

-(void)showInstructions:(UINavigationController*)appNavController{
    
    BPInstructionsViewController *billPayInsVC = [[BPInstructionsViewController alloc] initWithComponent:componentObject];
    billPayInsVC.delegate = self;
    [appNavController pushViewController:billPayInsVC animated:YES];
}

#pragma mark BillPay Instructions Delegate Methods

-(void)instructionContinueButtonClicked{
    
    [self showCamera];
    isFromPreview = NO;
}
-(void)instructionsBackButtonClicked{
    [navigationController popViewControllerAnimated:YES];
}
-(void)instructionSettingsButtonClicked{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [navigationController pushViewController:componentSettingsController animated:YES];
}

#pragma mark Camera methods

-(void)showCamera{
    CaptureSettings* captureSettings = [[CaptureSettings alloc] init];
    captureSettings.showGallery = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
    captureSettings.useVideoFrame = false; // This is not configurable from Settings , by default it is false.
    captureSettings.showFlashOptions = YES;
    captureSettings.showAutoTorch = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:AUTOTORCH ] boolValue];
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
    
    captureSettings.zoomMinFillFraction = 0.4;
    captureSettings.zoomMaxFillFraction = 1.3;
    
    if (captureSettings.cancelButtonText.length == 0)
        captureSettings.cancelButtonText = Klm(@"Cancel");
    
    
    captureSettings.manualCaptureTime = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
    captureSettings.edgeDetection = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:EDGEDETECTION]intValue];
    captureSettings.doShowGuidingDemo = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue];

    
    captureSettings.centerShiftValue = 0;
    
    captureSettings.doContinuousCapture = YES;
    captureSettings.staticFramePaddingPercent = 6;
    
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

        captureSettings.hideStaticFrame = false; // This is not configurable from Settings , So it should be shown always .
    }
    
    appStateMachine.appState = CAPTURING;
    
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

// Processes the image with given settings
- (void)processImageBasedOnSettingsWithImage:(kfxKEDImage*)image{
    capturedImage_Raw = image;
    appStateMachine.appState = CAPTURED;
    isUseButtonClicked = NO;
    if ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS ] valueForKey:DOQUICKANALYSIS]boolValue]) {
        [AppUtilities addActivityIndicator];
        if (!imageProcessor)
            imageProcessor = [[ImageProcessor alloc] init];
        imageProcessor.delegate = self;
        [imageProcessor performQuickAnalysisOnImage:image];
    }else{
        if(![AppUtilities isLowerEndDevice])
            [self processCapturedImage];
    }
    [self showPreview:image];
}


-(void)cancelCamera{
    
    if(appStateMachine.appState == PROCESSING){
        
        return;
    }
    
    if (isRetakeImage) {
        ExhibitorViewController *exhibitorObj = [[ExhibitorViewController alloc]initWithNibName:EXHIBITORVIEWCONTROLLER bundle:nil];
        exhibitorObj.inputImage = [appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
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
        [navigationController popViewControllerAnimated:YES];
        
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
        exhibitorObj.rightButtonTitle = @"";
        
    }
    
    
    
    [navigationController pushViewController:exhibitorObj animated:YES];
    
}

#pragma mark Exhibitor Delegate Methods

-(void) useSelectedPhotoButtonClicked
{
    [self useButtonClicked];
    
}
-(void) albumButtonClicked
{
    // handle the album button action
    [self retakeButtonClicked];
    
}
-(void)useButtonClicked{
    if ([AppUtilities isConnectedToNetwork]) {
        isUseButtonClicked = YES;
        [AppUtilities addActivityIndicator];
        
        NSLog(@"App state is %d and status code is %ld", appStateMachine.appState, (long)extractedStatusCode);
        if (appStateMachine.appState == EXTRACTED) {
            
            if (extractedStatusCode==200) {
                [self storeImages];
                [AppUtilities removeActivityIndicator];
                [self fillColorAreasArray];
                [self showSummaryScreen:processedResults withImage:capturedImage_Processed andAnimation:YES];
            }else if(extractionError.code == -1009 || self.extractedStatusCode == 0){
                [self extractData:capturedImage_Processed];
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
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Couldn’t read the bill") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                alertView.tag = EXTRACTION_FAILED_TAG;
                [alertView show];
            }
        }else if(appStateMachine.appState == PROCESSED){
            [self extractData:capturedImage_Processed];
        }else if(appStateMachine.appState == CAPTURED){
            [self processCapturedImage];
        }
    }else{
        UIAlertView* networkError = [[UIAlertView alloc] initWithTitle:Klm(@"Network Alert!!") message:Klm(@"Bill extraction cannot be performed because the app cannot connect to the network.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
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
    [self showSummaryScreen:self.backupResults withImage:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] andAnimation:NO];
}

-(kfxKEDImagePerfectionProfile*)getProcessingProfile{
    
    kfxKEDImagePerfectionProfile * kPerfectionProf=nil;
    NSString * opStr = [AppUtilities getEVRSImagePerfectionStringFromSettings:[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] ofComponentType:BILLPAY isFront:appStateMachine.isFront withScaleSize:CGSizeZero withFrontImageWidth:nil];
    
    kPerfectionProf = [[kfxKEDImagePerfectionProfile alloc]initWithName:STATICPERFECTIONPROFILE andOperations:opStr];
    
    return kPerfectionProf;
}


#pragma mark Processor methods

-(void)processCapturedImage{
    
    if (!imageProcessor)
        imageProcessor = [[ImageProcessor alloc] init];
    imageProcessor.delegate = self;
    capturedImage_Raw.imageMimeType = MIMETYPE_TIF;
    [imageProcessor processImage:capturedImage_Raw withProfile:[self getProcessingProfile]];
    
    appStateMachine.appState = PROCESSING;
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
        capturedImage_Processed = processedImage;
        capturedImage_Processed.imageMimeType = MIMETYPE_TIF;
        if(isUseButtonClicked){
            [self extractData:processedImage];
        }
        
    }else{
        [AppUtilities removeActivityIndicator];
        appStateMachine.appState = CAPTURED;
    }
}


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
        //        if(![AppUtilities isLowerEndDevice])
        //            [self processCapturedImage];
    }else{
        appStateMachine.appState = CAPTURED;
    }
}

#pragma mark Data Extraction Method

-(void)extractData:(kfxKEDImage*)processedImage {
    
    //if ([AppUtilities isConnectedToNetwork]) {
    extractionError = nil;
    extractedStatusCode = 0;
    appStateMachine.appState = EXTRRACTING;
    
    if (!extractionManager)
        extractionManager = [[ExtractionManager alloc] init];
    
    extractionManager.delegate = self;
    
    NSMutableArray *arrProcessed = [[NSMutableArray alloc]init];
    if(processedImage){
        [arrProcessed addObject:processedImage];
    }
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
   
    
    if(self.xCountry && ![self.xCountry isEqualToString:@""]){
        [parameters setValue:self.xCountry forKey:@"xcountry"];
    }
    
    if ([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]) {
        
        //Sending for extraction if server type is KTA
        extractionManager.serverType = KTA;
        
        //We need to send login credentials to the server if the server type is KTA.
        NSString *serverUrl = [NSString stringWithFormat:@"%@",[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPROCESSNAME] forKey:PROCESS_IDENTITY_NAME];
        [parameters setValue:@"" forKey:DOCUMENT_NAME];
        [parameters setValue:@"" forKey:DOCUMENT_GROUP_NAME];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAUSERNAME] forKey:USERNAME];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPASSWORD] forKey:PASSWORD];
        
        [extractionManager extractImagesData:[[NSMutableArray alloc]initWithObjects:processedImage, nil] saveOriginalImages:nil withURL:[NSURL URLWithString:serverUrl] withParams:([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue]||[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE] boolValue])?parameters:nil withMimeType:MIMETYPE_TIF];
    }else{
        
        if ([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH]boolValue])
        {
            [parameters setValue:@"1" forKey:@"ProcessCount"];
        }
        
        if (sessionKey != nil)
        {
            
            [parameters setValue:sessionKey forKey:@"SessionKey"];
            
        }
        
        //Sending for extraction if server type is RTTI
        extractionManager.serverType = RTTI;
        NSString *serverUrl = [NSString stringWithFormat:@"%@",[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL]];
        [extractionManager extractImagesData:[[NSMutableArray alloc]initWithObjects:processedImage, nil] saveOriginalImages:[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH]boolValue]?[[NSMutableArray alloc]initWithObjects:capturedImage_Raw, nil]:nil withURL:[NSURL URLWithString:serverUrl] withParams:parameters withMimeType:MIMETYPE_TIF];
    }
    
    parameters = nil;
}

#pragma mark RTTI Manager Delegate Methods

-(void)extractionSucceeded:(NSInteger)statusCode withResults:(NSData *)resultsData{
    appStateMachine.appState = EXTRACTED;
    self.extractedStatusCode = statusCode;
    
    if (statusCode==REQUEST_SUCCESS) {
        extractionError = nil;
        //[self storeImages];
        [self parseResponseData:resultsData];
        
        if (isUseButtonClicked) {
            [self fillColorAreasArray];

            [self storeImages];
            [AppUtilities removeActivityIndicator];
            [self showSummaryScreen:processedResults withImage:capturedImage_Processed andAnimation:YES];
        }
    }else{
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
        extractionError = [NSError errorWithDomain:[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL] code:statusCode userInfo:userInfo];
        if (isUseButtonClicked) {
            [AppUtilities removeActivityIndicator];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Couldn’t read the bill") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
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
        errorMessage = Klm(@"Bill extraction cannot be performed because the app cannot connect to the network.");
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
            
            //Taking user to summary screen even extraction fails and checks send summary is on/off.
           
            [self storeImages]; //Need to store image in file to show in preview screen.
            
        });

    
    }
}

#pragma mark--Parse Methods

-(void)parseResponseData:(NSData *)resultsData{
    
    NSArray *arrresponse;
    
    NSDictionary *result;
    
    id response = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingAllowFragments error:nil];
    
    if([response isKindOfClass:[NSDictionary class]]) {
        
        arrresponse = [NSArray arrayWithObject:(NSDictionary *)response];
    }
    else {
        
        arrresponse = (NSArray *)response;
    }
    
    if(arrresponse.count>0)
        result=[response objectAtIndex:0];
    
    processedResults = [[result valueForKey:STATICSERVERFIELDS] mutableCopy];
    
    NSLog(@"The processed results are %@",processedResults);
    
    
}

#pragma mark Summary Screen
-(void)showSummaryScreen:(NSArray*)results withImage:(kfxKEDImage*)image andAnimation:(BOOL)animation{
    
    BPSummaryViewController *billPaySummary;
    
    if([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
        
        billPaySummary = [[BPSummaryViewController alloc] initWithComponent:componentObject kedImage:image andRawImage:animation?capturedImage_Raw:nil andResults:results];
    }
    else {
        
        billPaySummary = [[BPSummaryViewController alloc] initWithComponent:componentObject kedImage:image andRawImage:nil andResults:results];
    }
    billPaySummary.extractedError = extractionError?extractionError:nil;
    billPaySummary.delegate = self;
    [navigationController pushViewController:billPaySummary animated:animation];
}

#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==111) {
        
        [self clearRawImage];
        [self clearProcessedImage];
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
            BPSummaryViewController *summaryController = (BPSummaryViewController*)navigationController.topViewController;
            summaryController.backButtonClicked = YES;
            [self clearProcessedImage];
            [self clearRawImage];
            [appStateMachine cleanUpDisk];
            [navigationController popToRootViewControllerAnimated:NO];
        }
    }else if(alertView.tag == EXTRACTION_FAILED_TAG){
        [self showSummaryScreen:nil withImage:capturedImage_Processed andAnimation:YES];
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
            exhibitorController.inputImage = [appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
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
    
   captureSettings.useVideoFrame = false; // This is not configurable from Settings , by default it is false.
    captureSettings.showFlashOptions = YES;
    captureSettings.showGallery = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
    captureSettings.showAutoTorch = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:AUTOTORCH ] boolValue];
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

    
    if (captureSettings.cancelButtonText.length == 0)
        captureSettings.cancelButtonText = Klm(@"Cancel");
    
    captureSettings.manualCaptureTime = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
    captureSettings.edgeDetection = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:EDGEDETECTION]intValue];
    
    captureSettings.zoomMinFillFraction = 0.4;
    captureSettings.zoomMaxFillFraction = 1.3;
    
    
    captureSettings.centerShiftValue = 0;
    
    captureSettings.doContinuousCapture = YES;
    captureSettings.staticFramePaddingPercent = 6;
    
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

    }
    
    appStateMachine.appState = CAPTURING;
}

-(void)clearRawImage {
    
    if(self.capturedImage_Raw) {
        
        [self.capturedImage_Raw clearImageBitmap];
        self.capturedImage_Raw = nil;
    }
}

-(void)clearProcessedImage {
    
    if(self.capturedImage_Processed) {
        
        [self.capturedImage_Processed clearImageBitmap];
        self.capturedImage_Processed = nil;
    }
    
}

-(void)storeImages{
    
    [appStateMachine storeImage:capturedImage_Processed withType:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
}

-(void)fillColorAreasArray{
    
    if(!processedResults || [processedResults count] == 0){
        return;
    }
    self.coloredAreas = [AppUtilities getRectDictsFromResults:processedResults];
}


@end
