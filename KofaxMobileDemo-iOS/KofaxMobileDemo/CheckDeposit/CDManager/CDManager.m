//
//  BillPayManager.m
//  BankRight
//
//  Created by kaushik on 02/07/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibLogistics/kfxLogistics.h>
#import <kfxLibUtilities/kfxUtilities.h>

#import "CDManager.h"

#import "CDCountryViewController.h"
#import "CaptureViewController.h"
#import "ExhibitorViewController.h"
#import "ImageProcessor.h"
#import "ExtractionManager.h"
#import "ComponentSettingsViewController.h"

#import "PersistenceManager.h"


#import "AppStateMachine.h"

#import "CDInstructionsViewController.h"

#import "CaptureSettings.h"


#import "CheckHistoryManager.h"
#import "ChecksHistory.h"
#import "CheckHistoryViewController.h"

#define AlertTagAmountMismatch 9
#define AlertTagAmountInMICR 9090
#define AlertTagCheckRejectReason 8088

typedef enum RotateCheckBack{
    ROTATE_NOT_STARTED = 0,
    ROTATE_STARTED ,
    ROTATE_IN_PROGRESS,
    ROTATE_COMPLETED
}ROTATECHECKBACKSTATES;

typedef enum appStateValForCD{
    CDNOOP = 10,
    CDCAPTURING,
    CDCAPTURED,
    CDPROCESSING,
    CDPROCESSED,
    CDCANCELLING,
    CDCANCELLED,
    CDEXTRRACTING,
    CDEXTRACTED,
    CDFAILED,
    CDPROCESSING_USECLICKED,
    CDREPROCESSING
}appStateValCD;

static NSString * sessionKey = nil;

@interface CDManager ()<CDCountryProtocol,CaptureViewControllerProtocol,ExhibitorProtocol,ImageProcessorProtocol,ExtractionManagerProtocol,CDInstructionsProtocol>{
    
    UINavigationController *navigationController;
    AppStateMachine *appStateMachine;
    ImageProcessor *imageProcessor;
    ExtractionManager *extractionManager;
    CDInstructionsViewController *checkDepositInsVC;
    Component *componentObject;
    NSMutableArray *processedResults;
    NSDictionary *advancedSettings;
    NSMutableArray *coloredAreas; // array which has array of rectangles
}

@property (assign) BOOL fromImageCapturedMethod;
@property (assign) BOOL fromImageSelectedMethod;

@property (assign) BOOL frontCheckProcessed;
@property (assign) BOOL backCheckProcessed;

@property (assign) BOOL isFrontDemoShownForFirstTime;
@property (assign) BOOL isBackDemoShownForFirstTime;

@property (nonatomic,strong) NSString *localMICR;

@property (assign) NSInteger returnCode;
@property (nonatomic,strong) NSString *extractionFailedMessage;

@property (nonatomic,strong) kfxKEDImage *currentCapturedImage;
@property (nonatomic,strong) kfxKEDImage *currentProcessedImage;

@property (nonatomic,assign)BOOL showAmountInMicrAlert;
@property (nonatomic,assign)BOOL isFront;

@property (nonatomic,assign)appStateValCD appStateCD;

@property (nonatomic,strong) NSString *xCountry;
@property (nonatomic, strong) NSString *countryCode;

@end


@implementation CDManager


#pragma mark
#pragma mark Exposed Methods

// initialise CDManager's default values
-(void)loadCheckDepositManager:(UINavigationController*)appNavController andComponent:(Component*)currentComponent{
    
    //Configuring App's State
    appStateMachine = [AppStateMachine sharedInstance];
    self.isFront = NO;
    
    appStateMachine.module = CHECK_DEPOSIT;
    self.appStateCD = CDNOOP;
    
    appStateMachine.front_processed = nil;
    appStateMachine.back_processed = nil;
    
    _frontCheckProcessed = NO;
    _backCheckProcessed = NO;
    
    _fromImageCapturedMethod = NO;
    _fromImageSelectedMethod = NO;
    _showAmountInMicrAlert = NO;
    
    self.isFrontDemoShownForFirstTime = YES;
    self.isBackDemoShownForFirstTime = YES;
    
    
    navigationController = appNavController;
    componentObject = currentComponent;
    
    advancedSettings = [componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS];
    
    self.xCountry = [[NSString alloc] init];
    
    [self showCountriesList:navigationController];
    
    
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    sessionKey = [[NSUUID UUID] UUIDString];
    
    [stats beginSession: sessionKey withCategory:@"CheckDeposit"];
}


// releasing the allocated memory
-(void)unloadCheckDepositManager{
    
    // do any clean up
    self.isFront = NO;
    
    //[navigationController popToRootViewControllerAnimated:YES];
    
    if (_currentCapturedImage) {
        [_currentCapturedImage clearImageBitmap];
        _currentCapturedImage = nil;
    }
    
    if (_currentProcessedImage) {
        [_currentProcessedImage clearImageBitmap];
        _currentProcessedImage = nil;
    }
    
    if (appStateMachine.front_processed) {
        [appStateMachine.front_processed clearImageBitmap];
        appStateMachine.front_processed = nil;
    }
    
    if (appStateMachine.back_processed) {
        [appStateMachine.back_processed clearImageBitmap];
        appStateMachine.back_processed = nil;
    }
    
    self.localMICR = nil;
    self.extractionFailedMessage = nil;
    
    checkDepositInsVC = nil;
    componentObject = nil;
    imageProcessor = nil;
    
    processedResults = nil;
    advancedSettings = nil;
    
    extractionManager.delegate = nil;
    extractionManager = nil;
    imageProcessor.delegate = nil;
    imageProcessor = nil;
    
    self.xCountry = nil;
    
    [appStateMachine cleanUpDisk];
    
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    
    [stats endSession:TRUE withDescription:@"Complete"];

    
}

#pragma mark
#pragma mark Check Deposit Countries List

-(void)showCountriesList:(UINavigationController*)appNavController{
    
    CDCountryViewController *cdCountrySelectionVC = [[CDCountryViewController alloc] init];
    cdCountrySelectionVC.delegate = self;
    [appNavController pushViewController:cdCountrySelectionVC animated:YES];
    
}

#pragma mark
#pragma mark Check Deposit Countries List Delegate methods

-(void)countryForCDSelected : (NSString*)cdCountry{
    
    if ([cdCountry isEqualToString:@"US"]) {
        self.countryCode = @"en_US";
    }
    else if ([cdCountry isEqualToString:@"CA"]) {
        self.countryCode = @"en_CA";
    }
    else if ([cdCountry isEqualToString:@"SG"]) {
        self.countryCode = @"en_SG";
    }
    else if ([cdCountry isEqualToString:@"HK"]) {
        self.countryCode = @"en_HK";
    }
    else if ([cdCountry isEqualToString:@"AU"]) {
        self.countryCode = @"en_AU";
    }
    else if ([cdCountry isEqualToString:@"UK"]) {
        self.countryCode = @"en_GB";
    }
  
    self.xCountry = cdCountry;
    [self showInstructions:navigationController];
}
-(void)countrySelectionCancelled{
    
    [navigationController popViewControllerAnimated:YES];
}
-(void)countrySettingsClicked{
    
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [navigationController pushViewController:componentSettingsController animated:YES];
}

#pragma mark Check Front Width


// This method calculates the check front width
-(NSString *)calculateTheCheckFrontWidth:(kfxKEDImage *)frontProcessed {
    
    NSString *strCheckFrontWidth = @"";
    
    if(frontProcessed!=nil && frontProcessed.imageDPI != 0){
        
        float width = (float)frontProcessed.imageWidth /(float)frontProcessed.imageDPI;
        return strCheckFrontWidth = [NSString stringWithFormat:@"%f",width];
    }
    
    return strCheckFrontWidth;
    
}


#pragma mark
#pragma mark Show Check Deposit instructions

-(void)showInstructions:(UINavigationController*)appNavController{
    checkDepositInsVC = [[CDInstructionsViewController alloc] initWithComponent:componentObject];
    checkDepositInsVC.countryCode = self.countryCode;
    checkDepositInsVC.delegate = self;
    [appNavController pushViewController:checkDepositInsVC animated:YES];
}

#pragma mark
#pragma mark Check Deposit Instructions Delegate Methods

-(void)checkFrontButtonClicked{
    
    self.isFront = YES;
    
    _fromImageCapturedMethod = NO;
    _fromImageSelectedMethod = NO;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //check for the state as well as the actual existence of the image in disk
        if(!_frontCheckProcessed || ![appStateMachine isImageInDisk:FRONT_PROCESSED mimeType:MIMETYPE_TIF])
        {
            [self discardCapturedImageAndShowCamera:YES];
        }
        else {
            [self showPreview:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] forPreview:YES];
        }
    });
}

