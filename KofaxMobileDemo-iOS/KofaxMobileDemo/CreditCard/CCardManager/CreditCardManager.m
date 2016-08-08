//
//  CCardManager.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CreditCardManager.h"

#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibLogistics/kfxLogistics.h>
#import <kfxLibUtilities/kfxUtilities.h>
#import "CreditCardInstructionsViewController.h"

#import "CreditCardCaptureViewController.h"

#import "CreditCardManualEntryViewController.h"

#import "ComponentSettingsViewController.h"


#import "CreditCardSummaryViewController.h"

#import "AppStateMachine.h"

#import "CaptureSettings.h"

#import "CaptureViewController.h"

#import "ExtractionManager.h"

#import "ImageProcessor.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


static CreditCardManager *creditCardManager = nil;
static NSString * sessionKey = nil;

@interface CreditCardManager ()<CreditCardInstructionsProtocol,CreditCardSummaryProtocol,CreditCardManualEntryProtocol,UIAlertViewDelegate,CreditCardProtocol,CaptureViewControllerProtocol,ExtractionManagerProtocol,ImageProcessorProtocol>

@property (nonatomic, assign)UINavigationController *navigationController;
@property (nonatomic,strong) AppStateMachine *appStateMachine;
@property (nonatomic,assign) Component *componentObject;

@property (nonatomic,strong) NSMutableDictionary *creditCardInfo;
@property (assign) BOOL fromSummaryScreen;

@property(nonatomic,strong) NSError *extractionError;
@property(nonatomic,strong) ExtractionManager *extractionManager;
@property(nonatomic,strong) NSMutableArray *processedResults;
@property(nonatomic,strong) ImageProcessor *imageProcessor;
@property(nonatomic) BOOL isFromPreview,isUseButtonClicked,isRetakeImage;
@property(nonatomic,strong)kfxKEDImage *capturedImage_Processed,*capturedImage_Raw;
@property(nonatomic) NSInteger extractedStatusCode;



@property (assign) BOOL fromImageSelectedMethod;





@end

@implementation CreditCardManager
@synthesize navigationController;
@synthesize appStateMachine;
@synthesize componentObject;
@synthesize extractionError;
@synthesize extractionManager;
@synthesize processedResults;
@synthesize imageProcessor;
@synthesize isFromPreview,isUseButtonClicked,isRetakeImage;
@synthesize capturedImage_Processed,capturedImage_Raw;
@synthesize extractedStatusCode;


#pragma mark
#pragma mark CreditCardInsDelegate Method

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
    
    self.creditCardInfo = nil;
    self.extractionError = nil;
    self.extractionManager.delegate = nil;
    self.processedResults = nil;
    [self clearRawImage];
    [self clearProcessedImage];
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    [stats endSession:TRUE withDescription:@"Complete"];
    
    sessionKey=nil;

}

-(void)loadCreditCardManager:(UINavigationController*)appNavController andComponent:(Component*)currentComponent{
    
    //Configuring App's State
    appStateMachine = [AppStateMachine sharedInstance];
    
    appStateMachine.isFront = YES;
    appStateMachine.module = CREDIT_CARD;
    appStateMachine.appState = NOOP;
    navigationController = appNavController;
    componentObject = currentComponent;
    
    self.creditCardInfo = [[NSMutableDictionary alloc] init];
    self.fromSummaryScreen = NO;
    
    [self showInstructions:navigationController];
    
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    sessionKey = [[NSUUID UUID] UUIDString];
    
    [stats beginSession: sessionKey withCategory:@"CREDIT CARD"];
    
    
}

#pragma mark Load Credit Card instructions

-(void)showInstructions:(UINavigationController*)appNavController{
    
    CreditCardInstructionsViewController *creditCardInsVC = [[CreditCardInstructionsViewController alloc] initWithComponent:componentObject];
    creditCardInsVC.delegate = self;
    [appNavController pushViewController:creditCardInsVC animated:YES];
}

