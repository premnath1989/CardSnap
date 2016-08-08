//
//  DLManager.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "DLManager.h"
#import "BarcodeReaderViewController.h"
#import "kfxVRSMbl.h"
#import "DLSummaryViewController.h"
#import "ComponentSettingsViewController.h"
#import "DLRegionViewController.h"
#import "LicenceHelper.h"


//state machine logic to maintain different states of DL
typedef enum dlState{
    
    DLNOOP = 10,
    DLCAPTURING,
    DLCAPTURED,
    DLPROCESSING,
    DLPROCESSED,
    DLEXTRRACTING,
    DLEXTRACTED,
    DLEXTRACTIONFAILED,
    DLPROCESSING_USECLICKED,
    DLCANCELLED
    
}dlState;

//tags for different alerts
#define RTTIERRORALERT 111
#define QUICKANALYSISALERT 222
#define ODEALERT 333


static NSString * sessionKey = nil;

@interface DLManager()<DLSummaryProtocol,UIAlertViewDelegate,DLRegionProtocol>


@property (nonatomic,strong)  UINavigationController* navigationController;
@property (nonatomic,assign)  Component *componentObject;
@property (nonatomic,strong)  kfxKEDImagePerfectionProfile* imagePerfectionProfile;
@property (nonatomic,strong)  ImageProcessor* processor;
@property (nonatomic,strong)  AppParser* parser;
@property (nonatomic,strong)  ExtractionManager* extractionManager;
@property (nonatomic,strong)  DLData* dlDataObject;
@property (nonatomic,assign)  BOOL fromSelectedImageMethod,isForPreview,isFrontClicked;
@property (nonatomic,strong)  DLRegionAttributes* dlRegion;
@property (nonatomic,assign)  dlState currentDLState;
@property (nonatomic,assign)  BOOL isFrontProcessedInDisk;
@property (nonatomic,assign)  BOOL isBackProcessedInDisk;
@property (nonatomic,strong)  CaptureViewController* captureScreen;
@property (nonatomic,strong)  NSString *barcodeString;
@property (nonatomic,assign)  captureSides captureSide;
@property (nonatomic,strong)  AppStateMachine *appStateMachine;
@property (nonatomic,strong)  kfxKEDImage *currentCapturedImage;
@property (nonatomic,strong)  kfxKEDImage * temporaryImageHolder;
@property (nonatomic,strong)  NSArray * resultArray;
@property (nonatomic, strong) NSError *extractionError;

@end

@implementation DLManager


-(id)initWithComponent : (Component*)component
{
    if(self = [super init])
    {
        self.componentObject = component;
        [self setDefaults];
        
    }
    
    return self;
}

-(void)loadManager:(UINavigationController *)appNavController
{
    self.navigationController = appNavController;
    self.currentDLState = DLNOOP;
    self.barcodeString = @"";
    DLRegionViewController* dlRegionSelectionVc = [[DLRegionViewController alloc] init];
    dlRegionSelectionVc.delegate = self;
    dlRegionSelectionVc.selectedComponent = self.componentObject;
    [self.navigationController pushViewController:dlRegionSelectionVc animated:YES];
    
    self.appStateMachine = [AppStateMachine sharedInstance];
    self.appStateMachine.module = ID_CARD;
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    sessionKey = [[NSUUID UUID] UUIDString];
    
    [stats beginSession: sessionKey withCategory:@"MobileID"];
    
}

-(void)unloadManager
{
    self.navigationController = nil;
    self.extractionManager.delegate = nil;
    self.extractionManager = nil;
    self.parser.delegate = nil;
    self.parser = nil;
    self.processor.delegate = nil;
    self.processor = nil;
    self.captureScreen.delegate = nil;
    self.captureScreen = nil;
    self.currentCapturedImage = nil;
    self.navigationController = nil;
    self.imagePerfectionProfile = nil;
    self.dlDataObject = nil;
    self.dlRegion = nil;
    self.captureScreen.delegate = nil;
    self.captureScreen = nil;
    self.barcodeString = nil;
    
    [self.appStateMachine cleanUpDisk];
    
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    
    [stats endSession:TRUE withDescription:@"Complete"];
    
    
}



-(void)setDefaults
{
    self.isFrontProcessedInDisk = NO;
    self.isBackProcessedInDisk = NO;
    self.processor = [[ImageProcessor alloc] init];
    self.processor.delegate = self;
    self.parser = [[AppParser alloc] init];
    self.parser.delegate = self;
    self.extractionManager = [[ExtractionManager alloc] init];
    self.extractionManager.delegate = self;
}


- (BOOL)isODEEnabledForRegionSelected:(NSString*)region{
    BOOL isODEEnabled = NO;
    
    if ([region isEqualToString:@"Australia"] || [region isEqualToString:@"Asia"] || [region isEqualToString:@"United States"]) {
        isODEEnabled = YES;
    }
    
    return isODEEnabled;
}

- (BOOL)isKofaxMobileIdEnabledForRegionSelected:(NSString*)region{
    BOOL isKofaxMobileIdEnabled = NO;
    
    if ([region isEqualToString:@"United States"]) {
        isKofaxMobileIdEnabled = YES;
    }
    
    return isKofaxMobileIdEnabled;
}


#pragma mark
#pragma mark Region Selection Delegate methods

-(void)regionForDLSelected : (DLRegionAttributes *)dlRegion
{
    self.currentDLState = DLNOOP;
    self.dlRegion = dlRegion;
    self.captureSide = NONESIDE;
    [self showInstructions];
    
}

-(void)regionSelectionCancelled
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)regionSettingsClicked
{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:self.componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [self.navigationController pushViewController:componentSettingsController animated:YES];
}
#pragma mark
#pragma mark Instruction Delegate methods

-(void)assignCaptureSide:(captureSides)captureSideSelected {
    
    self.captureSide = captureSideSelected;
    [self onDLBackClicked];
}