-(void)checkBackButtonClicked{
    
    self.isFront = NO;
    
    _fromImageCapturedMethod = NO;
    _fromImageSelectedMethod = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //Check if back is processed and check if the actual image exists
        if(!_backCheckProcessed || ![appStateMachine isImageInDisk:BACK_PROCESSED mimeType:MIMETYPE_TIF]){
            [self discardCapturedImageAndShowCamera:YES];
        }
        else{
            [self showPreview:[appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF] forPreview:YES];
        }
    });
}


-(void)makeDepositButtonClicked{
    [self addCheckHistoryToDatabase];
    if([self isthereMismatch]){
        [self showAlertWithTitle:Klm(@"Amounts mismatch") andMessage:Klm(@"Your check deposit has been accepted and is in review") andTag:2];
    }
    else{
        [self showAlertWithTitle:@"" andMessage:Klm(@"Your check deposit has been accepted") andTag:2];
    }
}

-(void)backButtonClicked{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showAlertWithTitle: Klm([componentObject.texts.summaryText valueForKey:SUBMITCANCELALERTTEXT]) andMessage:nil andTag:1];
    });
}


-(void)checkHistoryClicked{
    
    CheckHistoryViewController *historyController = [[CheckHistoryViewController alloc]initWithNibName:@"CheckHistoryViewController" bundle:nil];
    [navigationController pushViewController:historyController animated:YES];
}


#pragma mark
#pragma mark Camera method



// method to open camera screen
-(void)showCamera{
    
    CaptureSettings* captureSettings = [[CaptureSettings alloc] init];
    captureSettings.showFlashOptions = NO;
    captureSettings.showGallery = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
    
    
    
    NSDictionary *settingsDictionary = [componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS];
    NSDictionary *cameraText = componentObject.texts.cameraText;
    
    //captureSettings.captureExperience = [[settingsDictionary valueForKey:CAPTUREEXPERIENCE] intValue];
    captureSettings.captureExperience = CHECK;
        
    captureSettings.moveCloserMessage = Klm([cameraText valueForKey:MOVECLOSER]);
    captureSettings.holdSteadyMessage = Klm([cameraText valueForKey:HOLDSTEADY]);
    captureSettings.cancelButtonText = Klm([cameraText valueForKey:CANCELBUTTON]);
    captureSettings.holdParallelMessage = Klm([cameraText valueForKey:HOLDPARALLEL]);
    captureSettings.orientationMessage = Klm([cameraText valueForKey:ORIENTATION]);

    
    if(self.isFront){
        captureSettings.userInstruction = Klm([cameraText valueForKey:USERINSTRUCTIONFRONT]);
    }
    else{
        captureSettings.userInstruction = Klm([cameraText valueForKey:USERINSTRUCTIONBACK]);
    }
    
    captureSettings.centerMessage = Klm([cameraText valueForKey:CENTERMESSAGE]);
    captureSettings.zoomOutMessage = Klm([cameraText valueForKey:ZOOMOUTMESSAGE]);
    captureSettings.capturedMessage = Klm([cameraText valueForKey:CAPTUREDMESSAGE]);
    
    if (captureSettings.cancelButtonText.length == 0)
        captureSettings.cancelButtonText = Klm(@"Cancel");
    
    captureSettings.doContinuousCapture = YES;
    
    captureSettings.manualCaptureTime = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
    captureSettings.showAutoTorch=[[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS] valueForKey:AUTOTORCH] boolValue];
    captureSettings.edgeDetection=[[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS] valueForKey:EDGEDETECTION] intValue];
    
    captureSettings.stabilityThresholdEnabled = YES;
    captureSettings.rollThresholdEnabled = YES;
    captureSettings.pitchThresholdEnabled = YES;
    captureSettings.focusConstraintEnabled = YES;
    captureSettings.useVideoFrame = YES; // For Check Deposite by default it should be true for better results

    captureSettings.doShowGuidingDemo = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue];
    
    
    if( [[[componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue] && self.isFront  && self.isFrontDemoShownForFirstTime && [[[componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS]valueForKey:FIRSTTIMELAUNCHDEMO]boolValue] ) {
        
        self.isFrontDemoShownForFirstTime = NO;
        
        if(!self.isBackDemoShownForFirstTime) {
            
            NSMutableDictionary *advacnedSettings = [[componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS]mutableCopy];
            [advacnedSettings setValue:[NSNumber numberWithBool:false] forKey:SHOWCHECKGUIDINGDEMO];
            [advacnedSettings setValue:[NSNumber numberWithBool:false] forKey:FIRSTTIMELAUNCHDEMO];
            [componentObject.settings.settingsDictionary setValue:advacnedSettings forKey:ADVANCEDSETTINGS];
        }
        
    }
    else if( [[[componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue] && !self.isFront  && self.isBackDemoShownForFirstTime && [[[componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS]valueForKey:FIRSTTIMELAUNCHDEMO]boolValue] ) {
        
        self.isBackDemoShownForFirstTime = NO;
        
        if(!self.isFrontDemoShownForFirstTime) {
            
            NSMutableDictionary *advacnedSettings = [[componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS]mutableCopy];
            [advacnedSettings setValue:[NSNumber numberWithBool:false] forKey:SHOWCHECKGUIDINGDEMO];
            [advacnedSettings setValue:[NSNumber numberWithBool:false] forKey:FIRSTTIMELAUNCHDEMO];
            [componentObject.settings.settingsDictionary setValue:advacnedSettings forKey:ADVANCEDSETTINGS];
        }
        
    }

    captureSettings.stabilityThreshold = [[settingsDictionary valueForKey:STABILITYDELAY]intValue];
    captureSettings.rollThreshold = [[settingsDictionary valueForKey:ROLLTHRESHOLD] intValue];
    captureSettings.pitchThreshold = [[settingsDictionary valueForKey:PITCHTHRESHOLD]intValue];

    if([AppUtilities isiPhone4s])
    {
        captureSettings.centerShiftValue = 0;
    }
    else {
        captureSettings.centerShiftValue = 35;
    }
    
    captureSettings.staticFrameAspectRatio  = 2.75/6.0;
    
    
    captureSettings.staticFramePaddingPercent = 5.0;
    captureSettings.offset = [[settingsDictionary valueForKey:OFFSETTHRESHOLD] floatValue];
    
    captureSettings.longAxisThreshold = [[settingsDictionary valueForKey:OFFSETTHRESHOLD] floatValue];
    captureSettings.shortAxisThreshold = [[settingsDictionary valueForKey:OFFSETTHRESHOLD] floatValue];
    
    captureSettings.hideStaticFrame = false; // This is not configurable from Settings , So it should be shown always .
    captureSettings.isBackCheckSide = !self.isFront;
    
    
    
    CaptureViewController* captureScreen = [[CaptureViewController alloc] initWithCaptureSettings:captureSettings];
    if(_fromImageSelectedMethod){
        captureScreen.loadAlbum = YES;
    }
    else{
        captureScreen.loadAlbum = NO;
    }
    captureScreen.delegate = self;
    
    [navigationController pushViewController:captureScreen animated:YES];
    
    captureScreen = nil;
    
}

#pragma mark
#pragma mark Capture Manager Delegate Methods

// this method call when we select an image from gallery
-(void) imageSelected:(kfxKEDImage *)capturedImage
{
    self.appStateCD = CDCAPTURED;
    
    _fromImageCapturedMethod = NO;
    _fromImageSelectedMethod = YES;
    self.currentCapturedImage  = capturedImage;
    [self doSomeCommonOperationsAfterCapture];
}

//This method call when we captured image using camera
-(void)imageCaptured:(kfxKEDImage*)capturedImage{
    
    self.appStateCD = CDCAPTURED;
    
    _fromImageCapturedMethod = YES;
    _fromImageSelectedMethod = NO;
    self.currentCapturedImage  = capturedImage;
    [self doSomeCommonOperationsAfterCapture];
}

// after capture or select from gallery do commmon operation here
-(void)doSomeCommonOperationsAfterCapture
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [appStateMachine storeToDisk:self.currentCapturedImage withType:self.isFront?FRONT_RAW:BACK_RAW mimeType:MIMETYPE_JPG];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showPreview:self.currentCapturedImage forPreview:NO];
    });
    
    if ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:DOQUICKANALYSIS] boolValue]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            if (!imageProcessor) {
                imageProcessor = [[ImageProcessor alloc] init];
                imageProcessor.delegate = self;
            }
            [AppUtilities addActivityIndicator];
            [imageProcessor performQuickAnalysisOnImage:self.currentCapturedImage];
        });
    }
    else if (![AppUtilities isLowerEndDevice]){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self processCapturedImage];
        });
    }
}