#pragma mark CreditCard Instructions Delegate Methods

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
    
    /*Check extraction type.
      If extraction type is cardIO then launch CardIO capture experience.
      If extraction type is RTTI then launch Uniform Guidance Capture Experience
    */
    if(![[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE] boolValue]){
        
        //Capture Settings are not configurable.So default settings are used
        
        CaptureSettings* captureSettings = [[CaptureSettings alloc] init];
        captureSettings.showGallery = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWGALLERY ] boolValue];
        captureSettings.useVideoFrame = false; // This is not configurable from Settings , by default it is false.
        captureSettings.showFlashOptions = YES;
        captureSettings.showAutoTorch = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:AUTOTORCH ] boolValue];
        captureSettings.captureExperience = [[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE ] intValue];
        captureSettings.tutorialSampleImage=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Creditcard" ofType:@"png"]];
        
        captureSettings.moveCloserMessage = Klm([componentObject.texts.cameraText valueForKey:MOVECLOSER]);
        captureSettings.holdSteadyMessage = Klm([componentObject.texts.cameraText valueForKey:HOLDSTEADY]);
        captureSettings.cancelButtonText = Klm([componentObject.texts.cameraText valueForKey:CANCELBUTTON]);
        captureSettings.userInstruction = Klm([componentObject.texts.cameraText valueForKey:USERINSTRUCTIONFRONT]);
        captureSettings.centerMessage = Klm([componentObject.texts.cameraText valueForKey:CENTERMESSAGE]);
        captureSettings.zoomOutMessage = Klm([componentObject.texts.cameraText valueForKey:ZOOMOUTMESSAGE]);
        captureSettings.capturedMessage = Klm([componentObject.texts.cameraText valueForKey:CAPTUREDMESSAGE]);
        captureSettings.holdParallelMessage = Klm([componentObject.texts.cameraText valueForKey:HOLDPARALLEL]);
        captureSettings.orientationMessage = Klm([componentObject.texts.cameraText valueForKey:ORIENTATION]);
        
        captureSettings.manualCaptureTime = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:MANUALCAPTURETIMER]intValue];
         captureSettings.doShowGuidingDemo = [[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:SHOWCHECKGUIDINGDEMO]intValue];
        captureSettings.centerShiftValue = 0;
        captureSettings.doContinuousCapture = YES;
        
        //Setting default values for zoomMinFillFraction(0.2) and zoomMaxFillFraction(1.5)
        captureSettings.zoomMinFillFraction = 0.2;
        captureSettings.zoomMaxFillFraction = 1.5;
        
        if ([[[self.componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:CAPTUREEXPERIENCE]intValue] == 0){
            
            captureSettings.hideStaticFrame = false;
            captureSettings.staticFrameAspectRatio=[[[componentObject.settings.settingsDictionary valueForKey:CAMERASETTINGS]valueForKey:FRAMEASPECTRATIO]floatValue];
            
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
        
        CaptureViewController* captureScreen = [[CaptureViewController alloc] initWithCaptureSettings:captureSettings];
        captureScreen.delegate = self;
        [navigationController pushViewController:captureScreen animated:YES];
    
    }
    else{
        CreditCardCaptureViewController *cCardCapture = [[CreditCardCaptureViewController alloc]initWithNibName:@"CreditCardCaptureViewController" bundle:nil];
        cCardCapture.delegate = self;
        [self.navigationController pushViewController:cCardCapture animated:YES];
    }
}


#pragma mark
#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(alertView.tag==333 || alertView.tag == 111){
        if (buttonIndex==0) {
            
            [self clearProcessedImage];
            [self clearRawImage];
            [appStateMachine cleanUpDisk];
            
            if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.3")){
                [navigationController popToRootViewControllerAnimated:NO];
            }
            else{
                [navigationController popToRootViewControllerAnimated:YES];
            }
        }
    }
    else if(alertView.tag==222){
        if (buttonIndex==0) {
            [self retakeButtonClicked];
        }else if(buttonIndex==1){
            [self useButtonClicked];
        }
    }
    else if(alertView.tag == EXTRACTION_FAILED_TAG){
        [self showSummaryScreenWithAnimation:YES];
    }
}

#pragma mark--
#pragma mark--Image capture control delegate methods