-(void)onDLFrontClicked
{
    BOOL isModlesAvailable = [self checkForModels];
    if (isModlesAvailable) {
    self.fromSelectedImageMethod =NO;
    self.isFrontClicked=YES;
    if (self.captureSide == ONESIDE) {
        self.isBackProcessedInDisk = YES;
    }
    
    
    //Front has already been captured hence show preview
    if(self.isFrontProcessedInDisk)
    {
        self.isForPreview = YES;
        [self showPreviewFromSummary];
    }
    //no image captured yet show camera
    else
    {
        self.isForPreview = NO;
        self.currentDLState = CAPTURING;
        [self showCamera];
    }
    }
}

-(void)onDLBackClicked
{
    self.fromSelectedImageMethod = NO;
    
    
    //show barcode reader when the selected region is united states or canada
    if (self.captureSide == OTHERSIDEBARCODE) {
        
        self.currentDLState = CAPTURING;
        [self showBarcodeReader];
        
    }else{
        
        self.isFrontClicked=NO;
        
        //Back has already been captured hence show preview
        
        if(self.isBackProcessedInDisk)
        {
            self.isForPreview = YES;
            [self showPreviewFromSummary];
        }
        //no image captured yet show camera
        else
        {
            self.isForPreview = NO;
            self.currentDLState = CAPTURING;
            [self showCamera];
            
        }
    }
}

-(void)onSettingsClicked
{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:self.componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    componentSettingsController.isODEEnabledForSelectedRegion = [self isODEEnabledForRegionSelected:self.dlRegion.xRegion];
    componentSettingsController.isKofaxMobileIdEnabledForSelectedRegion = [self isKofaxMobileIdEnabledForRegionSelected:self.dlRegion.xRegion];
    [self.navigationController pushViewController:componentSettingsController animated:YES];
}

-(void)backButtonClicked
{
    //go back where we came from
    if(self.currentDLState == DLNOOP)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    //cancel everything clean up and go to home
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}
-(void)showCamera
{
    CaptureSettings* captureSettings = [[CaptureSettings alloc] init];
    captureSettings.showGallery = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
    captureSettings.useVideoFrame = YES; // This is not configurable from Settings , by default it is false.
    captureSettings.showAutoTorch = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:AUTOTORCH ] boolValue];
    if([self.dlRegion.strImageResize isEqualToString:ImageResizeGermanyOldID2]){
        
        captureSettings.staticFrameAspectRatio = DLASECTRATIO_GERMANY_ID2;
    }
    else {
        
        captureSettings.staticFrameAspectRatio = DLASPECTRATIO;
    }
    
    captureSettings.staticFramePaddingPercent = DLPADDINGPERCENT;
    
    captureSettings.captureExperience = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE ] intValue];
    captureSettings.manualCaptureTime = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
    captureSettings.edgeDetection = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:EDGEDETECTION]intValue];
    captureSettings.doShowGuidingDemo = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]boolValue];
    
    if ([[UIScreen mainScreen]bounds].size.height>480) {
        captureSettings.centerShiftValue = 35;
    }else{
        captureSettings.centerShiftValue = 25;
    }
    
    //customize texts
    if(self.currentDLState == DLCAPTURING && !self.isFrontClicked)
        captureSettings.userInstruction = Klm([self.componentObject.texts.cameraText valueForKey:USERINSTRUCTIONBACK]);
    else
        captureSettings.userInstruction = Klm([self.componentObject.texts.cameraText valueForKey:USERINSTRUCTIONFRONT]);
    
    captureSettings.cancelButtonText = Klm([self.componentObject.texts.cameraText valueForKey:CANCELBUTTON]);
    captureSettings.moveCloserMessage = Klm([self.componentObject.texts.cameraText valueForKey:MOVECLOSER]);
    captureSettings.holdSteadyMessage = Klm([self.componentObject.texts.cameraText valueForKey:HOLDSTEADY]);
    captureSettings.holdParallelMessage = Klm([self.componentObject.texts.cameraText valueForKey:HOLDPARALLEL]);
    captureSettings.orientationMessage = Klm([self.componentObject.texts.cameraText valueForKey:ORIENTATION]);

    captureSettings.centerMessage = Klm([self.componentObject.texts.cameraText valueForKey:CENTERMESSAGE]);
    captureSettings.zoomOutMessage = Klm([self.componentObject.texts.cameraText valueForKey:ZOOMOUTMESSAGE]);
    captureSettings.capturedMessage = Klm([self.componentObject.texts.cameraText valueForKey:CAPTUREDMESSAGE]);
    
    if (captureSettings.cancelButtonText.length == 0)
        captureSettings.cancelButtonText = Klm(@"Cancel");
    
    if ([[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE]intValue] == 0)
    {
        captureSettings.stabilityThresholdEnabled = YES;
        captureSettings.rollThresholdEnabled = YES;
        captureSettings.pitchThresholdEnabled = YES;
        captureSettings.focusConstraintEnabled = YES;

        captureSettings.offset = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]floatValue];
        
        captureSettings.stabilityThreshold = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:STABILITYDELAY]intValue];
        captureSettings.rollThreshold = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:ROLLTHRESHOLD]intValue];
        captureSettings.pitchThreshold = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:PITCHTHRESHOLD]intValue];

        captureSettings.longAxisThreshold = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]intValue];
        captureSettings.shortAxisThreshold = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:OFFSETTHRESHOLD]intValue];

        captureSettings.hideStaticFrame = false; // This is not configurable from Settings , So it should be shown always .
    }
    
    captureSettings.zoomMinFillFraction = 0.7;
    captureSettings.zoomMaxFillFraction = 1.1;
    
    if(self.captureScreen)
    {
        self.captureScreen.delegate = nil;
        self.captureScreen = nil;
    }
    
    self.captureScreen = [[CaptureViewController alloc] initWithCaptureSettings:captureSettings];
    self.captureScreen.delegate = self;
    if(_fromSelectedImageMethod)
        self.captureScreen.loadAlbum = YES;
    else
        self.captureScreen.loadAlbum = NO;
    [self.navigationController pushViewController:self.captureScreen animated:YES];
}

//Barcode is deprecated
-(void)showBarcodeReader
{
    BarcodeReaderViewController* barcodeController = [[BarcodeReaderViewController alloc] initWithNibName:@"BarcodeReaderViewController" bundle:nil];
    barcodeController.delegate = self;
    [self.navigationController pushViewController:barcodeController animated:YES];
    
}