// clicked on cancel button perform here
-(void)cancelCamera{
    
    if (self.appStateCD == CDPROCESSING){
        [imageProcessor cancelProcessing];
        self.appStateCD = CDCANCELLING;
    }
    else if (self.appStateCD == CDEXTRRACTING){
        [extractionManager cancelExtraction];
    }
    else
    {
        self.appStateCD = CDNOOP;
    }
    
    [navigationController popToViewController:checkDepositInsVC animated:YES];
}

#pragma mark
#pragma mark Quick Analysis Feedback

// call back calls if quick analysic feedback is in on state
-(void)quickAnalysisResponse:(kfxKEDQuickAnalysisFeedback*)feedback{
    
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
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(feedback.isBlurry || feedback.isUnderSaturated || feedback.isOverSaturated){
                [self showAlertWithTitle:quickFeedback andMessage:nil andTag:6];
            }
            
        });
    }
}

#pragma mark
#pragma mark Preview methods

// method for show preview
// isPreview true Preview with Extracted result
// isPreview false Preview with row Image
-(void)showPreview:(kfxKEDImage*)capturedImage forPreview:(BOOL)isPreview{
    
    ExhibitorViewController *exhibitorObj = [[ExhibitorViewController alloc] initWithNibName:@"ExhibitorViewController" bundle:nil];
    exhibitorObj.delegate = self;
    exhibitorObj.inputImage  = capturedImage;
    
    if(self.isFront ){
        
        if(!_fromImageSelectedMethod)
        {
            [exhibitorObj removeNavigationBarItems];
            exhibitorObj.leftButtonTitle = Klm([componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
            
            if (exhibitorObj.leftButtonTitle.length == 0)
                exhibitorObj.leftButtonTitle = Klm(@"Retake");
            
            if(_fromImageCapturedMethod){
                exhibitorObj.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:FRONTUSEBUTTON]);
                
                if (exhibitorObj.rightButtonTitle.length == 0)
                    exhibitorObj.rightButtonTitle = Klm(@"Use");
            }
            else{
                exhibitorObj.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:CANCELBUTTON]);
                exhibitorObj.isCancelButtonShow = YES;
                
                if (exhibitorObj.rightButtonTitle.length == 0)
                    exhibitorObj.rightButtonTitle = Klm(@"Cancel");
            }
        }else {
            
            
            exhibitorObj.showTopBar = YES;
            exhibitorObj.leftButtonTitle =@"";
            exhibitorObj.rightButtonTitle = @"";
            
        }
        
    }
    else{
        
        if(!_fromImageSelectedMethod){
            [exhibitorObj removeNavigationBarItems];
            
            exhibitorObj.leftButtonTitle = Klm([componentObject.texts.previewText valueForKey:BACKRETAKEBUTTON]);
            
            if (exhibitorObj.leftButtonTitle.length == 0)
                exhibitorObj.leftButtonTitle = Klm(@"Retake");
            
            if (exhibitorObj.rightButtonTitle.length == 0)
                exhibitorObj.rightButtonTitle = Klm(@"Use");
            if (exhibitorObj.rightButtonTitle.length == 0)
                exhibitorObj.rightButtonTitle = Klm(@"Use");
            if(_fromImageCapturedMethod){
                exhibitorObj.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:BACKUSEBUTTON]);
                
                if (exhibitorObj.rightButtonTitle.length == 0)
                    exhibitorObj.rightButtonTitle = Klm(@"Use");
            }
            else{
                exhibitorObj.rightButtonTitle = Klm([componentObject.texts.previewText valueForKey:CANCELBUTTON]);
                exhibitorObj.isCancelButtonShow = YES;
                
                if (exhibitorObj.rightButtonTitle.length == 0)
                    exhibitorObj.rightButtonTitle = Klm(@"Cancel");
            }
        }
        else {
            
            exhibitorObj.showTopBar = YES;
            exhibitorObj.leftButtonTitle =@"";
            exhibitorObj.rightButtonTitle = @"";
        }
    }
    
    if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTSWITCH] boolValue])
    {
        
        if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:HIGHLIGHTDATA] boolValue]){
            
            if(self.isFront && isPreview){
                
                if((![[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:USEBANKRIGHTSETTINGS] boolValue]
                    && [[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:AUTOROTATE] boolValue]) ||
                   ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:USEBANKRIGHTSETTINGS] boolValue])){
                    if(coloredAreas && [coloredAreas count] > 0){
                        [exhibitorObj setColoredAreas:coloredAreas];
                    }
                }
                else{
                    [exhibitorObj setColoredAreas:nil];
                }
            }
            else{
                [exhibitorObj setColoredAreas:nil];
            }
        }
    }
    [navigationController pushViewController:exhibitorObj animated:NO];
    
}

#pragma mark
#pragma mark Exhibitor Delegate Methods

-(void) albumButtonClicked
{
    if (self.appStateCD == CDPROCESSING){
        [imageProcessor cancelProcessing];
        self.appStateCD = CDCANCELLING;
    }
    else if (self.appStateCD == CDEXTRRACTING){
        [extractionManager cancelExtraction];
    }
   
    //removing the processed front/back when extraction didnot finish as we may not need it further.
    if(self.appStateCD != CDEXTRACTED && self.appStateCD != CDNOOP)
        [appStateMachine removeFilePathIfExists:[appStateMachine getFilePathWithType:self.isFront?FRONT_PROCESSED:BACK_PROCESSED mimeType:MIMETYPE_TIF]];
    [self discardCapturedImageAndShowCamera:YES];
}

-(void) useSelectedPhotoButtonClicked{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self useButtonClicked];
    });
}

// method called after clicking on use button
-(void)useButtonClicked{
    
    
    // condition if check is extracted
    if (self.appStateCD == CDEXTRACTED) {
        [self handlePostExtractionOperations];
        
    }
    else if (self.appStateCD == CDCAPTURED || self.appStateCD == CDNOOP){
        
        // This block will execute if Image captured from the camera or it is initialized state
        [AppUtilities addActivityIndicator];
        [self processCapturedImage];
        self.appStateCD = CDPROCESSING_USECLICKED;
    }
    else if (self.appStateCD == CDPROCESSED){
        
        if (self.isFront) {
            [appStateMachine storeImage:self.currentProcessedImage withType:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
            [self handleCheckFrontOperations];
        }else{
            [appStateMachine storeImage:self.currentProcessedImage withType:BACK_PROCESSED mimeType:MIMETYPE_TIF];
            NSString *metaData = [self.currentProcessedImage getImageMetaData];
            if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue]!=1){
            if (![self checkBackHasEndorsement:metaData])
            {
                [PersistenceManager storeBackSignature:NO];
                dispatch_async(dispatch_get_main_queue() , ^{
                    [AppUtilities removeActivityIndicator];
                    [self showAlertWithTitle:Klm(@"Endorsement not found") andMessage:Klm(@"An endorsement could not be found on the back of the check. Would you like to retry?") andTag:0];
                });
                
            }
            else if ([self verifySignatureAndMicr:metaData] == 2)
            {
                dispatch_async(dispatch_get_main_queue() , ^{
                    [AppUtilities removeActivityIndicator];
                    [self showAlertWithTitle:Klm(@"Invalid check back") andMessage:Klm(@"This appears to be the front for the check. Please capture the back of the check") andTag:7];
                });
            }
            else
            {
                [self handleCheckBackOperations];
            }
            }
            else
            {
                [self handleCheckBackOperations];
            }
        }
    }
    else if (self.appStateCD == CDFAILED)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppUtilities removeActivityIndicator];
            [self showAlertWithTitle:Klm(@"Endorsement not found") andMessage:Klm(@"An endorsement could not be found on the back of the check. Would you like to retry?") andTag:0];
        });
    }
    else if (self.appStateCD == CDPROCESSING)
    {
        self.appStateCD = CDPROCESSING_USECLICKED;
        [AppUtilities addActivityIndicator];
    }
    
}

-(void)retakeButtonClicked{
    
    if (self.appStateCD == CDPROCESSING){
        [imageProcessor cancelProcessing];
        self.appStateCD = CDCANCELLING;
    }
    else if (self.appStateCD == CDEXTRRACTING){
        [extractionManager cancelExtraction];
    }
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    kfxKUTAppStatsSessionEvent * evt = [[kfxKUTAppStatsSessionEvent alloc] init];
    evt.type = @"RETAKE";
    
    [stats logSessionEvent:evt];
    
    
    [self discardCapturedImageAndShowCamera:YES];
    
}