-(void) imageSelected:(kfxKEDImage *)capturedImage
{
    capturedImage_Raw = capturedImage;
    _fromImageSelectedMethod = YES;
    
    //Check for "DoProcess" option.If true then process the image and send it for extraction,else send the captured image for extraction
    if([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:DOPROCESS] integerValue])
        [self processImageBasedOnSettingsWithImage];
    else
        [self extractData:capturedImage_Raw];
}


-(void)imageCaptured:(kfxKEDImage*)capturedImage{
    
    capturedImage_Raw=capturedImage;
    
    _fromImageSelectedMethod = NO;
    
    //Check for "DoProcess" option.If true then process the image and send it for extraction,else send the captured image for extraction
    if([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:DOPROCESS] integerValue])
        [self processImageBasedOnSettingsWithImage];
    else{
        capturedImage_Processed=capturedImage_Raw;
        [self showPreview:capturedImage_Raw];
        [self extractData:capturedImage_Raw];
    }
    
}


#pragma mark Processor methods

// Processes the image with given settings
- (void)processImageBasedOnSettingsWithImage{
    
    appStateMachine.appState = CAPTURED;
    isUseButtonClicked = NO;
    
    
    if ([[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS ] valueForKey:DOQUICKANALYSIS]boolValue]) {
        [AppUtilities addActivityIndicator];
        if (!imageProcessor)
            imageProcessor = [[ImageProcessor alloc] init];
        imageProcessor.delegate = self;
        [imageProcessor performQuickAnalysisOnImage:capturedImage_Raw];
    }else{
        if(![AppUtilities isLowerEndDevice]){
            [self processCapturedImage];
        }
            
    }
   
    
    [self showPreview:capturedImage_Raw];
}



//Get image perfection profile string
-(kfxKEDImagePerfectionProfile*)getProcessingProfile{
    
    kfxKEDImagePerfectionProfile * kPerfectionProf=nil;
    //Form ipOperations string from settings
    NSString * opStr = [AppUtilities getEVRSImagePerfectionStringFromSettings:[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] ofComponentType:CREDITCARD isFront:appStateMachine.isFront withScaleSize:CGSizeZero withFrontImageWidth:nil];
    //Create ImagePerfectionProfile with ipp string formed
    kPerfectionProf = [[kfxKEDImagePerfectionProfile alloc]initWithName:STATICPERFECTIONPROFILE andOperations:opStr];
    
    return kPerfectionProf;
}

// This callback fires if processing status is success/failure.
// if status is NO - Processing Failed.
// if status is YES - Image processed successfully.

-(void)processingSucceeded:(BOOL)status withOutputImage:(kfxKEDImage*)processedImage{
    
    //If image is processed successfully
    //Change the app state from 'PROCESSING' to 'PROCESSED'
    if (status){
        appStateMachine.appState = PROCESSED;
        //Extract data from processed image if processing is succesful
        capturedImage_Processed = processedImage;
        capturedImage_Processed.imageMimeType = MIMETYPE_TIF;
        if (isUseButtonClicked) {
            [self extractData:processedImage];
        }
    }
    //If processing fails then remove activity indicator
    //Change the app state from 'PROCESSING' to 'CAPTURED'
    else{
        [AppUtilities removeActivityIndicator];
        appStateMachine.appState = CAPTURED;
    }
}


#pragma mark Data Extraction Method