// Navigates to Instruction screen once the captured image is processed
-(void)showInstructions
{
    if(self.currentDLState == DLNOOP)
    {
        DLInstructionsViewController* dlInstructions = [[DLInstructionsViewController alloc] initWithComponent:self.componentObject];
        dlInstructions.delegate = self;
        [self.navigationController pushViewController:dlInstructions animated:YES];
    }
    else
    {
        DLInstructionsViewController* dlInstructions = nil;
        BOOL isNavigationFound = NO;
        
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[DLInstructionsViewController class]]) {
                isNavigationFound = YES;
                dlInstructions = (DLInstructionsViewController*)aViewController;
                
                if(self.isFrontProcessedInDisk){
                    
                    dlInstructions.frontThumbnail = [[self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_JPG] getImageBitmap];
                    
                }
                else if(self.isBackProcessedInDisk){
                    
                    dlInstructions.backThumbnail = [[self.appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_JPG] getImageBitmap];
                    
                }
                else if(self.captureSide == OTHERSIDEBARCODE){
                    
                    if([self.appStateMachine isImageInDisk:BACK_RAW mimeType:MIMETYPE_JPG]) {
                        
                        dlInstructions.backThumbnail = [[self.appStateMachine getImage:BACK_RAW mimeType:MIMETYPE_JPG] getImageBitmap];
                    }
                    else {
                        
                        dlInstructions.backThumbnail = [self.currentCapturedImage getImageBitmap];
                    }
                    
                }
                
                [self.navigationController popToViewController:dlInstructions animated:YES];
            }
        }
        
        if(!isNavigationFound){
            
            self.currentDLState = DLNOOP ;
            
            DLInstructionsViewController* dlInstructions = [[DLInstructionsViewController alloc] initWithComponent:self.componentObject];
            dlInstructions.delegate = self;
            [self.navigationController pushViewController:dlInstructions animated:YES];
            
        }
        
    }
    
}


// Shows the summary screen , once the extraction is completed
-(void)showSummaryScreen
{
    
    self.fromSelectedImageMethod = NO;
    [AppUtilities removeActivityIndicator];
    
    DLSummaryViewController *summaryController = nil;
    DLInstructionsViewController *instructionController = nil;
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[DLSummaryViewController class]]) {
            summaryController = (DLSummaryViewController*)aViewController;
            summaryController.captureSide = self.captureSide;
            if(self.currentDLState == DLEXTRACTIONFAILED){
                summaryController.launchedByExtractionFailed = YES;
            }
            else {
                
                summaryController.launchedByExtractionFailed = NO;
            }
            
            summaryController.extractedError = self.extractionError;
            summaryController.frontProcessedImage = [self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_JPG];
            
            if (self.captureSide == OTHERSIDEBARCODE) {
                
                summaryController.barCodeImage = [self.appStateMachine getImage:BACK_RAW mimeType:MIMETYPE_JPG];
            }else{
                
                summaryController.barCodeImage = [self.appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_JPG];
                
            }
            
            if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
                
                summaryController.frontRawImage = [self.appStateMachine getImage:FRONT_RAW mimeType:MIMETYPE_JPG];
                
                if (self.captureSide == TWOSIDECAPTURE){
                    
                    summaryController.backRawImage = [self.appStateMachine getImage:BACK_RAW mimeType:MIMETYPE_JPG];
                }
            }
            
            summaryController.resultsArray = self.resultArray;
            
            [summaryController updateDLData:self.dlDataObject];
            
            // Image Summary Debugging feature check
            if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]){
                
                summaryController.shouldImageDebuggingShown = YES;
            }
            else {
                
                summaryController.shouldImageDebuggingShown = NO;
            }
            [self.navigationController popToViewController:summaryController animated:YES];
        }else if([aViewController isKindOfClass:[DLInstructionsViewController class]]){
            instructionController = (DLInstructionsViewController*)aViewController;
        }
    }
    if (!summaryController) {
        
        DLSummaryViewController* dlSummary = [[DLSummaryViewController alloc] initWithComponent:self.componentObject andDLData:self.dlDataObject];
        dlSummary.delegate = self;
        dlSummary.captureSide = self.captureSide;
        dlSummary.resultsArray = self.resultArray;

        if(self.currentDLState == DLEXTRACTIONFAILED){
            dlSummary.launchedByExtractionFailed = YES;
        }
        else {
            
            dlSummary.launchedByExtractionFailed = NO;
        }
        
        dlSummary.extractedError = self.extractionError;
        
        dlSummary.frontProcessedImage = [self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_JPG];
        
        if (self.captureSide == OTHERSIDEBARCODE) {
            
            dlSummary.barCodeImage = [self.appStateMachine getImage:BACK_RAW mimeType:MIMETYPE_JPG];
        }else{
            dlSummary.barCodeImage = [self.appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_JPG];
        }
        
        if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]) {
            
            dlSummary.frontRawImage = [self.appStateMachine getImage:FRONT_RAW mimeType:MIMETYPE_JPG];
            
            if (self.captureSide == TWOSIDECAPTURE){
                
                dlSummary.backRawImage = [self.appStateMachine getImage:BACK_RAW mimeType:MIMETYPE_JPG];
            }
        }
        
        // Image Summary Debugging feature check
        if([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:EVRSDEBUGGING] boolValue]){
            
            dlSummary.shouldImageDebuggingShown = YES;
        }
        else {
            
            dlSummary.shouldImageDebuggingShown = NO;
        }
        
        
        NSInteger index = [allViewControllers indexOfObject:instructionController];
        [allViewControllers replaceObjectAtIndex:index withObject:dlSummary];
        [self.navigationController setViewControllers:allViewControllers];
        [self.navigationController popToViewController:dlSummary animated:YES];
    }
}


#pragma mark Capture control protocol


// Call Back once the image is captured from camera
-(void) imageSelected:(kfxKEDImage *)capturedImage
{
    _fromSelectedImageMethod = YES;
    self.currentCapturedImage = capturedImage;
    
//    if(self.currentDLState == DLCAPTURING)
        self.currentDLState = DLCAPTURED;
    
    [self taskToBeDoneAfterCapturing];
    
    [self performSelectorOnMainThread:@selector(showPreviewFromCapture) withObject:nil waitUntilDone:YES]; //shwoing preview screen on main thread to avoid delay to launch the screen.
    
    
    
}