-(void)cancelButtonClicked{
    [self discardCapturedImageAndShowCamera:NO];
}



#pragma mark
#pragma mark Processor methods


// method is used for processing the captured (row) image or image that is selected from the gallery
-(void)processCapturedImage{
    
    if(!imageProcessor){
        imageProcessor = [[ImageProcessor alloc] init];
        imageProcessor.delegate = self;
    }
    
    self.appStateCD = CDPROCESSING;
    //[appStateMachine removeFilePathIfExists:[appStateMachine getFilePathWithType:self.isFront?FRONT_PROCESSED:BACK_PROCESSED mimeType:MIMETYPE_TIF]];
    
    [imageProcessor processImage:self.currentCapturedImage withProfile:[self getProcessingProfile] withFileName:nil mimeType:MIMETYPE_TIF];
    
}


// this method call when we restart the capture process
-(void)discardCapturedImageAndShowCamera:(BOOL)showCam{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CaptureViewController * captureViewController = [navigationController.viewControllers objectAtIndex:navigationController.viewControllers.count-2];
        if ([captureViewController isKindOfClass:[CaptureViewController class]]) {
            captureViewController.settings.doShowGuidingDemo = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue];
            captureViewController.loadAlbum = _fromImageSelectedMethod?YES:NO;
            [navigationController popViewControllerAnimated:YES];
        }
        else if (showCam){
            [self showCamera];
        }else if (!_frontCheckProcessed || !_backCheckProcessed) {
            if ([captureViewController isKindOfClass:[CaptureViewController class]]) {
                captureViewController.loadAlbum = _fromImageSelectedMethod?YES:NO;
                captureViewController.settings.doShowGuidingDemo = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue];
            }
            [navigationController popViewControllerAnimated:NO];
        }else{
            [navigationController popViewControllerAnimated:YES];
        }
    });
}


// validation for check back endorsement
// return YES if Back Endorsement found
// return NO if Back Endorsement not found
-(BOOL)checkBackHasEndorsement:(NSString*)metaData{
    
    NSError *jsonError;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    CGFloat width=0, height=0;
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Output Image Attributes"]){
            
            jsonDict = [jsonDict objectForKey:@"Output Image Attributes"];
            
            height = [[jsonDict objectForKey:@"Height"] floatValue];
            width = [[jsonDict objectForKey:@"Width"] floatValue];
        }
    }
    
    jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    CGRect signatureRect = CGRectMake(0, 0, width, height);
    CGPoint BL, BR, TL, TR;
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Text Lines"]){
            
            jsonDict = [jsonDict objectForKey:@"Text Lines"];
            
            if([[jsonDict allKeys] containsObject:@"Lines"]){
                
                NSArray *tempArray = [jsonDict objectForKey:@"Lines"];
                
                for (NSDictionary *tempDict in tempArray) {
                    
                    if([[tempDict valueForKey:@"Type"] isEqualToString:@"HP"]){
                        // Signature Found
                        BL = CGPointMake([[tempDict valueForKey:@"BLx"] floatValue], [[tempDict valueForKey:@"BLy"] floatValue]);
                        BR = CGPointMake([[tempDict valueForKey:@"BRx"] floatValue], [[tempDict valueForKey:@"BRy"] floatValue]);
                        TL = CGPointMake([[tempDict valueForKey:@"TLx"] floatValue], [[tempDict valueForKey:@"TLy"] floatValue]);
                        TR = CGPointMake([[tempDict valueForKey:@"TRx"] floatValue], [[tempDict valueForKey:@"TRy"] floatValue]);
                        
                        if(CGRectContainsPoint(signatureRect, BL) && CGRectContainsPoint(signatureRect, BR)  &&
                           CGRectContainsPoint(signatureRect, TL) && CGRectContainsPoint(signatureRect, TR)) {
                            
                            // Signature Found
                            return YES;
                        }
                        else{
                            
                            //Signature not found
                            NSLog(@"Signature not found\n");
                        }
                    }
                }
                
            }
        }
    }
    
    return NO;
    
}

#pragma mark
#pragma mark Image Processor Delegate Methods


// This callback fires if processing status is success/failure.
// if status is NO - Processing Failed.
// if status is YES - Image processed successfully.

-(void)processingSucceeded:(BOOL)status withOutputImage:(kfxKEDImage*)processedImage{
    
    NSLog(@"*****  processingSucceeded");
    
    if (status){
        self.isFront?(_frontCheckProcessed = YES):(_backCheckProcessed = YES);
        
        if (self.appStateCD == CDPROCESSING_USECLICKED) {
            self.appStateCD = CDPROCESSED;
            self.currentProcessedImage = processedImage;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppUtilities removeActivityIndicator];
                [self useButtonClicked];
            });
        }
        else if(self.appStateCD == CDREPROCESSING)
        {
            self.appStateCD = CDPROCESSED;
            [self sendToServer];
        }
        else{
            self.appStateCD = CDPROCESSED;
            self.currentProcessedImage = processedImage;
            
        }
    }
    else{
        if(self.appStateCD != CDCANCELLING)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppUtilities removeActivityIndicator];
                self.appStateCD = CDNOOP;
                [self showAlertWithTitle:Klm(@"Processing Failed") andMessage:Klm(@"Processing of the image failed. Please retake.") andTag:10];
            });
        }
    }
}


// method for getting processing parameters
// return kfxKEDImagePerfectionProfile object
-(kfxKEDImagePerfectionProfile*)getProcessingProfile{
    
    
    
    NSString *strFrontImageWidth =@"";
    if(!self.isFront && [appStateMachine isImageInDisk:FRONT_PROCESSED mimeType:MIMETYPE_TIF]){
        
        // Fetch the Front Image Width
        strFrontImageWidth = [self calculateTheCheckFrontWidth:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF]];
    }
    
    
    kfxKEDImagePerfectionProfile * kPerfectionProf=nil;
    NSMutableDictionary *checkEVRSSettings = [[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] mutableCopy];
    [checkEVRSSettings  setValue:[advancedSettings valueForKey:USEHANDPRINT] forKey:USEHANDPRINT];
    [checkEVRSSettings  setValue:[advancedSettings valueForKey:SEARCHMICR] forKey:SEARCHMICR];
    
    NSString * opStr = [AppUtilities getEVRSImagePerfectionStringFromSettings:checkEVRSSettings ofComponentType:CHECKDEPOSIT isFront:self.isFront withScaleSize:CGSizeZero withFrontImageWidth:strFrontImageWidth];
    
    kPerfectionProf = [[kfxKEDImagePerfectionProfile alloc]initWithName:STATICPERFECTIONPROFILE andOperations:opStr];
    return kPerfectionProf;
}



// This method we used for reprocessing the Back check Image.
// The reason is using this method to auto rotate back check into Portrait for both mode (Portrait and upside down).
-(void)reprocessCapturedImage{
    
    if(!imageProcessor){
        imageProcessor = [[ImageProcessor alloc] init];
        imageProcessor.delegate = self;
    }
    self.appStateCD = CDREPROCESSING;
    kfxKEDImage *img = [appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF];
    
  //  [appStateMachine removeFilePathIfExists:[appStateMachine getFilePathWithType:BACK_PROCESSED mimeType:MIMETYPE_TIF]];
    [imageProcessor processImage:img withProfile:[self getReProcessingProfile] withFileName:nil mimeType:MIMETYPE_TIF];
}



-(void)classificationSucceded : (BOOL)status withClassification: (kfxKEDClassificationResult*)classificationResult Image:(kfxKEDImage*)classifiedImage{
    
    
}

#pragma mark
#pragma mark Check Amount in MICR

/*
 
 This method is used to check if an encoded amount is present in MICR.
 We use the "kfxKUTMicrParser" to check if the MICR is valid and than fetch the amount from "kfxKUTMicrLine" through "amount" property.
 
 */

-(void)checkAmountInMICR {
    
    // Parses the meta data
    
    NSString *strOCRData = [self getMICR];
    if(strOCRData.length) {
        
        kfxKUTMicrParser *theMicrData = [[kfxKUTMicrParser alloc] initWithMicr: strOCRData];
        if(theMicrData.isMicrValid) {
            
            kfxKUTMicrLine *theMicrLine = [theMicrData getMicrLine];
            NSString *strAmount = theMicrLine.amount;
            if(strAmount.length>0){
                
                NSLog(@"Amount in MICR %@",strAmount);
                NSInteger intAmount = strAmount.integerValue;
                if(intAmount>0){
                    
                    _showAmountInMicrAlert = YES;
                    
                }
                else {
                    
                    _showAmountInMicrAlert = NO;
                }
            }
            
        }
        
        
        
    }
    
}