-(void)extractData:(kfxKEDImage*)image {
    
    extractionError = nil;
    
    extractedStatusCode = 0;
    
    appStateMachine.appState = EXTRRACTING;
    
    if (!extractionManager)
        extractionManager = [[ExtractionManager alloc] init];
    
    extractionManager.delegate = self;
    
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    
    if (sessionKey != nil)
    {
        
        [parameters setValue:sessionKey forKey:@"SessionKey"];
        
    }
    
    
    NSArray *extractMethodTypes=[[NSArray alloc]initWithObjects:@"Embossed",@"NonEmbossed",@"Detect", nil];
    NSString *extractMethodType=[extractMethodTypes objectAtIndex:[[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:EXTRACTMETHOD] integerValue]];
    NSString *processOnServerSide=[NSString stringWithFormat:@"%s",[[[componentObject.settings.settingsDictionary valueForKey:EVRSSETTINGS] valueForKey:DOPROCESS] integerValue]?"false":"true"];
    
    [parameters setValue:extractMethodType forKey:@"xExtractMethod"];
    [parameters setValue:processOnServerSide forKey:@"xImagePerfection"];
    
    NSString *serverUrl = [NSString stringWithFormat:@"%@",[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL]];
    
    NSLog(@"The server url is %@",serverUrl);
    
    [extractionManager extractImagesData:[[NSMutableArray alloc]initWithObjects:image, nil] saveOriginalImages:nil withURL:[NSURL URLWithString:serverUrl] withParams:parameters withMimeType:MIMETYPE_TIF];
    
    parameters = nil;
}

#pragma mark RTTI Manager Delegate Methods

-(void)extractionSucceeded:(NSInteger)statusCode withResults:(NSData *)resultsData{
    
    appStateMachine.appState = EXTRACTED;
    extractedStatusCode=statusCode;
    
    if (statusCode==REQUEST_SUCCESS) {
        
        extractionError = nil;
       
        [self parseResponseData:resultsData];
        
        
        KFXCreditCard *creditCardData=[[KFXCreditCard alloc]init];
        
        for(NSDictionary *resultsDictionary in processedResults){
            if([[resultsDictionary valueForKey:@"name"] isEqualToString:@"CardNumber"]){
                
                creditCardData.cardNumber=[resultsDictionary valueForKey:@"text"];
                [self.creditCardInfo setValue:[resultsDictionary valueForKey:@"valid"] forKey:CREDITCARDNUMBERVALID];
            }
            if([[resultsDictionary valueForKey:@"name"] isEqualToString:@"ExpirationDate"]){

                NSArray *items = [[resultsDictionary valueForKey:@"text"] componentsSeparatedByString:@"/"];
                if(items.count==2){
                    creditCardData.expirationYear=[items objectAtIndex:1];
                    creditCardData.expirationMonth=[items objectAtIndex:0];
                }
                
                [self.creditCardInfo setValue:[resultsDictionary valueForKey:@"valid"] forKey:CREDITCARDEXPIRYDATEVALID];
                
            }
            if([[resultsDictionary valueForKey:@"name"] isEqualToString:@"CardNetwork"]){
                creditCardData.cardNetwork=[resultsDictionary valueForKey:@"text"];
                [self.creditCardInfo setValue:[resultsDictionary valueForKey:@"valid"] forKey:CREDITCARDNETWORKVALID];
            }
        }
        creditCardData.cvv=@"";
        
       
        
        //Update credit card data
        [self setCreditCardData:creditCardData];
        
        if (isUseButtonClicked) {
            
            [self storeImages];
            [AppUtilities removeActivityIndicator];
            
            [self showSummaryScreenWithAnimation:YES];
        }

        

        
    }else{
        
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSHTTPURLResponse localizedStringForStatusCode:statusCode] forKey:NSLocalizedDescriptionKey];
        extractionError = [NSError errorWithDomain:[[componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS]valueForKey:SERVERURL] code:statusCode userInfo:userInfo];

        if (isUseButtonClicked) {
            [AppUtilities removeActivityIndicator];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Could not read the card.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
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
        errorMessage = Klm(@"Could not read the card.");
    }
    else if (extractionError.code == REQUEST_TIMEDOUT) {
        errorMessage = Klm(@"The Request timed out.");
    }else if(extractionError.code == NONETWORK){
        errorMessage = Klm(@"Credit Card Cannot be extracted as the device cannot connect to the network.");
    }else if (extractionError.code > 0){
        
        errorMessage = [kfxError findErrMsg:extractionError.code];
        
    }else{
        errorMessage = Klm(@"The RTTI server may be offline or does not exist.");
    }
    
    if (isUseButtonClicked) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [AppUtilities removeActivityIndicator];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:errorMessage delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            [alert show];
            
            [self storeImages];
            
        });
    }
    
        
    
}