// Call back once the image is captured from alumb
-(void)imageCaptured:(kfxKEDImage *)capturedImage
{
    _fromSelectedImageMethod = NO;
    if(self.currentDLState == DLCAPTURING)
        self.currentDLState = DLCAPTURED;
    
    self.currentCapturedImage = capturedImage;
    
    [self taskToBeDoneAfterCapturing];
    
    [self showPreviewFromCapture];
}

-(void)taskToBeDoneAfterCapturing {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [self.appStateMachine storeToDisk:self.currentCapturedImage withType:self.isFrontClicked?FRONT_RAW:BACK_RAW mimeType:MIMETYPE_JPG];
        
    });
    
    if ([[[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS ] valueForKey:DOQUICKANALYSIS]boolValue])
    {
        [AppUtilities addActivityIndicator];
        [self.processor performQuickAnalysisOnImage:self.currentCapturedImage];
    }
    else
    {
        if(![AppUtilities isLowerEndDevice])
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [self scheduleProcessingInBackground];
            });
        }
        
    }
    
}

-(void)cancelCamera
{
    self.fromSelectedImageMethod = NO;
    [self cancelProcessing];
    [self cancelExtracting];
    ExhibitorViewController *exhibitorController = nil;
    NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *aViewController in allViewControllers) {
        if ([aViewController isKindOfClass:[ExhibitorViewController class]]) {
            exhibitorController = (ExhibitorViewController*)aViewController;
            exhibitorController.leftButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
            exhibitorController.rightButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:CANCELBUTTON]);
            
            if (exhibitorController.leftButtonTitle.length==0)
                exhibitorController.leftButtonTitle = Klm(@"Retake");
            
            if (exhibitorController.rightButtonTitle.length == 0)
                exhibitorController.rightButtonTitle = Klm(@"Cancel");
            
            exhibitorController.isCancelButtonShow = YES;
            exhibitorController.showTopBar = NO;
            exhibitorController.delegate = self;
            if(self.isFrontClicked){
                
                exhibitorController.inputImage = [self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_JPG];
            }
            else{
                exhibitorController.inputImage = [self.appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_JPG];
            }
            [self.navigationController popToViewController:exhibitorController animated:YES];
        }
    }
    
    if (!exhibitorController)
    {
        
        
        self.currentDLState = NOOP;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)cancelProcessing{
    if (self.currentDLState == DLPROCESSING || self.currentDLState == DLPROCESSING_USECLICKED) {
        [self.processor cancelProcessing];
        self.currentDLState = DLCANCELLED;
    }
}

- (void)cancelExtracting{
    if (self.currentDLState == DLEXTRRACTING) {
        [self.extractionManager cancelExtraction];
    }
}

-(void)showPreviewFromCapture
{
    
    if (self.isForPreview)
    {
        ExhibitorViewController *exhibitorController = nil;
        NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
        for (UIViewController *aViewController in allViewControllers) {
            if ([aViewController isKindOfClass:[ExhibitorViewController class]]) {
                exhibitorController = (ExhibitorViewController*)aViewController;
                
                if(!_fromSelectedImageMethod){
                    [exhibitorController removeNavigationBarItems];
                    exhibitorController.leftButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
                    exhibitorController.rightButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:FRONTUSEBUTTON]);
                    
                    if (exhibitorController.leftButtonTitle.length==0)
                        exhibitorController.leftButtonTitle = Klm(@"Retake");
                    
                    if (exhibitorController.rightButtonTitle.length == 0)
                        exhibitorController.rightButtonTitle = Klm(@"Use");
                    
                    exhibitorController.isCancelButtonShow = NO;
                }else {
                    
                    exhibitorController.showTopBar = YES;
                    exhibitorController.leftButtonTitle=@"";
                    exhibitorController.rightButtonTitle =@"";
                }
                exhibitorController.delegate = self;
                exhibitorController.inputImage = self.currentCapturedImage;
                [self.navigationController popToViewController:exhibitorController animated:YES];
            }
            
        }
    }
    else
    {
        ExhibitorViewController* previewVC = [[ExhibitorViewController alloc] initWithNibName:@"ExhibitorViewController" bundle:nil];
        previewVC.delegate = self;
        if(!self.fromSelectedImageMethod){
            previewVC.leftButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
            previewVC.rightButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:FRONTUSEBUTTON]);
            
            if (previewVC.leftButtonTitle.length==0)
                previewVC.leftButtonTitle = Klm(@"Retake");
            
            if (previewVC.rightButtonTitle.length == 0)
                previewVC.rightButtonTitle = Klm(@"Use");
        }
        else {
            
            previewVC.showTopBar = YES;
            previewVC.leftButtonTitle = @"";
            previewVC.rightButtonTitle=@"";
        }
        previewVC.inputImage = self.currentCapturedImage;
        [self.navigationController pushViewController:previewVC animated:YES];
    }
}

//This method shows the preview of the captured image if the preview is from summary it launches exhibitor in a different way
-(void)showPreviewFromSummary
{
    
    ExhibitorViewController* previewVC = [[ExhibitorViewController alloc] initWithNibName:@"ExhibitorViewController" bundle:nil];
    previewVC.delegate = self;
    previewVC.leftButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:FRONTRETAKEBUTTON]);
    previewVC.rightButtonTitle = Klm([self.componentObject.texts.previewText valueForKey:CANCELBUTTON]);
    
    if (previewVC.leftButtonTitle.length==0)
        previewVC.leftButtonTitle = Klm(@"Retake");
    
    if (previewVC.rightButtonTitle.length == 0)
        previewVC.rightButtonTitle = Klm(@"Cancel");
    
    previewVC.isCancelButtonShow = YES;
    
    previewVC.inputImage = self.isFrontClicked ? [self.appStateMachine getImage:FRONT_PROCESSED mimeType:MIMETYPE_JPG ]: [self.appStateMachine getImage:BACK_PROCESSED mimeType:MIMETYPE_JPG];
    [self.navigationController pushViewController:previewVC animated:YES];
    
    
}