/*
 
 This method is used to fetch the MICR from the extracted results
 
 */

-(NSString *)getMICR {
    
    NSString *strMicr = @"" ;
    
    if(!processedResults || [processedResults count] == 0){
        return strMicr;
    }
    
    //A2iA_CheckCodeline
    for (NSDictionary *dict in processedResults) {
        
        if([[dict allKeys] containsObject:@"name"]){
            
            if([[dict valueForKey:@"name"] isEqualToString:@"A2iA_CheckCodeline"]){
                strMicr =[dict valueForKey:@"text"];
                break;
            }
        }
    }
    
    return strMicr;
    
}

// method used if Check is invalid
-(void)showAlertforAmountInMICR {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"This check is invalid as the codeline includes an encoded amount.")  delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
        alertView.tag = AlertTagAmountInMICR;
        [alertView show];
        alertView = nil;
        
    });
}


#pragma mark
#pragma mark Data Extraction Method

-(void)extractData:(kfxKEDImage*)processedImage{
    
    if(!extractionManager){
        extractionManager = [[ExtractionManager alloc] init];
        extractionManager.delegate = self;
    }
    
    if ([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]) {
        
        //Sending for extraction if server type is KTA
        extractionManager.serverType = KTA;
        
        NSMutableArray *arrProcessed = [[NSMutableArray alloc]init];
        if(processedImage){
            [arrProcessed addObject:processedImage];
        }
        
        //We need to send login credentials to the server if the server type is KTA.
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        NSURL *rttiServerURL = [NSURL URLWithString:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]];
        [parameters setValue:[NSString stringWithFormat:@"%lu",(unsigned long)arrProcessed.count] forKey:@"ProcessCount"];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPROCESSNAME] forKey:PROCESS_IDENTITY_NAME];
        [parameters setValue:@"Check" forKey:DOCUMENT_NAME];
        [parameters setValue:@"Kofax_Check_Deposit" forKey:DOCUMENT_GROUP_NAME];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAUSERNAME] forKey:USERNAME];
        [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPASSWORD] forKey:PASSWORD];
        
        [extractionManager extractImagesData:arrProcessed saveOriginalImages:nil withURL:rttiServerURL withParams:([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue]||[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE] boolValue])?parameters: nil withMimeType:MIMETYPE_TIF];
    }else{
        
        //Sending for extraction if server type is RTTI
        
        
        extractionManager.serverType = RTTI;
        NSString *rttiServerUrl = [NSString stringWithFormat:@"%@",[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL]];
        [extractionManager extractDataForImage:processedImage URL:[NSURL URLWithString:rttiServerUrl] withMimeType:MIMETYPE_TIF];
    }
}


// method used for sending multipart request to Server
-(void)talkToRTTIwithFront:(kfxKEDImage*)frontImage AndBack:(kfxKEDImage*)backImage{
    
    if ([AppUtilities isConnectedToNetwork]) {
        if(!extractionManager){
            
            extractionManager = [[ExtractionManager alloc] init];
            extractionManager.delegate = self;
        }
        
        NSMutableArray *arrProcessed = [[NSMutableArray alloc]init];
        NSMutableArray *arrUnProccessed = [[NSMutableArray alloc]init];
        if(frontImage){
            
            [arrProcessed addObject:[appStateMachine getFilePathWithType:FRONT_PROCESSED mimeType:MIMETYPE_TIF]];
            
            if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue] && ![[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue])
                [arrUnProccessed addObject:[appStateMachine getFilePathWithType:FRONT_RAW mimeType:MIMETYPE_JPG]];
        }
        
        if(backImage) {
            [arrProcessed addObject:[appStateMachine getFilePathWithType:BACK_PROCESSED mimeType:MIMETYPE_TIF]];
            if([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue]&& ![[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue])
                [arrUnProccessed addObject:[appStateMachine getFilePathWithType:BACK_RAW mimeType:MIMETYPE_JPG]];
        }
        
        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
        
        if ([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]) {
            extractionManager.serverType = KTA;

            if(self.xCountry && ![self.xCountry isEqualToString:@""]){
                [parameters setValue:self.xCountry forKey:@"Country"];
            }
            
            //We need to send login credentials to the server if the server type is KTA.
            NSURL *rttiServerURL = [NSURL URLWithString:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]];
            
            
            if ([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue]||[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE] boolValue])
            {
            
                [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPROCESSNAME] forKey:PROCESS_IDENTITY_NAME];
                [parameters setValue:@"" forKey:DOCUMENT_NAME];
                [parameters setValue:@"" forKey:DOCUMENT_GROUP_NAME];
                [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAUSERNAME] forKey:USERNAME];
                [parameters setValue:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPASSWORD] forKey:PASSWORD];
            }
            
            int errorStatus = [extractionManager extractImageFiles:arrProcessed saveOriginalImages:arrUnProccessed withURL:rttiServerURL withParams:parameters withMimeType:MIMETYPE_TIF];
            
            if(errorStatus != KMC_SUCCESS){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [AppUtilities removeActivityIndicator];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:[kfxError findErrMsg:errorStatus] delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                    
                    [alertView show];
                });
                
            }
        }
        else{
            
            if(self.xCountry && ![self.xCountry isEqualToString:@""]){
                [parameters setValue:self.xCountry forKey:@"xCountry"];
            }
            
            if (sessionKey != nil)
            {
                
                [parameters setValue:sessionKey forKey:@"SessionKey"];
                
            }
            
            extractionManager.serverType = RTTI;
            NSURL *rttiServerURL = [NSURL URLWithString:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL]];
            if ([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue]|| ![[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE] boolValue])
            {
                [parameters setValue:[NSString stringWithFormat:@"%lu",(unsigned long)arrProcessed.count] forKey:@"ProcessCount"];
            }
            
            int errorStatus = [extractionManager extractImageFiles:arrProcessed saveOriginalImages:arrUnProccessed withURL:rttiServerURL withParams:parameters withMimeType:MIMETYPE_TIF];
            
            if(errorStatus != KMC_SUCCESS){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [AppUtilities removeActivityIndicator];
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:[kfxError findErrMsg:errorStatus] delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                    
                    [alertView show];
                });
                
            }
            
        }
        
        arrProcessed = nil;
        arrUnProccessed = nil;
        parameters = nil;
    }else{
        [AppUtilities removeActivityIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* networkError = [[UIAlertView alloc] initWithTitle:Klm(@"Network Alert!!") message:Klm(@"Check extraction cannot be performed because the app cannot connect to the network.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            [networkError show];
        });
    }
}

#pragma mark
#pragma mark RTTI Manager Delegate Methods

// call back is used if extraction is succeeded
-(void)extractionSucceeded:(NSInteger)statusCode withResults:(NSData *)resultsData{
    NSLog(@" ***** extraction successed");
    self.appStateCD = CDEXTRACTED;
    _returnCode = statusCode;
    checkDepositInsVC.extractedError = nil;
    if (statusCode != REQUEST_SUCCESS) {
        _extractionFailedMessage = @"Couldn’t read the Document.";
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
        checkDepositInsVC.extractedError = [NSError errorWithDomain:[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL] code:statusCode userInfo:userInfo];
    }
   
    [self parseResponseData:resultsData];
    
    checkDepositInsVC.checkResults = processedResults;
    
    
    NSLog(@"processedResults = %@\n",processedResults);
    [self fillColorAreasArray];
    [self handlePostExtractionOperations];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppUtilities removeActivityIndicator];
        // Disabling the Settings
        checkDepositInsVC.disableSettings = YES;
    });
}


// callback execute if extraction failed
-(void)extractionFailedWithError:(NSError *)error responseCode:(NSInteger)responseCode
{
    self.appStateCD = CDEXTRACTED;
    if(responseCode == REQUEST_FAILURE)
    {
        _extractionFailedMessage = Klm(@"Could not read the document.");
    }
    else if(error.code==REQUEST_TIMEDOUT){
        _extractionFailedMessage = Klm(@"The Request timed out.");
    }
    else if(error.code == NONETWORK){
        _extractionFailedMessage = Klm(@"Check extraction cannot be performed because the app cannot connect to the network.");
    }
    else if (error.code > 0){
        
        _extractionFailedMessage = [kfxError findErrMsg:error.code];
        
    }else{
        _extractionFailedMessage = Klm([[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?@"The KTA server may be offline or does not exist.":@"The RTTI server may be offline or does not exist.");
    }
    
    checkDepositInsVC.extractedError = error;
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppUtilities removeActivityIndicator];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:_extractionFailedMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
        alertView.tag = 4;
        _returnCode = error.code;
        [alertView show];

        //Earlier we are showing send summary screen when extraction is succeeded, now we are showing this screen even exraction is failed.
    });
    
    NSLog(@"Extraction Failed with Error %@\n",[error description]);
}