-(void)clearRawImage {
    
    if(self.capturedImage_Raw) {
        
        [self.capturedImage_Raw clearImageBitmap];
        self.capturedImage_Raw = nil;
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

#pragma mark
#pragma mark CreditCardProtocol Methods
-(void)cancelCardCapture{
    
    if(self.fromSummaryScreen){
        
        CreditCardSummaryViewController *summaryController = [[CreditCardSummaryViewController alloc]initWithComponent:componentObject andCreditCard:self.creditCardInfo];
        summaryController.delegate = self;
        [self.navigationController pushViewController:summaryController animated:NO];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }

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
        
        
        
        [navigationController pushViewController:exhibitorObj animated:NO];
    }else{
        
        extractionError = nil;
        extractionManager = nil;
        imageProcessor = nil;
        processedResults = nil;
        
        [navigationController setNavigationBarHidden:NO animated:YES];
        [navigationController popViewControllerAnimated:YES];
        
    }
    appStateMachine.appState = NOOP;
}

-(void)creditCardCaptureComplete:(KFXCreditCard *)creditCard{
    
    [self setCreditCardData:creditCard];
    
    CreditCardSummaryViewController *summaryController = [[CreditCardSummaryViewController alloc]initWithComponent:componentObject andCreditCard:self.creditCardInfo];
    summaryController.delegate = self;
    [self.navigationController pushViewController:summaryController animated:YES];
    
    /*
    CCardManualEntryViewController *manualEntryController = [[CCardManualEntryViewController alloc]initWithCreditCard:creditCard andComponent:self.componentObject];
    manualEntryController.delegate = self;
    [self.navigationController pushViewController:manualEntryController animated:YES];
    */
}

-(void)setCreditCardData:(KFXCreditCard *)creditCard{
    
    NSLog(@"\nCC Info:\neYear : %@\neMonth : %@\nnumber : %@\n",creditCard.expirationYear,creditCard.expirationMonth,creditCard.cardNumber);
    NSString *expYear = creditCard.expirationYear;
    
    if(creditCard.expirationYear && ![creditCard.expirationYear isEqualToString:@""]){
        if([[[self.componentObject.settings.settingsDictionary valueForKey:RTTISETTINGS] valueForKey:SERVER_MODE] boolValue]){
            expYear = [NSString stringWithFormat:@"%d",[creditCard.expirationYear intValue]%100];
        }

    }
    
    NSString *expDate = @"";
    
    if(![expYear isEqualToString:@""] && creditCard.expirationMonth && ![creditCard.expirationMonth isEqualToString:@""]){
        
        expDate = [NSString stringWithFormat:@"%@ / %@",creditCard.expirationMonth,expYear];
    }
    
    [self.creditCardInfo setValue:creditCard.cardNumber forKey:@"cardNumber"];
    [self.creditCardInfo setValue:expDate forKey:@"expiryDate"];
    [self.creditCardInfo setValue:creditCard.cvv forKey:@"cvv"];
    [self.creditCardInfo setValue:@"" forKey:@"amount"];
    [self.creditCardInfo setValue:creditCard.cardNetwork forKey:@"cardNetwork"];

}

#pragma mark
#pragma mark CreditCardManualEntryProtocol Methods
-(void)manualCancelButtonClicked{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm(@"Do you want to cancel the credit card payment?") delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Yes"), Klm(@"No"), nil ];
    alert.tag = 333;
    [alert show];
}

-(void)manualDoneButtonClicked:(KFXCreditCard*)creditCard{
    
    NSMutableDictionary *creditCardInfo = [[NSMutableDictionary alloc]init];
    [creditCardInfo setValue:creditCard.cardNumber forKey:@"cardNumber"];
    [creditCardInfo setValue:[NSString stringWithFormat:@"%@ / %@",creditCard.expirationMonth,creditCard.expirationYear] forKey:@"expiryDate"];
    [creditCardInfo setValue:creditCard.cvv forKey:@"cvv"];
    [creditCardInfo setValue:@"" forKey:@"amount"];
    CreditCardSummaryViewController *summaryController = [[CreditCardSummaryViewController alloc]initWithComponent:componentObject andCreditCard:creditCardInfo];
    summaryController.delegate = self;
    [self.navigationController pushViewController:summaryController animated:YES];
}

#pragma mark
#pragma mark CreditCardSummaryProtocol Methods

-(void)summaryRetakeButtonClicked{
    kfxKUTAppStatistics * stats = [kfxKUTAppStatistics appStatisticsInstance];
    kfxKUTAppStatsSessionEvent * evt = [[kfxKUTAppStatsSessionEvent alloc] init];
    evt.type = @"RETAKE";
    
    [stats logSessionEvent:evt];
    self.fromSummaryScreen = YES;
    [self.navigationController popViewControllerAnimated:NO];
}
-(void)summaryCancelButtonClicked{
    
    // Go back to the previous (manual entry) screen...
//    [navigationController popViewControllerAnimated: true];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:nil message:Klm([componentObject.texts.summaryText valueForKey:SUBMITCANCELALERTTEXT]) delegate:self cancelButtonTitle:nil otherButtonTitles:Klm(@"Yes"), Klm(@"No"), nil ];
    alert.tag = 333;
    [alert show];
    
}

-(void)summarySettingsButtonClicked{
    ComponentSettingsViewController *componentSettingsController = [[ComponentSettingsViewController alloc] initWithComponent:componentObject andTheme:[[ProfileManager sharedInstance]getActiveProfile].theme];
    [navigationController pushViewController:componentSettingsController animated:YES];
}

-(void)summarySubmitButtonClicked{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:Klm([componentObject.texts.summaryText valueForKey:SUBMITALERTTEXT]) delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles: nil];
    alert.tag = 111;
    [alert show];
}