-(BOOL)checkForModels{
    ExtractionManager *extractionManager = [[ExtractionManager alloc] init];
    if (![extractionManager isLocalVersionAvailable:kfxKOEIDRegion_US] && [self isODEActive]) {
        [AppUtilities removeActivityIndicator];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Download Models first to continue with ODE") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            
            [alertView show];
            
        });
        return NO;
    }else{
        return YES;
    }
}

#pragma mark
#pragma mark Summary protocol

-(void)licenseFrontThumbNailClicked
{
    
    BOOL isModlesAvailable = [self checkForModels];
    if (isModlesAvailable) {
    self.isFrontClicked = YES;
    if(self.isFrontProcessedInDisk){
        self.isForPreview = YES;
        [self showPreviewFromSummary];
    }
    else{
        
        self.isForPreview = NO;
        [self showCamera];
    }
    }
}

-(void)licenseBackThumbNailClicked
{
    if (self.captureSide == OTHERSIDEBARCODE) {
        
        self.currentDLState = CAPTURING;
        [self showBarcodeReader];
    }else{
        
        self.isFrontClicked = NO;
        if(self.isBackProcessedInDisk)
        {
            self.isForPreview = YES;
            [self showPreviewFromSummary];
        }
        else
        {
            self.isForPreview = NO;
            [self showCamera];
        }
    }
}

-(void)summaryCancelClicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self cleanUp];
}

-(void)submitButtonClicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    [self cleanUp];
    
}

-(void)settingsClicked
{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:self.componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    componentSettingsController.isODEEnabledForSelectedRegion = [self isODEEnabledForRegionSelected:self.dlRegion.xRegion];
    componentSettingsController.isKofaxMobileIdEnabledForSelectedRegion = [self isKofaxMobileIdEnabledForRegionSelected:self.dlRegion.xRegion];
    [self.navigationController pushViewController:componentSettingsController animated:YES];
}




#pragma mark
#pragma mark barcode delegate methods


-(void)barcodeFound :(kfxKEDBarcodeResult *)result withImage:(kfxKEDImage*)barcodeImage
{
    self.currentCapturedImage = barcodeImage;
    [self.appStateMachine storeToDisk:barcodeImage withType:BACK_RAW mimeType:MIMETYPE_JPG]; //Dispatch queue has been removed because writing to file process will be done in other thread. We can't get kfxKEDImage while image is in writing process.
    [kfxKEDBarcodeResult decodeDataFormat:[result dataFormat]];
    
    NSData *encodeData = [[NSData alloc]initWithBase64EncodedString:result.value options:0];
    self.barcodeString = [[NSString alloc]initWithData:encodeData encoding:NSUTF8StringEncoding];
    
    
    // Replace non-printable record separator character with a carriage return to avoid issues parsing the
    // request on the server
    self.barcodeString = [self.barcodeString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%C", 0x001e] withString:@"\r"];
    
    self.isBackProcessedInDisk = NO;
    
    if(self.isFrontProcessedInDisk){
        
        [AppUtilities addActivityIndicator];
        [self extractData];
    }else{
        [self showInstructions];
    }
    
}

-(void)skipButtonClicked{
    
    self.captureSide = ONESIDE;
    
    if (self.isFrontProcessedInDisk && !self.dlDataObject ) {
        
        [AppUtilities addActivityIndicator];
        self.isBackProcessedInDisk = YES;
        [self extractData];
    }
    
    
}

#pragma mark
#pragma mark Parser delegate methods

-(void)dlFrontParsed:(DLData *)dlFrontData
{
    self.dlDataObject = dlFrontData;
    self.dlDataObject.userPickedregion = self.dlRegion.xRegion;
    
    [AppUtilities removeActivityIndicator];
    //show summary set both front and back images setting nil wouldnot hurt
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showSummaryScreen];
    });
    
    
    
}

-(void)dlFrontParsingFailed
{
    //throw error
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:Klm(@"Response Error") message:Klm(@"Response received from server is not as expected") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
    [alert show];
}

//not used right now
//Barcode Parsing methods
-(void)barcodeParsed:(DLData *)dlBarcodeData
{
    NSLog(@"dldata is %@",dlBarcodeData.zipCode);
    [self mergeDLData:dlBarcodeData];
    //show summary set both front and back images setting nil wouldnot hurt
    [self showSummaryScreen];
}

-(void)barcodeParsingFailed
{
    //throw error
}

#pragma mark
#pragma mark Exhibitor methods

-(void)useSelectedPhotoButtonClicked
{
    [self useButtonClicked];
    
}
-(void)albumButtonClicked
{
    // handle album method
    [self retakeButtonClicked];
}
-(void)useButtonClicked
{
    if(self.currentDLState == DLPROCESSED && self.isFrontClicked)
    {
        //write to disk
        self.isFrontProcessedInDisk = [[AppStateMachine sharedInstance] storeImage:self.temporaryImageHolder withType:FRONT_PROCESSED mimeType:MIMETYPE_JPG];
        
        if((((![self.appStateMachine isImageInDisk:BACK_PROCESSED mimeType:MIMETYPE_JPG] && self.captureSide != OTHERSIDEBARCODE)||(![self.appStateMachine isImageInDisk:BACK_RAW mimeType:MIMETYPE_JPG] && self.captureSide == OTHERSIDEBARCODE)) && self.captureSide != ONESIDE))
        {
            [self showInstructions];
        }
        else
        {
            [AppUtilities addActivityIndicator];
            [self extractData];
        }
    }
    else if(self.currentDLState == DLPROCESSED && !self.isFrontClicked)
    {
        self.isBackProcessedInDisk = [[AppStateMachine sharedInstance] storeImage:self.temporaryImageHolder withType:BACK_PROCESSED mimeType:MIMETYPE_JPG];
        
        if(!self.isFrontProcessedInDisk)
        {
            [self showInstructions];
        }
        else
        {
            [AppUtilities addActivityIndicator];
            [self extractData];
        }
    }
    else if(self.currentDLState == DLCAPTURED)
    {
        self.currentDLState = DLPROCESSING_USECLICKED;
        [AppUtilities addActivityIndicator];
        [self scheduleProcessingInBackground];
    }
    else if (self.currentDLState == DLPROCESSING)
    {
        self.currentDLState = DLPROCESSING_USECLICKED;
        [AppUtilities addActivityIndicator];
    }
    else if(self.currentDLState == DLEXTRACTED || self.currentDLState == DLEXTRACTIONFAILED)
    {
        [self showSummaryScreen];
    }
    
    
}
-(void)retakeButtonClicked
{
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    kfxKUTAppStatsSessionEvent * evt = [[kfxKUTAppStatsSessionEvent alloc] init];
    evt.type = @"RETAKE";
    
    [stats logSessionEvent:evt];
    
    if (self.isForPreview)
    {
        [self cancelProcessing];
        self.currentDLState = DLCAPTURING;
        [self showCamera];
    }
    else
    {
        if(self.currentDLState == DLEXTRACTIONFAILED)
            self.currentDLState = DLCAPTURING;
        
        
        //Please check viewcontroller class type before you are directly using from navigation stack controllers.
        
        CaptureViewController * capVC = nil;
        UIViewController *aViewController = ([self.navigationController.viewControllers count] >= 2) ?[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2]:nil;
        
        if(aViewController && [aViewController isKindOfClass:[CaptureViewController class]]){
            
            capVC = (CaptureViewController*)aViewController;
            
            if(self.fromSelectedImageMethod) {
                self.currentDLState = DLCAPTURING;
                capVC.loadAlbum = YES;
            }
            else {
                capVC.loadAlbum=NO;
            }
            [self.navigationController popViewControllerAnimated:YES];
            
        }
        
        
    }
}