#pragma mark---Parse Methods
-(void)parseResponseData:(NSData *)resultsData{
    
    NSArray *responseArray = [NSJSONSerialization JSONObjectWithData:resultsData options:NSJSONReadingAllowFragments error:nil];
    NSDictionary *tempDict;
    
    if([responseArray count] > 0){
        tempDict = [responseArray objectAtIndex:0];
    }
    else{
        return;
    }
    processedResults = [[tempDict valueForKey:STATICSERVERFIELDS] mutableCopy];
    
    
}

#pragma mark---
//Method is used for showing summary screen when extraction fails and also checks if send summary is on/off.
- (void)showSummaryScreenOnExtractionFails
{
    checkDepositInsVC.checkResults = nil;
    checkDepositInsVC.disableSettings = YES;
    if(self.isFront){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSummaryScreen:nil withImage:_currentProcessedImage andAnimation:NO];
        });
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showSummaryScreen:nil withImage:_currentProcessedImage andAnimation:NO];
        });
    }
    [self checkForImageSummaryEnabled];
}

#pragma mark
#pragma mark Summary Screen
-(void)showSummaryScreen:(NSArray*)results withImage:(kfxKEDImage*)image andAnimation:(BOOL)animation{
    
    if(self.isFront){
        if(!_backCheckProcessed){
            
            if(checkDepositInsVC.cdState == 0){
                checkDepositInsVC.cdState = 1;
            }
        }
        else{
            
            if(checkDepositInsVC.cdState == 1){
                checkDepositInsVC.cdState = 2;
            }
        }
        checkDepositInsVC.checkFront = [image getImageBitmap];
        checkDepositInsVC.checkFrontRaw = [appStateMachine getImage:FRONT_RAW mimeType:MIMETYPE_JPG];
        checkDepositInsVC.checkProcessedFront = [appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    }
    else{
        if(!_frontCheckProcessed ){
            if(checkDepositInsVC.cdState == 0){
                checkDepositInsVC.cdState = 1;
            }
        }
        else{
            if(checkDepositInsVC.cdState == 1){
                checkDepositInsVC.cdState = 2;
            }
        }
        checkDepositInsVC.checkBack = [image getImageBitmap];
        checkDepositInsVC.checkBackRaw = [appStateMachine getImage:BACK_RAW mimeType:MIMETYPE_JPG];
        checkDepositInsVC.checkProcessedBack = [appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF];
        
    }
    
    [self performSelectorOnMainThread:@selector(popVC) withObject:self waitUntilDone:NO];
}

#pragma mark
#pragma mark Local Methods

// method is used for filling the color cordinate for heighlighted the selected area.
-(void)fillColorAreasArray{
    
    if(!processedResults || [processedResults count] == 0){
        return;
    }
    coloredAreas = [AppUtilities getRectDictsFromResults:processedResults];
    NSLog(@"coloredAreas = %@\n",coloredAreas);
}


// method is used to call after extraction is success.
// if returncode is 200 , extraction was success
// else extraction was failed.
-(void)handlePostExtractionOperations{
    
    if (_returnCode == 200) {
        [self checkAmountInMICR];
        [PersistenceManager storeCheckInformation:processedResults];
        if(self.isFront){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSummaryScreen:processedResults withImage:_currentProcessedImage andAnimation:NO];
            });
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSummaryScreen:processedResults withImage:_currentProcessedImage andAnimation:NO];
            });
        }
        [self showCheckRejectReason];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:_extractionFailedMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            alertView.tag = 4;
            [alertView show];
        });
    }
}

// after processing the image this method used to call for
// take decision based on condition wheteher to go for summary screen ,or reproces Image, or send to server
-(void)handleCheckFrontOperations{
    
    // The settings needs to be fetched again , as the user can change the settings after he intializes the Check Depost Module
    advancedSettings = [componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS];
    
    if (!_backCheckProcessed) {
        if (![[advancedSettings valueForKey:CHECKVALIDATIONSERVER] boolValue]) {
            
            if ([self validateSignatureOnCheckFront]){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showSummaryScreen:nil withImage:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] andAnimation:NO];  //Fetching image from documents folder
                });
            }
            else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showSummaryScreen:nil withImage:self.currentProcessedImage andAnimation:NO];
                });
            }
            
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSummaryScreen:nil withImage:_currentProcessedImage andAnimation:NO];
            });
        }
    }
    else if (_backCheckProcessed)
    {
        if (![[advancedSettings valueForKey:CHECKVALIDATIONSERVER] boolValue]) {
            if ([self validateSignatureOnCheckFront]){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppUtilities addActivityIndicator];
                    
                    if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 2)
                    {
                        [self reprocessCapturedImage];
                    }
                    else{
                        [self talkToRTTIwithFront:self.currentProcessedImage AndBack:nil];
                    }
                });
            }
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppUtilities addActivityIndicator];
            });
            if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 2){
                [self reprocessCapturedImage];
            }
            else{
                [self talkToRTTIwithFront:self.currentProcessedImage AndBack:nil];
            }
        }
    }
}

// after processing the image this method used to call for
// take decision based on condition wheteher to go for summary screen ,or reproces Image, or send to server
-(void)handleCheckBackOperations{
    
    BOOL isFrontProcessed = _frontCheckProcessed;
    // The settings needs to be fetched again , as the user can change the settings after he intializes the Check Depost Module
    advancedSettings = [componentObject.settings.settingsDictionary valueForKey:ADVANCEDSETTINGS];
    
    if (isFrontProcessed){
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppUtilities addActivityIndicator];
        });
        if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 2){
            [self reprocessCapturedImage];
        }
        else{
            [self talkToRTTIwithFront:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] AndBack:nil];
        }
        [PersistenceManager storeBackSignature:YES];
    }
    else if (!isFrontProcessed){
        [self showSummaryScreen:nil withImage:self.currentProcessedImage andAnimation:NO];
        [PersistenceManager storeBackSignature:YES];
    }
}

// if entered amount and extracted amount does not match this alert will display.
-(void)showMisMatchAlert{
    
    if([self isthereMismatch]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:@"" andMessage:Klm(@"The amount you entered does not match the amount scanned from your check") andTag:AlertTagAmountMismatch];
        });
    }
    else {
        [self checkForImageSummaryEnabled];
    }
}

// method to save check details to dataBase
-(void)addCheckHistoryToDatabase{
    CheckHistoryManager *historyManager = [[CheckHistoryManager alloc]init];
    NSString *micrCode = nil;
    
    [self updateCheckHistory];
    ChecksHistory *historyObject = (ChecksHistory*)[NSEntityDescription insertNewObjectForEntityForName:@"ChecksHistory" inManagedObjectContext:historyManager.managedObjectContext];
    NSArray *checkHistory = [PersistenceManager getCheckInformation];
    
    for (int j=0; j<[checkHistory count]; j++) {
        NSDictionary *dict = [checkHistory objectAtIndex:j];
        if ([[dict objectForKey:@"name"] isEqualToString:@"A2iA_CheckDate"]) {
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc]init];
            [dateFormat setDateFormat:@"MM-dd-yyyy"];
            historyObject.checkDate = [dateFormat dateFromString:[dict objectForKey:@"text"]];
            dateFormat = nil;
        }else if([[dict objectForKey:@"name"]isEqualToString:@"A2iA_CheckPayeeName"]){
            historyObject.payeeName = [dict objectForKey:@"text"];
        }else if([[dict objectForKey:@"name"]isEqualToString:@"A2iA_CheckNumber"]){
            historyObject.checkNumber = [dict valueForKey:@"text"];
        }else if([[dict objectForKey:@"name"]isEqualToString:@"A2iA_CheckCodeline"]){
            micrCode = [dict valueForKey:@"text"];
        }else if([[dict objectForKey:@"name"] isEqualToString:@"A2iA_CheckAmount"]){
            historyObject.amount = [dict valueForKey:@"text"];
        }
    }
    if (micrCode || micrCode.length!=0) {
        historyObject.micrCode = micrCode;
    }
    
    historyObject.payDate = [NSDate date];
    historyObject.frontImageFilePath = UIImageJPEGRepresentation([[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] getImageBitmap], 0);
    historyObject.backImageFilePath = UIImageJPEGRepresentation([[appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF] getImageBitmap], 0);
    
    NSArray *documentsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [documentsArray objectAtIndex:0];
    NSString *frontFilePath = [documentsDirectory stringByAppendingPathComponent:@"Front.jpg"];
    NSString *backFilePath = [documentsDirectory stringByAppendingPathComponent:@"Back.jpg"];
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:frontFilePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:frontFilePath error:nil];
    }
    if ([[NSFileManager defaultManager]fileExistsAtPath:backFilePath]) {
        [[NSFileManager defaultManager]removeItemAtPath:backFilePath error:nil];
    }
    
    kfxKEDImage *frontImage = [appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
    kfxKEDImage *backImage = [appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF];
    
    frontImage.imageFileOutputColor = KED_BITDEPTH_COLOR;
    [frontImage specifyFilePath:frontFilePath];
    frontImage.imageMimeType = MIMETYPE_TIF;
    //frontImage.imageDPI = 200;
    frontImage.jpegQuality = 90;
    if([frontImage imageWriteToFile] == KMC_SUCCESS){
    }
    [frontImage clearFileBuffer];
    [frontImage clearImageBitmap];
    backImage.imageFileOutputColor = KED_BITDEPTH_COLOR;
    [backImage specifyFilePath:backFilePath];
    backImage.imageMimeType = MIMETYPE_TIF;
    //backImage.imageDPI = 200;
    backImage.jpegQuality = 90;
    if([backImage imageWriteToFile] == KMC_SUCCESS){
    }
    [backImage clearFileBuffer];
    [backImage clearImageBitmap];
    
    [historyManager.managedObjectContext save:nil];
}