-(void)summaryPreviewButtonClicked{
    
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
    
    [navigationController popViewControllerAnimated:NO];
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
        
        if (appStateMachine.appState == EXTRACTED) {
            
            if (extractedStatusCode==200) {
                [self storeImages];
                [AppUtilities removeActivityIndicator];
                [self showSummaryScreenWithAnimation:YES];
            }else if(extractionError.code == -1009 || self.extractedStatusCode == 0){
                [self extractData:capturedImage_Processed];
            }else if(extractionError){
                [AppUtilities removeActivityIndicator];
                NSString *errorMessage;
                if (extractionError.code == -1001) {
                    errorMessage = Klm(@"The Request timed out.");
                }else{
                    errorMessage = Klm(@"The RTTI server may be offline or does not exist.");
                }
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:Klm(@"Extraction failed") message:errorMessage delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                alert.tag = EXTRACTION_FAILED_TAG;
                [alert show];
            }else{
                [AppUtilities removeActivityIndicator];
                UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Could not read the card") delegate:self cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
                alertView.tag = EXTRACTION_FAILED_TAG;
                [alertView show];
            }
        }else if(appStateMachine.appState == PROCESSED){
            [self extractData:capturedImage_Processed];
        }else if(appStateMachine.appState == CAPTURED){
            [self processCapturedImage];
        }
    }else{
        UIAlertView* networkError = [[UIAlertView alloc] initWithTitle:Klm(@"Network Alert!!") message:Klm(@"Credit Card Cannot be extracted as the device cannot connect to the network.") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
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
    [self showSummaryScreenWithAnimation:NO];
}


-(void)showSummaryScreenWithAnimation:(BOOL)animation{
    
    CreditCardSummaryViewController *creditCardSummary;
    creditCardSummary = [[CreditCardSummaryViewController alloc]initWithComponent:componentObject andCreditCard:self.creditCardInfo];
    creditCardSummary.delegate = self;
    [navigationController pushViewController:creditCardSummary animated:animation];
}

-(void)storeImages{
    
    [appStateMachine storeImage:capturedImage_Processed withType:FRONT_PROCESSED mimeType:MIMETYPE_TIF];
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

-(void)clearProcessedImage {
    
    if(self.capturedImage_Processed) {
        
        [self.capturedImage_Processed clearImageBitmap];
        self.capturedImage_Processed = nil;
    }
    
}



@end