-(void)cancelButtonClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)scheduleProcessingInBackground
{
    
    if(self.currentDLState == DLCAPTURED){
        
        self.currentDLState = DLPROCESSING;
    }
    
    [self processImage];
}

//Process the image before classifying it
-(void)processImage
{
    if(self.processor){
        [self.processor processImage:self.currentCapturedImage withProfile:[self getImagePerfectionProfile] withFileName:nil mimeType:MIMETYPE_JPG];
    }
}


//The perfection profile is same for front and back (barcode)
-(kfxKEDImagePerfectionProfile*)getImagePerfectionProfile
{
    self.imagePerfectionProfile = nil;
    
    CGSize scaleSize;
    
    if([self.dlRegion.strImageResize isEqualToString:ImageResizeGermanyOldID2]){
        
        scaleSize = CGSizeMake(4.134, 2.913);
        
    }
    else
        scaleSize = CGSizeZero;
    
    NSString *opStr = @"" ;
    
    if ([self isODEActive]) {
        opStr = @"_DeviceType_2_Do90DegreeRotation_4_DoCropCorrection_DoDocumentDetectorBasedCrop_DoScaleImageToDPI_500_DoSkewCorrectionPage__DocDimLarge_3.375_DocDimSmall_2.125_LoadSetting_<Property Name=\"CSkewDetect.correct_illumination.Bool\" Value=\"0\" />";
    }else{
        opStr = [AppUtilities getEVRSImagePerfectionStringFromSettings:[self.componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] ofComponentType:IDCARD isFront:self.isFrontClicked withScaleSize:scaleSize withFrontImageWidth:nil];
    }
    self.imagePerfectionProfile = [[kfxKEDImagePerfectionProfile alloc]initWithName:STATICPERFECTIONPROFILE andOperations:opStr];
    return self.imagePerfectionProfile;
}



#pragma mark
#pragma mark image processor delegate

-(void)quickAnalysisResponse:(kfxKEDQuickAnalysisFeedback *)feedback
{
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
        
    }
}

-(void)processingSucceeded:(BOOL)status withOutputImage:(kfxKEDImage *)processedImage
{
    if(status)
    {
        self.temporaryImageHolder = processedImage;
        if(self.currentDLState == DLPROCESSING_USECLICKED){
            
            self.currentDLState = DLPROCESSED;
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppUtilities removeActivityIndicator];
                [self useButtonClicked];
            });
            
        }
        else {
            
            self.currentDLState = DLPROCESSED;
        }
        
    }
    else
    {
        //TODO throw error
        [AppUtilities removeActivityIndicator];
        NSLog(@"Processing failed");
    }
}


-(void)onDeviceExtraction
{
    
}