// in history we are maintaing only 10 items in check history.
// if it is greater than 10 use this method to deleted old record.
-(void)updateCheckHistory{
    
    CheckHistoryManager *historyManager = [[CheckHistoryManager alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChecksHistory" inManagedObjectContext:historyManager.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entity];
    NSArray *historyArray = [historyManager.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if ([historyArray count]==10) {
        [historyManager.managedObjectContext deleteObject:[historyArray objectAtIndex:0]];
    }
    [historyManager.managedObjectContext save:nil];
}


//Method is used to check MICR exist on the check front
-(int)checkMICR:(NSString*)ocrData withBLy:(int)mMICRBLy andTLy:(int)mMICRTLy{
    
    int MIN_MICR_HEIGHT = 8;
    int MIN_MICR_DATA_LEN = 11;
    __block int result = 0;
    if ((mMICRBLy - mMICRTLy) >= MIN_MICR_HEIGHT) {
        if (ocrData.length >= MIN_MICR_DATA_LEN) {
            NSRegularExpression *regex = [NSRegularExpression
                                          regularExpressionWithPattern:@"C\\d{9}C"
                                          options:NSRegularExpressionCaseInsensitive
                                          error:nil];
            [regex enumerateMatchesInString:ocrData options:NSMatchingReportCompletion range:NSMakeRange(0, [ocrData length]) usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                result = 2;
                
            }];
        }
    }
    return result;
}

/*
 This method is used to check if Signature & MICR exist on the check.
 */
-(int)verifySignatureAndMicr:(NSString*)metaData
{
    
    
    NSError *jsonError;
    
    NSDictionary *jsonDict =  [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    
    CGFloat width=0, height=0, xDPI = 0, yDPI = 0;
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Output Image Attributes"]){
            
            jsonDict = [jsonDict objectForKey:@"Output Image Attributes"];
            
            height = [[jsonDict objectForKey:@"Height"] floatValue];
            width = [[jsonDict objectForKey:@"Width"] floatValue];
            xDPI = [[jsonDict objectForKey:@"xDPI"] floatValue];
            yDPI = [[jsonDict objectForKey:@"yDPI"] floatValue];
            NSLog(@"---height is %f----width is %f----xdpi is %f----ydpi is %f",height,width,xDPI,yDPI);
        }
    }
    
    
    int i = 0;
    jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        
        if([[jsonDict allKeys] containsObject:@"Text Lines"]){
            
            jsonDict = [jsonDict objectForKey:@"Text Lines"];
            
            if([[jsonDict allKeys] containsObject:@"Lines"]){
                
                NSArray *tempArray = [jsonDict objectForKey:@"Lines"];
                
                // if tempArray does not have count means, Micr does not exist. making blank before assinging new value.
                
                _localMICR = @"";
                
                for (NSDictionary *tempDict in tempArray) {
                    
                    if([[tempDict valueForKey:@"Label"] isEqualToString:@"MICR"] && [[tempDict valueForKey:@"OCR Data"] length] > 0){
                        NSString *ocrData = [tempDict valueForKey:@"OCR Data"];
                        
                        if (ocrData.length != 0) {

                            i = [self checkMICR:ocrData withBLy:[[tempDict valueForKey:@"BLy"]intValue] andTLy:[[tempDict valueForKey:@"TLy"]intValue]];
                            ocrData = [[ocrData componentsSeparatedByCharactersInSet:
                                        [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                       componentsJoinedByString:@""];
                            if (i==2) {
                                
                                if(self.isFront){
                                    _localMICR = ocrData;
                                }
                                else{ // This covers the case where front is captured for back.
                                    return 2;
                                }
                            }
                        }
                        break;
                    }
                }
            }
        }
    }
    
    jsonDict = [NSJSONSerialization JSONObjectWithData:[metaData dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    
    if([[jsonDict allKeys] containsObject:@"Front Side"]){
        jsonDict = [jsonDict objectForKey:@"Front Side"];
        if([[jsonDict allKeys] containsObject:@"Text Lines"]){
            jsonDict = [jsonDict objectForKey:@"Text Lines"];
            if([[jsonDict allKeys] containsObject:@"Lines"]){
                NSArray *tempArray = [jsonDict objectForKey:@"Lines"];
                for (NSDictionary *tempDict in tempArray) {
                    if([[tempDict valueForKey:@"Type"] isEqualToString:@"HP"]){
                        i += 1;
                        break;
                    }
                }
            }
        }
    }
    
    return i;
    
}

// method to validate the signature on Back Check
-(BOOL)validateSignatureOnCheckFront
{
    if (![[advancedSettings valueForKey:SEARCHMICR] boolValue] && ![[advancedSettings valueForKey:USEHANDPRINT] boolValue] && ![[advancedSettings valueForKey:CHECKFORDUPLICATES] boolValue]) {
        return YES;
    }
    int result = [self verifySignatureAndMicr:[self.currentProcessedImage getImageMetaData]];
    NSString *title = @"", *msg = Klm(@"Retake?");
    
    if(result != 3 && ([[advancedSettings valueForKey:SEARCHMICR] boolValue] || [[advancedSettings valueForKey:USEHANDPRINT] boolValue])){
        
        title = Klm(@"Signature and MICR not found");
        msg = Klm(@"Unable to find both MICR and Signature. Would you like to retry?");
        
        if (result==0) {
            
            if (![[advancedSettings valueForKey:SEARCHMICR] boolValue]) {
                
                title = Klm(@"Signature not found");
                msg = Klm(@"Unable to find Signature. Would you like to retry?");
                
                
            }else if(![[advancedSettings valueForKey:USEHANDPRINT] boolValue]){
                title = Klm(@"MICR not detected");
                msg = Klm(@"Unable to find MICR. Would you like to retry?");
                
            }
        }
        else if(result == 1){
            
            if([[advancedSettings valueForKey:SEARCHMICR] boolValue]){
                
                title = Klm(@"MICR not detected");
                msg = Klm(@"Unable to find MICR. Would you like to retry?");
                
            }
        }
        else if(result == 2){
            
            if([[advancedSettings valueForKey:USEHANDPRINT] boolValue]){
                title = Klm(@"Signature not found");
                msg = Klm(@"Unable to find Signature. Would you like to retry?");
            }
        }
    }
    else{
        
        if ([[advancedSettings valueForKey:CHECKFORDUPLICATES] boolValue] && [self checkMICRExistOrNot:_localMICR]) {
            
            title = Klm(@"Duplicate Check");
            msg = Klm(@"Would you like to retake?");
        }
        else{
            return YES;
        }
    }
    
    if(![title isEqualToString:@"Signature and MICR not found"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlertWithTitle:title andMessage:msg andTag:3];
        });
    }
    else {
        
        if(result == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showAlertWithTitle:title andMessage:msg andTag:3];
            });
            
        }
        else{
            
            return YES;
        }
        
    }
    
    return NO;
}

// method for matching entered amount and extracted amount
-(BOOL)isthereMismatch{
    
    float userEnterAmount = [[AppUtilities getNumberFormatterOfLocaleBasedOnCountryCode:self.countryCode] numberFromString:checkDepositInsVC.checkAmount].floatValue;
    if(userEnterAmount == [[self getCheckAmountFromResults] floatValue])
        return NO;
    return YES;
}

// fetch amount from extracted data received from server
-(NSString*)getCheckAmountFromResults{
    NSString *strAmount = @"";
    if(!processedResults || [processedResults count] == 0){
        return strAmount;
    }
    
    //A2iA_CheckAmount
    for (NSDictionary *dict in processedResults) {
        if([[dict allKeys] containsObject:@"name"]){
            if([[dict valueForKey:@"name"] isEqualToString:@"A2iA_CheckAmount"]){
                strAmount  = [dict valueForKey:@"text"];
                break;
            }
        }
    }
    return strAmount;
}

// method to check if micr exist or not
-(BOOL)checkMICRExistOrNot:(NSString*)micr{
    
    CheckHistoryManager *chMgr = [[CheckHistoryManager alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ChecksHistory" inManagedObjectContext:chMgr.managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    [fetchRequest setEntity:entity];
    
    NSArray *historyArray = [chMgr.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (ChecksHistory *historyObject in historyArray) {
        NSString *micrFromHistory = [[historyObject.micrCode componentsSeparatedByCharactersInSet:
                                      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                     componentsJoinedByString:@""];
        NSLog(@"micrFromHistory = %@\nCurrent MICR = %@",micrFromHistory,micr);
        if ([micrFromHistory isEqualToString:micr]) {
            return YES;
            break;
        }
    }
    return NO;
}

// method is used for getting kfxKEDImagePerfectionProfile for rotation
-(kfxKEDImagePerfectionProfile*)getReProcessingProfile{
    
    kfxKEDImagePerfectionProfile * kPerfectionProf=nil;
    
    kPerfectionProf = [[kfxKEDImagePerfectionProfile alloc]initWithName:STATICPERFECTIONPROFILE andOperations:@"_DoBinarization_DeviceType_0_DoNoPageDetection__Do90DegreeRotation_3"];
    
    return kPerfectionProf;
}

// method for pop the current viewController
-(void)popVC{
    
    [AppUtilities removeActivityIndicator];
    [navigationController popToViewController:checkDepositInsVC animated:NO];
}

// show alert message with title and message with tag if any.
-(void)showAlertWithTitle:(NSString*)title andMessage:(NSString*)message andTag:(int)tag{
    [AppUtilities removeActivityIndicator];
    NSString *yesButton = Klm(@"YES");
    NSString *noButton = Klm(@"NO");
    
    if(tag == 6){
        yesButton = Klm(@"Retake");
        noButton = Klm(@"Use");
    }
    if(tag == 7 || tag == AlertTagAmountMismatch || tag == 2 || tag == 10){
        yesButton = Klm(@"OK");
        noButton = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:yesButton otherButtonTitles:noButton, nil];
        
        alertView.tag = tag;
        [alertView show];
    });
}

#pragma mark
#pragma mark Alert view delegate method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 0){ // Check back endorsement Not found case
        if(buttonIndex == 0){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //removing the processed back when extraction didnot finish as we may not need it further.
                if(self.appStateCD != CDEXTRACTED && self.appStateCD != CDNOOP)
                    [appStateMachine removeFilePathIfExists:[appStateMachine getFilePathWithType:BACK_PROCESSED mimeType:MIMETYPE_TIF]];
                
                [self discardCapturedImageAndShowCamera:YES];
            });
        }
        else{
            
            if ([self verifySignatureAndMicr:[self.currentProcessedImage getImageMetaData]] == 2)
            {
                dispatch_async(dispatch_get_main_queue() , ^{
                    [AppUtilities removeActivityIndicator];
                    [self showAlertWithTitle:Klm(@"Invalid check back") andMessage:Klm(@"This appears to be the front for the check. Please capture the back of the check") andTag:7];
                });
            }
            else
            {
                [self handleCheckBackOperations];
            }
        }
    }
    else if(alertView.tag == 1){ // Back/Cancel button clicked case
        if(buttonIndex == 0){
            [navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else if(alertView.tag == 2){ // Check deposited successfully case
        [navigationController popToRootViewControllerAnimated:YES];
    }
    else if(alertView.tag == 3){ // Check front signature/MICR/duplicate case
        if(buttonIndex == 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self discardCapturedImageAndShowCamera:YES];
            });
        }
        else{
            if( [appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF] ){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppUtilities addActivityIndicator];
                    if([[advancedSettings valueForKey:CHECKEXTRACTION] intValue] == 2){
                        [self reprocessCapturedImage];
                    }
                    else{
                        [self talkToRTTIwithFront:self.currentProcessedImage AndBack:nil];
                    }
                });
            }
            else{
                [self showSummaryScreen:nil withImage:self.currentProcessedImage andAnimation:NO];
            }
        }
    }
    else if(alertView.tag == 4){ // Extraction Failed case
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppUtilities removeActivityIndicator];
        });
        self.appStateCD = CDPROCESSED;
        [self showSummaryScreenOnExtractionFails];
    }
    else if (alertView.tag == 6){ // Quick Analysis feedback is oversatured or undersaturade
        
        if(buttonIndex == 0){
            
            if(self.appStateCD == CDPROCESSING){
                [imageProcessor cancelProcessing];
            }
            else if(self.appStateCD == CDPROCESSED || self.appStateCD == CDEXTRRACTING){
                [extractionManager cancelExtraction];
            }
            [navigationController popViewControllerAnimated:NO];
        }
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self useButtonClicked];
            });
        }
    }
    else if (alertView.tag == 7){ // check front captured for check back case
        
        _backCheckProcessed = NO;  //Resetting bool value when check front is captured instead of check back.
        
        [navigationController popViewControllerAnimated:NO];
    }
    else if (alertView.tag == AlertTagAmountMismatch){
        
        alertView = nil;
        [self checkForImageSummaryEnabled];
        
    }
    else if(alertView.tag == 10){
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [AppUtilities removeActivityIndicator];
            [self retakeButtonClicked];
        });
        
    }
    else if (alertView.tag == AlertTagAmountInMICR) {
        _showAmountInMicrAlert = NO;
        [self showMisMatchAlert];
    }
    else if (alertView.tag == AlertTagCheckRejectReason) {
        [self checkForImageSummaryEnabled];
    }
}

#pragma mark
#pragma mark ImageSummary

-(void)checkForImageSummaryEnabled {
    
    if([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Klm(@"Message") message:Klm(@"Would you like to send the images via mail for debugging?") delegate:checkDepositInsVC cancelButtonTitle:Klm(@"Yes") otherButtonTitles:Klm(@"No"), nil];
            alertView.tag=CheckDepositDebuggingTag;
            [alertView show];
        });
    }
    
}

#pragma mark-  Check  Reject Reason
-(void)showCheckRejectReason {
    
    NSString *strReasonForRejection = [self getCheckRejectReason];
    if(strReasonForRejection.length>0){
        NSString *strMessage = @"";
        
        if([strReasonForRejection isEqualToString:@"ImageTooLight"]){
            strMessage = Klm(@"Check image is too light. Please re-take the picture and submit again.");
        }
        else if([strReasonForRejection isEqualToString:@"ImageTooDark"]){
            strMessage = Klm(@"Check image is too dark. Please re-take the picture and submit again.");
        }
        else if([strReasonForRejection isEqualToString:@"CodeLineUsabilityFailure"]){
            strMessage = Klm(@"Codeline is not usable. Please re-take the picture and submit again.");
        }
        else if([strReasonForRejection isEqualToString:@"NotRecognizedAsCheck"]){
            strMessage = Klm(@"Deposit amount is not recognized. Please re-take the picture and submit again.");
        }
        else if([strReasonForRejection isEqualToString:@"InvalidTransit"]){
            strMessage = Klm(@"Transit number is invalid. Please try different check.");
        }
        else {
            strMessage = strReasonForRejection;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:Klm(@"Message") message:strMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil, nil];
            alertView.tag=AlertTagCheckRejectReason;
            [alertView show];
            alertView = nil;
            
        });
    }
    else {
        if(_showAmountInMicrAlert) {
            [self showAlertforAmountInMICR];
        }
        else {
            [self showMisMatchAlert];
        }
    }
}

-(NSString*)getCheckRejectReason{
    NSString *strCheckRejection = @"";
    if(!processedResults || [processedResults count] == 0){
        return strCheckRejection;
    }
    for (NSDictionary *dict in processedResults) {
        if([[dict allKeys] containsObject:@"name"]){
            if([[dict valueForKey:@"name"] isEqualToString:@"ReasonForRejection"]){
                strCheckRejection = [dict valueForKey:@"text"];
                break;
            }
        }
    }
    return strCheckRejection;
}

// method for sending request to server
-(void)sendToServer
{
    [self talkToRTTIwithFront:[appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_TIF] AndBack:[appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_TIF]];
}


@end