-(void)extractData
{
    
    if ([self isODEActive]) {
        
        NSLog(@"%@",self.dlRegion.xRegion);
        
        kfxKEDImage *frontImage = nil;
        kfxKEDImage *backImage = nil;
        
        kfxKOEIDRegion region = kfxKOEIDRegion_US;
        if ([self.dlRegion.xRegion isEqualToString:@"United States"]) {
            region = kfxKOEIDRegion_US;
        }
        else if ([self.dlRegion.xRegion isEqualToString:@"Asia"]){
            region = kfxKOEIDRegion_Asia;
        }
        else if ([self.dlRegion.xRegion isEqualToString:@"Australia"]){
            region = kfxKOEIDRegion_Australia;
        }
        
        if (![self.extractionManager isLocalVersionAvailable:kfxKOEIDRegion_US]) {
            [AppUtilities removeActivityIndicator];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Models are not downloaded,please download to Proceed to Extract") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                
                [alertView show];
                
            });
            return;
        }
        
        
        self.currentDLState = EXTRRACTING;
        self.extractionManager.delegate = self;
        
        
        if([self.appStateMachine isImageInDisk:FRONT_PROCESSED mimeType:MIMETYPE_JPG]){
            
            kfxKEDImage *odeFront = [[kfxKEDImage alloc] init];
            NSString *imagePath =  [self.appStateMachine getFilePathWithType:FRONT_PROCESSED mimeType:MIMETYPE_JPG];
            [odeFront specifyFilePath:imagePath];
            frontImage = odeFront;
            [frontImage imageReadFromFile];
            
            frontImage = [[kfxKEDImage alloc] initWithImage:[odeFront getImageBitmap]];
            
        }
        
        
        if (self.captureSide == OTHERSIDEBARCODE) {
            [self.extractionManager extractFieldsFrontImage:frontImage barcode:self.barcodeString region:region modelsType:(region == kfxKOEIDRegion_US ? SERVER:LOCAL) url:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:ODE_MODELS_SERVER_URL]]]];
        }else{
            int imageType = (self.captureSide == OTHERSIDEBARCODE) ? BACK_RAW : BACK_PROCESSED;
            if([self.appStateMachine isImageInDisk:imageType mimeType:MIMETYPE_JPG]) {
                
                kfxKEDImage *odeBack = [[kfxKEDImage alloc] init];
                NSString *imagePath =  [self.appStateMachine getFilePathWithType:imageType mimeType:MIMETYPE_JPG];
                [odeBack specifyFilePath:imagePath];
                backImage = odeBack;
                [backImage imageReadFromFile];
                
                backImage = [[kfxKEDImage alloc] initWithImage:[odeBack getImageBitmap]];
            }
            
            [self.extractionManager extractFieldsOnDeviceFrontImage:frontImage backImage:backImage region:region modelsType:(region == kfxKOEIDRegion_US ? SERVER:LOCAL) url:[NSURL URLWithString:[NSString stringWithFormat:@"%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:ODE_MODELS_SERVER_URL]]]];
        }
        
    }
    else{
        
        if([AppUtilities isConnectedToNetwork])
        {
            self.currentDLState = EXTRRACTING;
            self.extractionManager.delegate = self;
            
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            
            NSMutableArray *arrProcessed = [[NSMutableArray alloc]init];
            NSMutableArray *arrUnProccessed = [[NSMutableArray alloc]init];
            if([self.appStateMachine isImageInDisk:FRONT_PROCESSED mimeType:MIMETYPE_JPG]){
                
                [arrProcessed addObject:[self.appStateMachine getFilePathWithType:FRONT_PROCESSED mimeType:MIMETYPE_JPG]];
                if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue])
                    [arrUnProccessed addObject:[self.appStateMachine getFilePathWithType:FRONT_RAW mimeType:MIMETYPE_JPG]];
                
            }
            
            if([self.appStateMachine isImageInDisk:BACK_PROCESSED mimeType:MIMETYPE_JPG]) {
                
                [arrProcessed addObject:[self.appStateMachine getFilePathWithType:BACK_PROCESSED mimeType:MIMETYPE_JPG]];
                if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue])
                    [arrUnProccessed addObject:[self.appStateMachine getFilePathWithType:BACK_RAW mimeType:MIMETYPE_JPG]];
            }
            
            if ([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]) {
                
                
                
                [parameters setValue:self.dlRegion.xRegion forKey:@"Region"];
                
                //Uncomment this and replace @"Barcode results here" with actual string retrieved from Barcode
                if (self.captureSide == OTHERSIDEBARCODE) {
                    [parameters setValue:self.barcodeString forKey:@"Barcode"];
                }
                
                if(self.dlRegion.xState.length >0){
                    
                    [parameters setValue:self.dlRegion.xState forKey:@"State"];
                    
                }
                
                [parameters setValue:@"false" forKey:@"CropImage"];
                
                
                
                
                [parameters setValue:@"" forKey:DOCUMENT_NAME];
                [parameters setValue:@"" forKey:DOCUMENT_GROUP_NAME];
                
                //Sending for extraction if server type is KTA
                self.extractionManager.serverType = KTA;
                
                //We need to send login credentials to the server if the server type is KTA.
                NSString *serverUrl;
                if ([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:MOBILE_ID_TYPE] boolValue]) {
                    serverUrl = [NSString stringWithFormat:@"%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTA_KOFAX_SERVER_URL]];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTA_KOFAX_PROCESSNAME] forKey:PROCESS_IDENTITY_NAME];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTA_KOFAX_IDTYPE] forKey:PROCESS_ID_TYPE];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTA_KOFAX_USERNAME] forKey:USERNAME];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTA_KOFAX_PASSWORD] forKey:PASSWORD];
                }
                else{
                    serverUrl = [NSString stringWithFormat:@"%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPROCESSNAME] forKey:PROCESS_IDENTITY_NAME];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAIDTYPE] forKey:PROCESS_ID_TYPE];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAUSERNAME] forKey:USERNAME];
                    [parameters setValue:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTAPASSWORD] forKey:PASSWORD];
                    [parameters setValue:@"true" forKey:@"ExtractFaceImage"];
                    [parameters setValue:@"true" forKey:@"ExtractSignatureImage"];
                    [parameters setValue:self.dlRegion.strImageResize forKey:@"ImageResize"];
                }
                
                int errorStatus =  [self.extractionManager extractImageFilesWithProcessSync:arrProcessed saveOriginalImages:arrUnProccessed withURL:[NSURL URLWithString:serverUrl] withParams:parameters withMimeType:MIMETYPE_JPG];
                
                if(errorStatus != KMC_SUCCESS){
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [AppUtilities removeActivityIndicator];
                        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:[kfxError findErrMsg:errorStatus] delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                        
                        [alertView show];
                    });
                    
                }
                
                
                
                
            }else{
                
                if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SAVEORIGINALIMAGESWITCH] boolValue])
                    [parameters setValue:[NSString stringWithFormat:@"%ld",(long)arrProcessed.count] forKey:@"ProcessCount"];
                
                [parameters setValue:self.dlRegion.xRegion forKey:@"xregion"];
                
                //Uncomment this and replace @"Barcode results here" with actual string retrieved from Barcode
                if (self.captureSide == OTHERSIDEBARCODE) {
                    [parameters setValue:self.barcodeString forKey:@"xbarcode"];
                }
                
                if(self.dlRegion.xState.length >0){
                    
                    [parameters setValue:self.dlRegion.xState forKey:@"xstate"];
                    
                }
                
                
                
                if(self.dlRegion.strImageResize.length >0){
                    
                    [parameters setValue:self.dlRegion.strImageResize forKey:@"xImageResize"];
                }
                
                [parameters setValue:@"true" forKey:@"xExtractFaceImage"];
                [parameters setValue:@"true" forKey:@"xExtractSignatureImage"];
                
                
                //Sending for extraction if server type is RTTI
                self.extractionManager.serverType = RTTI;
                NSString *serverUrl;
                if ([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:MOBILE_ID_TYPE] boolValue]) {
                    serverUrl = [NSString stringWithFormat:@"%@%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:RTTI_KOFAX_SERVER_URL],@"?class=ID"];
                }
                else{
                    serverUrl = [NSString stringWithFormat:@"%@%@",[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL],@"?class=ID"];
                }
                
                
                if (sessionKey != nil)
                {
                    
                    [parameters setValue:sessionKey forKey:@"SessionKey"];
                    
                }
                
                int errorStatus =[self.extractionManager extractImageFilesWithProcessSync:arrProcessed saveOriginalImages:arrUnProccessed withURL:[NSURL URLWithString:serverUrl] withParams:parameters withMimeType:MIMETYPE_JPG];
                
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
            
        }
        else
        {
            NSLog(@"error");
            [self performSelectorOnMainThread:@selector(showAlert) withObject:nil waitUntilDone:YES];
        }
        
    }
}


#pragma mark
#pragma mark RTTI delegate methods
-(void)extractionSucceeded:(NSInteger)statusCode withResults:(id)results
{
    self.extractionError = nil;
    if (statusCode==REQUEST_SUCCESS) {
        self.currentDLState = DLEXTRACTED;
        [AppUtilities removeActivityIndicator];
        NSError *error;
        if ([results isKindOfClass:[NSData class]]) {
            NSArray* dlDictArray = [NSJSONSerialization JSONObjectWithData:results options:NSJSONReadingMutableContainers error:&error];
            if (dlDictArray.count) {
                NSDictionary *result = [dlDictArray objectAtIndex:0];
                self.resultArray = [result valueForKey:@"fields"];
            }
        }
        [self.parser parseDLFront:(NSData *)results];
        self.parser.delegate = self;
        
    }else if (statusCode==KMC_SUCCESS)
    {
        /// Parse the data
        self.currentDLState = DLEXTRACTED;
        if ([results isKindOfClass:[NSArray class]]) {
            self.resultArray = results;
            
        }
        [self.parser parseDLFrontWithODE:(NSArray*)results];
        self.parser.delegate = self;
    }
    else{
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
        self.extractionError = [NSError errorWithDomain:[[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:KTASERVERURL]:[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL] code:statusCode userInfo:userInfo];
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:Klm(@"Could not classify ID Card.") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
        alertView.tag = RTTIERRORALERT;
        [alertView show];
    }
}

-(void)extractionFailedWithError:(NSError *)error responseCode:(NSInteger)responseCode
{
    
    [AppUtilities removeActivityIndicator];
    self.currentDLState = DLEXTRACTIONFAILED;
    self.extractionError = error;
    self.dlDataObject = nil;
    self.resultArray=nil;
    NSString* errorMessage;
    
    if(responseCode == REQUEST_FAILURE)
    {
        errorMessage = Klm(@"Could not read the document.");
    }
    else if (responseCode == REQUEST_TIMEDOUT) {
        errorMessage = Klm(@"The Request timed out.");
    }else if(responseCode == NONETWORK){
        errorMessage = Klm(@"ID Card extraction cannot be performed because the app cannot connect to the network.");
    }else if (error.code > 0){
        
        errorMessage = [kfxError findErrMsg:error.code];
        
    }else{
        errorMessage = Klm([[[_componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVER_MODE]boolValue]?@"The KTA server may be offline or does not exist.":@"The RTTI server may be offline or does not exist.");
    }
    
    dispatch_async(dispatch_get_main_queue(),^{
        
        UIAlertView* rttiError = [[UIAlertView alloc] initWithTitle:Klm(@"Extraction Failed!!") message:errorMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
        rttiError.tag = RTTIERRORALERT;
        [rttiError show];
    });
    
}

#pragma mark
#pragma mark  merge DL data
-(void)mergeDLData :(DLData*)dlData
{
    if(self.dlDataObject)
    {
        //merge here
        [self.dlDataObject mergeDataWithObject:dlData];
    }
    else
    {
        //no earlier data so just copy the latest data
        self.dlDataObject = dlData;
    }
}

#pragma mark
#pragma mark Alerts and Alert View delegate

-(void)addQuickAnalysisALert:(NSString*)quickFeedback
{
    [AppUtilities removeActivityIndicator];
    
    UIAlertView * quickAlert = [[UIAlertView alloc] initWithTitle:Klm(@"Quick Analysis Feedback") message:quickFeedback delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Retake"), Klm(@"Use"), nil ];
    quickAlert.tag = QUICKANALYSISALERT;
    [quickAlert show];
    
}

-(void)showAlert
{
    [AppUtilities removeActivityIndicator];
    UIAlertView* networkError = [[UIAlertView alloc] initWithTitle:Klm(@"Extraction failed") message:Klm(@"ID Card extraction cannot be performed because the app cannot connect to the network.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
    [networkError show];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //Retake clicked
    if(alertView.tag == RTTIERRORALERT)
    {
        [self showSummaryScreen];
    }
    else if(alertView.tag == QUICKANALYSISALERT)
    {
        if(buttonIndex == 0)
        {
            [self retakeButtonClicked];
        }
        else
            [self useButtonClicked];
    }
    else
    {
        if(buttonIndex == 0)
        {
            //Launch Camera
            [AppUtilities removeActivityIndicator];
            if (self.isForPreview) {
                [self showCamera];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        
    }
    
    
}

-(BOOL)isODEActive
{
    BOOL odeActive = NO;
    if (((NSNumber*)[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE]).integerValue == [NSNumber numberWithInt:2].integerValue) {
        odeActive = YES;
    }
    return odeActive;
}

-(BOOL)isKofaxMobileIdActive
{
    BOOL kofaxMobileIdActive = NO;
    if ([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:MOBILE_ID_TYPE] boolValue]) {
        kofaxMobileIdActive = YES;
    }
    return kofaxMobileIdActive;
}

#pragma mark
#pragma mark cleanup methods
-(void)cleanUp
{
    self.imagePerfectionProfile = nil;
    self.navigationController = nil;
    self.currentCapturedImage = nil;
    self.extractionManager = nil;
    self.processor = nil;
    self.parser = nil;
    self.dlDataObject = nil;
}



-(void)dealloc
{
    NSLog(@"dealloc called");
    self.imagePerfectionProfile = nil;
    self.componentObject = nil;
    self.dlDataObject = nil;
    self.currentCapturedImage = nil;
}

@end
