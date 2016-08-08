//
//  CaptureViewController.m
//  Kofax Mobile Demo
//
//  Created by kaushik on 20/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CaptureViewController.h"
#import <kfxLibUIControls/kfxUIControls.h>
#import "LicenceHelper.h"
#import "AppDelegate.h"

#import "PersistenceManager.h"
#import "ExhibitorViewController.h"


#define DEFAULTSTABILITYDELAY 95
#define CAMERAACESSALERTTAG   111
#define rightAlignPadding     65.0

@interface CaptureViewController () <kfxKUIImageCaptureControlDelegate>
{
    BOOL tapped, isTapToCaptureShown;
    int pageLongAxisThreshold, pageShortAxisThreshold;
}
@property (nonatomic,strong) kfxKUIImageCaptureControl *captureControl;
@property (nonatomic, strong) kfxKUIDocumentBaseCaptureExperience* uniformGuidanceExperience;
@property (nonatomic,strong)  UIImage* torchOn;
@property (nonatomic,strong)  UIImage* torchOff;
@property (nonatomic, strong) UIView *flashView;
@property (nonatomic,strong)  UIButton *torchButton;
@property (nonatomic,strong)  UIButton *galleryButton;
@property (nonatomic,strong) UIImageView* forceCaptureMessage;
@property (nonatomic,strong) NSTimer *forceCaptureTimer;
@property (nonatomic,strong) UILabel *tapToCaptureLabel;

@property(nonatomic,assign)IBOutlet UIView* bottomOverlay;
@property(nonatomic,assign)IBOutlet UIButton* forceCaptureButton;
@property(nonatomic,assign)IBOutlet UIButton* cancelButton;
@property (nonatomic,strong) kfxKUIImageCaptureControl *cameraView;

@property (nonatomic,strong) UIColor *documentNotFoundColor,*moveCloserColor,*pageOrientationColor,*userInstructionColor,*holdSteadyColor;

@end


@implementation CaptureViewController
@synthesize loadAlbum;


#pragma mark
#pragma mark Exposed Methods

-(id)initWithCaptureSettings : (CaptureSettings*)settings
{
    if(self = [super init])
    {
        self.settings = settings;
        
        
    }
    
    return self;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark
#pragma mark Default Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    // Below not needed, cause it's called in viewwillappear
    //  [self initializeCaptureControl];
    [self setNeedsStatusBarAppearanceUpdate];
    self.cancelButton.hidden = YES;
    self.forceCaptureButton.hidden = YES;
    //blur the view when app goes into background
    [self createViewBlurInBackground];
    
    
}
-(void) viewDidAppear:(BOOL)animated
{
    if(loadAlbum)
    {
        [self onGalleryButtonClicked:self.galleryButton];
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    isTapToCaptureShown = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.forceCaptureButton.userInteractionEnabled = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //checking camera access is avialble or not.
    [self checkCameraAccess:^(BOOL status) {
        if (status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // So black screen will show first....
                [self performSelector:@selector(initializeCaptureControl) withObject:nil afterDelay:0.25];
            });
        }
        else{
            [[KMDAlertView sharedInstance] showAlert:self title:ATITLE_CAMERA_PERMISSION message:AMSG_CAMERA_PERMISSION buttonTitles:[NSArray arrayWithObjects:Klm(@"OK"), nil] completion:^(NSString *buttonTitle) {
                if(buttonTitle == Klm(@"OK"))
                {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
    }];

}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


-(void)initializeCaptureControl
{
    if(!self.captureControl)
    {
        CGFloat captureViewHeight = ([[UIScreen mainScreen] bounds].size.height <= 480 && !self.settings.useVideoFrame) ? 390 : [[UIScreen mainScreen] bounds].size.height;
        CGFloat freeScreenHeight = [[UIScreen mainScreen] bounds].size.height - self.bottomOverlay.bounds.size.height;
        CGFloat yOffset = 0.0;

        if (captureViewHeight > freeScreenHeight)
        {
            yOffset = self.bottomOverlay.bounds.size.height - (captureViewHeight - freeScreenHeight) / 2.0;
        }

        self.captureControl = [[kfxKUIImageCaptureControl alloc] initWithFrame:CGRectMake(0.0, -yOffset, [[UIScreen mainScreen]bounds].size.width, captureViewHeight)];
        
        [kfxKUIImageCaptureControl initializeControl];
        self.captureControl.useVideoFrame = self.settings.useVideoFrame;
        [self.captureControl setStabilityDelay:DEFAULTSTABILITYDELAY];
        self.captureControl.delegate = self;
        self.captureControl.flash = kfxKUIFlashOff;
        if(self.settings.showAutoTorch)
        {
          self.captureControl.flash = kfxKUITorchAuto;
        }
        
        [self.captureControl setPageDetectMode:kfxKUIPageDetectContinuous];
        
        
        [self.captureControl doContinuousMode:self.settings.doContinuousCapture];

        self.bottomOverlay.backgroundColor = [UIColor blackColor];
//        if (self.settings.captureExperience != CHECK && self.settings.useVideoFrame)
//        {
//            self.bottomOverlay.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bottom_bg.png"]];
//        }

        if (self.settings.hideCaptureButton) {
            tapped =  NO;
            self.cancelButton.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 16, 0);
        }
        
        [self.view addSubview:self.captureControl];
        self.cancelButton.hidden = NO;
        self.cancelButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self.forceCaptureButton setHidden:YES];

        [self configureCriteria];
        if (self.settings.captureExperience == CHECK)
        {
            kfxKUICheckCaptureExperience *checkExperience = [[kfxKUICheckCaptureExperience alloc] initWithCaptureControl:self.captureControl criteria:[self createCheckCriteriaWithOffset:yOffset]];
           
            self.uniformGuidanceExperience = checkExperience;
        }
        else
        {
            
            
            kfxKUIDocumentCaptureExperience* documentExperience = [[kfxKUIDocumentCaptureExperience alloc] initWithCaptureControl:self.captureControl criteria:[self createDocumentCriteriaWithOffset:yOffset]];
            self.uniformGuidanceExperience = documentExperience;

        }
        
        [self.uniformGuidanceExperience addObserver: self
                                         forKeyPath: @"tutorialEnabled"
                                            options: NSKeyValueObservingOptionNew
                                            context: NULL];
        
        //Hiding capture experience instructions when manual time is zero. Type casting is not working, so took seperate reference and hiding those messages.
        if (self.settings.manualCaptureTime == 0) {
            [self hideUniformGuidenceMessages];
        }
        
        if (self.settings.tutorialSampleImage) {
            self.uniformGuidanceExperience.tutorialSampleImage = self.settings.tutorialSampleImage;
        }
//        if(self.settings.module==CREDITCARD){
//            self.uniformGuidanceExperience.tutorialSampleImage=[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Creditcard" ofType:@"png"]];
//        }

        
        // "showCaptureDemonstration" is deprecated in SDK 2.4.1
        
        self.uniformGuidanceExperience.tutorialEnabled = self.settings.doShowGuidingDemo;
        
        
        if (self.uniformGuidanceExperience.tutorialEnabled) {
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(checkAnimationTapped:)];
            [self.captureControl addGestureRecognizer:tapGesture];
        }
        
        if (self.settings.manualCaptureTime != 0) {
            [self.uniformGuidanceExperience takePicture];
        }
        
        [self configureUniformGuidenceMessage];

        
        if (self.forceCaptureTimer) {
            [self.forceCaptureTimer invalidate];
        }
        
        if([AppUtilities isFlashAvailable])
        {
            [self addTorch];
        }
        
        [self addGalleryButton];
        self.galleryButton.hidden = YES;

        // Will show gallery icon when tutorial is disabled and show gallery switch is on.
        
        if (self.uniformGuidanceExperience.tutorialEnabled == NO) {
            if(self.settings.showGallery) {
                self.galleryButton.hidden = NO;
            }
            [self startTheManualCaptureTimer];

        }
        
        [self.bottomOverlay.superview bringSubviewToFront:self.bottomOverlay];
    }
}

-(kfxKUICheckCaptureExperienceCriteriaHolder*)createCheckCriteriaWithOffset:(CGFloat)yOffset{
    //to be backward compatible with managers constructing the criteria object ideally should be part of settings
    kfxKUICheckCaptureExperienceCriteriaHolder* checkCriteria = [[kfxKUICheckCaptureExperienceCriteriaHolder alloc] init];
    checkCriteria.stabilityThreshold = self.settings.stabilityThreshold;
    checkCriteria.stabilityThresholdEnabled = self.settings.stabilityThresholdEnabled;
    checkCriteria.rollThreshold = self.settings.rollThreshold;
    checkCriteria.pitchThreshold = self.settings.pitchThreshold;
    checkCriteria.pitchThresholdEnabled = self.settings.pitchThresholdEnabled;
    checkCriteria.rollThresholdEnabled = self.settings.rollThresholdEnabled;
    checkCriteria.focusConstraintEnabled = self.settings.focusConstraintEnabled;
    
    kfxKEDCheckDetectionSettings* checkSettings = [[kfxKEDCheckDetectionSettings alloc] init];
    checkSettings.zoomMinFillFraction = self.settings.isBackCheckSide ? 0.75 : 0.70;
    checkSettings.zoomMaxFillFraction = 1.1;
    checkSettings.checkSide = self.settings.isBackCheckSide ? KED_CHECK_SIDE_BACK : KED_CHECK_SIDE_FRONT;
    
    if (yOffset == 0.0)
    {
        checkSettings.targetFrameCenter = CGPointMake(self.captureControl.center.x, self.captureControl.center.y);
    }
    else
    {
        checkSettings.targetFramePaddingPercent = 9.0;
    }
    
    checkCriteria.checkDetectionSettings = checkSettings;
    
    return checkCriteria;
}

-(kfxKUIDocumentCaptureExperienceCriteriaHolder*)createDocumentCriteriaWithOffset:(CGFloat)yOffset{
    kfxKUIDocumentCaptureExperienceCriteriaHolder* documentCriteria = [[kfxKUIDocumentCaptureExperienceCriteriaHolder alloc] init];
    documentCriteria.stabilityThreshold = self.settings.stabilityThreshold;
    documentCriteria.stabilityThresholdEnabled = self.settings.stabilityThresholdEnabled;
    documentCriteria.rollThreshold = self.settings.rollThreshold;
    documentCriteria.pitchThreshold = self.settings.pitchThreshold;
    documentCriteria.pitchThresholdEnabled = self.settings.pitchThresholdEnabled;
    documentCriteria.rollThresholdEnabled = self.settings.rollThresholdEnabled;
    documentCriteria.focusConstraintEnabled = self.settings.focusConstraintEnabled;
    
    kfxKEDDocumentDetectionSettings* documentSettings = [[kfxKEDDocumentDetectionSettings alloc] init];
    documentSettings.longAxisThreshold = pageLongAxisThreshold;
    documentSettings.shortAxisThreshold = pageShortAxisThreshold;
    documentSettings.targetFrameAspectRatio = self.settings.staticFrameAspectRatio;
    documentSettings.edgeDetection = (kfxKEDDocumentEdgeDetection)self.settings.edgeDetection;
    
    if (yOffset == 0.0)
    {
        documentSettings.targetFrameCenter = CGPointMake(self.captureControl.center.x, self.captureControl.center.y);
    }
    else
    {
        documentSettings.targetFramePaddingPercent = 9.0;
    }
    
    documentSettings.zoomMinFillFraction = self.settings.zoomMinFillFraction;
    documentSettings.zoomMaxFillFraction = self.settings.zoomMaxFillFraction;
    
    documentCriteria.documentDetectionSettings = documentSettings;
    return documentCriteria;
}


// method for configuring the messages
-(void)configureUniformGuidenceMessage
{
    if (self.settings.moveCloserMessage.length != 0){
        self.uniformGuidanceExperience.zoomInMessage.message = self.settings.moveCloserMessage;
    }
    if (self.settings.holdSteadyMessage.length != 0){
        self.uniformGuidanceExperience.holdSteadyMessage.message = self.settings.holdSteadyMessage;
    }
    if (self.settings.userInstruction.length != 0){
        self.uniformGuidanceExperience.userInstruction.message = self.settings.userInstruction;
    }
    if (self.settings.capturedMessage.length != 0 ){
        self.uniformGuidanceExperience.capturedMessage.message = self.settings.capturedMessage;
    }
    if (self.settings.zoomOutMessage.length != 0 ){
        self.uniformGuidanceExperience.zoomOutMessage.message = self.settings.zoomOutMessage;
    }
    if (self.settings.centerMessage.length != 0 ){
        self.uniformGuidanceExperience.centerMessage.message = self.settings.centerMessage;
    }
    if (self.settings.holdParallelMessage.length != 0 ){
        self.uniformGuidanceExperience.holdParallelMessage.message = self.settings.holdParallelMessage;
    }
    if (self.settings.orientationMessage.length != 0 ){
        self.uniformGuidanceExperience.rotateMessage.message = self.settings.orientationMessage;
    }
}

//This method is used for hiding user instruction messages while capturing documents

- (void)hideUniformGuidenceMessages
{
    self.uniformGuidanceExperience.centerMessage.hidden = YES;
    self.uniformGuidanceExperience.zoomOutMessage.hidden = YES;
    self.uniformGuidanceExperience.zoomInMessage.hidden = YES;
    self.uniformGuidanceExperience.holdSteadyMessage.hidden = YES;
    self.uniformGuidanceExperience.userInstruction.hidden = YES;
    self.uniformGuidanceExperience.capturedMessage.hidden = YES;
    self.uniformGuidanceExperience.holdParallelMessage.hidden = YES;
    self.uniformGuidanceExperience.rotateMessage.hidden = YES;

}

//This method is used for unhiding user instruction messages while capturing documents

- (void)unHideUniformGuidenceMessages
{
    self.uniformGuidanceExperience.zoomOutMessage.hidden = NO;
    self.uniformGuidanceExperience.zoomInMessage.hidden = NO;
    self.uniformGuidanceExperience.holdSteadyMessage.hidden = NO;
    self.uniformGuidanceExperience.centerMessage.hidden = NO;
    self.uniformGuidanceExperience.capturedMessage.hidden = NO;
    self.uniformGuidanceExperience.userInstruction.hidden = NO;
    self.uniformGuidanceExperience.holdParallelMessage.hidden = NO;
    self.uniformGuidanceExperience.rotateMessage.hidden = NO;
}

-(void)tapOnCaptureView:(UITapGestureRecognizer*)tapGesture{
    if (!tapped) {
        tapped = YES;
        [self.captureControl forceTakePicture];
    }
}
-(void)checkAnimationTapped:(UITapGestureRecognizer*)tapGesture{
    
    // "showCaptureDemonstration" is deprecated in SDK 2.4.1
    self.uniformGuidanceExperience.tutorialEnabled = NO;
}


-(void)freeCaptureControl
{
    if (self.forceCaptureTimer.valid) {
        [self.forceCaptureTimer invalidate];
    }
    if(self.captureControl!=nil) {
        
        [self.captureControl removeFromSuperview];
        self.captureControl.delegate = nil;
        self.captureControl = nil;
    }
    if(self.flashView != nil){
        
        [self.flashView removeFromSuperview];
        self.flashView = nil;
    }
    if(self.uniformGuidanceExperience != nil) {
        
        [self.uniformGuidanceExperience removeObserver:self forKeyPath:@"tutorialEnabled" context:NULL];
        self.uniformGuidanceExperience = nil;

    }
    if(self.tapToCaptureLabel != nil){
        
        [self.tapToCaptureLabel removeFromSuperview];
        self.tapToCaptureLabel = nil;
    }
 
    
}

-(void)configureCriteria{
    self.settings.stabilityThresholdEnabled = YES;
    pageLongAxisThreshold = self.settings.longAxisThreshold;
    pageShortAxisThreshold = self.settings.shortAxisThreshold;
}

-(void)showCaptureMessage{
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnCaptureView:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.captureControl addGestureRecognizer:tapGesture];
    self.tapToCaptureLabel = [[UILabel alloc]init];
    self.tapToCaptureLabel.frame = CGRectMake(0, 0, 150, 30);
    self.tapToCaptureLabel.font = [UIFont fontWithName:FONTNAME size:17];
    self.tapToCaptureLabel.textColor = [UIColor whiteColor];
    self.tapToCaptureLabel.transform = CGAffineTransformMakeRotation(M_PI / 2);
    self.tapToCaptureLabel.backgroundColor = [UIColor blackColor];
    self.tapToCaptureLabel.alpha = 0.4;
    self.tapToCaptureLabel.layer.cornerRadius = 5;
    self.tapToCaptureLabel.text = Klm(@"Tap to capture");
    self.tapToCaptureLabel.textAlignment = NSTextAlignmentCenter;
    //self.tapToCaptureLabel.center = CGPointMake(self.animationExperience.staticFrameCenter.x+80, self.animationExperience.staticFrameCenter.y);
    [self.view addSubview:self.tapToCaptureLabel];
    [self.tapToCaptureLabel.superview bringSubviewToFront:self.tapToCaptureLabel];
}

#pragma mark
#pragma mark UI Methods


-(void)showForceCaptureMessage
{
    //Notification for voice over to speech "Tap to capture manually".
    
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, // announce
                                    Klm(@"Tap to capture"));  // actual text

    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 142, 43)];
    label.text = Klm(@"Tap to capture");
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:FONTNAME size:17];
    [self.forceCaptureTimer invalidate];

    
    [self.forceCaptureButton setHidden:NO];
    
    if (!self.settings.hideForceCaptureMessage){
        self.forceCaptureMessage = [[UIImageView alloc]initWithFrame:CGRectMake(([[UIScreen mainScreen]bounds].size.width-180)/2, self.bottomOverlay.frame.origin.y-122, 180, 43)];
        self.forceCaptureMessage.image = [UIImage imageNamed:@"bg.png"];
        [self.forceCaptureMessage addSubview:label];
        self.forceCaptureMessage.transform = CGAffineTransformMakeRotation(M_PI / 2);
        self.forceCaptureButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self.view addSubview:self.forceCaptureMessage];
     
        [self animateViewWithMax:[NSNumber numberWithInt:10] current:[NSNumber numberWithInt:0]];
    }
}

// method to stop auto capture document
-(void)stopAutoCapture
{
    if(self.settings.captureExperience== CHECK){
        [self.uniformGuidanceExperience stopCapture];
    }else{
        [self.captureControl stopCapture];
    }
}

- (void) animateViewWithMax:(NSNumber *)max current:(NSNumber *)current
{
    [UIView animateWithDuration:1.5f delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.forceCaptureMessage.frame = CGRectMake(self.forceCaptureMessage.frame.origin.x, self.forceCaptureMessage.frame.origin.y-20, self.forceCaptureMessage.frame.size.width, self.forceCaptureMessage.frame.size.height);
                         
                     }completion:^(BOOL finished){
                         
                     }];
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.forceCaptureMessage.frame = CGRectMake(self.forceCaptureMessage.frame.origin.x, self.forceCaptureMessage.frame.origin.y+20, self.forceCaptureMessage.frame.size.width, self.forceCaptureMessage.frame.size.height);
                         
                     }completion:^(BOOL finished){
                         
                         
                         if (current.intValue < max.intValue) {
                             [self performSelector:@selector(animateViewWithMax:current:) withObject:max withObject:[NSNumber numberWithInteger:(current.intValue+1)]];
                         }else{
                             self.forceCaptureMessage.hidden = YES;
                             if (self.settings.manualCaptureTime != 0) {  //Unhiding user instructions when animation is completed
                                 [self unHideUniformGuidenceMessages];
                             }
                        }
                         
                     }];
}


//TODO optimize this method

-(void)addFlash
{
    
    if(!self.flashView)
        self.flashView = [[UIView alloc]initWithFrame:CGRectMake(215,[[UIScreen mainScreen]bounds].size.height<=480?90:163,135,20)];
    
    //    self.flashView = [[UIView alloc]initWithFrame:CGRectMake(213,165,135,20)];
    UIImageView *flashImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    flashImage.image = [UIImage imageNamed:@"flash.png"];
    flashImage.tag =11;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flashButtonAction:)];
    [tap setNumberOfTapsRequired:1];
    flashImage.userInteractionEnabled = YES;
    self.flashView.userInteractionEnabled = YES;
    [flashImage addGestureRecognizer:tap];
    [self.flashView addGestureRecognizer:tap];
    UIButton *autoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *onButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *offButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [autoButton setTitle:Klm(@"Auto") forState:UIControlStateNormal];
    [onButton setTitle:Klm(@"On") forState:UIControlStateNormal];
    [offButton setTitle:Klm(@"Off") forState:UIControlStateNormal];
    autoButton.titleLabel.font = [UIFont fontWithName:FONTNAME size:15];
    onButton.titleLabel.font = [UIFont fontWithName:FONTNAME size:15];
    offButton.titleLabel.font = [UIFont fontWithName:FONTNAME size:15];
    autoButton.frame = CGRectMake(20, 0, 35, 20);
    onButton.frame = CGRectMake(55, 0, 35, 20);
    offButton.frame = CGRectMake(90, 0, 35, 20);
    autoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    onButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    offButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    autoButton.tag = kfxKUIFlashAuto;
    onButton.tag = kfxKUIFlashOn;
    offButton.tag = kfxKUIFlashOff;
    onButton.hidden = YES;
    offButton.hidden = YES;
    [autoButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [onButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [offButton addTarget:self action:@selector(flashButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.flashView addSubview:autoButton];
    [self.flashView addSubview:onButton];
    [self.flashView addSubview:offButton];
    [self.flashView addSubview:flashImage];
    self.flashView.transform = CGAffineTransformMakeRotation(M_PI / 2);
    //[topView addSubview:flashView];
    for (UIView *sbView in [self.flashView subviews]) {
        if ((sbView.tag==kfxKUIFlashAuto && self.captureControl.flash==kfxKUIFlashAuto)||(sbView.tag==kfxKUIFlashOn && self.captureControl.flash==kfxKUIFlashOn)||(sbView.tag==kfxKUIFlashOff && self.captureControl.flash==kfxKUIFlashOff)) {
            sbView.hidden = NO;
            sbView.frame = CGRectMake(20, 0, 35, 20);
        }else if(sbView.tag==kfxKUIFlashAuto||sbView.tag==kfxKUIFlashOn||sbView.tag==kfxKUIFlashOff){
            sbView.hidden = YES;
        }
    }
    
    [self.view addSubview:self.flashView];
    [self.flashView.superview bringSubviewToFront:self.flashView];
}
-(void)addGalleryButton
{
    if(!self.galleryButton) {
        
        //calculating x offset of gallery icon.
        
        float x_offset = CGRectGetWidth(self.view.frame) - 2 * rightAlignPadding;
        self.galleryButton = [[UIButton alloc]initWithFrame:CGRectMake(x_offset, 3, 64, 64)];
    }
    
    [self.galleryButton setImage:[UIImage imageNamed:@"gallery.png"] forState:UIControlStateNormal];
    self.flashView.hidden = NO;
    [self.galleryButton addTarget:self action:@selector(onGalleryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomOverlay addSubview:self.galleryButton];
    
}
-(IBAction)onGalleryButtonClicked :(UIButton*)sender
{
    // Create image picker controllerx
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker.view setFrame:CGRectMake(0, 80, 320, 350)];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [imagePicker setDelegate:self];
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    loadAlbum = NO;
    //[self.delegate imageCaptured:image];
    //Get Image URL from Library
    UIImage *myUIImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    [self freeCaptureControl];

    kfxKEDImage *image = [[kfxKEDImage alloc] initWithImage: myUIImage];
    if(self.delegate && [self.delegate respondsToSelector:@selector(imageSelected:)]){
        
        [self.delegate imageSelected:image];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{    
    loadAlbum  = NO;
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Picker cancelled");

}

-(void)addTorch
{
    self.torchOn = [UIImage imageNamed:@"torchon.png"];
    self.torchOff = [UIImage imageNamed:@"torch_off.png"];
    if(!self.torchButton)
        self.torchButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-65, 3, 64, 64)];
    
    [self.torchButton setImage:self.torchOff forState:UIControlStateNormal];
    self.flashView.hidden = NO;
    [self.torchButton addTarget:self action:@selector(onTorchButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.torchButton.transform = CGAffineTransformMakeRotation(M_PI / 2);
    if(!self.settings.showAutoTorch)
        [self.bottomOverlay addSubview:self.torchButton];
}

-(IBAction)onTorchButtonClicked :(UIButton*)sender
{
    if(sender.imageView.image == self.torchOn)
    {
        [sender setImage:self.torchOff forState:UIControlStateNormal];
        self.captureControl.flash = kfxKUIFlashOff;
        for (UIView *sbView in [self.flashView subviews]) {
            if ((sbView.tag==kfxKUIFlashAuto && self.captureControl.flash==kfxKUIFlashAuto)||(sbView.tag==kfxKUIFlashOn && self.captureControl.flash==kfxKUIFlashOn)||(sbView.tag==kfxKUIFlashOff && self.captureControl.flash==kfxKUIFlashOff)) {
                sbView.hidden = NO;
                sbView.frame = CGRectMake(20, 0, 35, 20);
            }else if(sbView.tag==kfxKUIFlashAuto||sbView.tag==kfxKUIFlashOn||sbView.tag==kfxKUIFlashOff){
                sbView.hidden = YES;
            }
        }
        self.flashView.hidden = NO;
    }
    else
    {
        [sender setImage:self.torchOn forState:UIControlStateNormal];
        self.flashView.hidden = YES;
        self.captureControl.flash = kfxKUITorch;
    }
}

-(void)flashButtonAction:(id)sender{
    BOOL anyOneButtonHidden = NO;
    for (UIView *subview in [self.flashView subviews]) {
        if (subview.hidden) {
            anyOneButtonHidden = YES;
            break;
        }
    }
    if (anyOneButtonHidden) {
        for (UIView *subview in [self.flashView subviews]) {
            if (subview.tag == kfxKUIFlashOn || subview.tag==kfxKUIFlashOff) {
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromLeft;
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [subview.layer addAnimation:transition forKey:nil];
            }
            if (subview.tag==kfxKUIFlashAuto) {
                subview.frame = CGRectMake(20, 0, 35, 20);
            }else if(subview.tag == kfxKUIFlashOn){
                subview.frame = CGRectMake(55, 0, 35, 20);
            }else if(subview.tag==kfxKUIFlashOff){
                subview.frame = CGRectMake(90, 0, 35, 20);
            }
            subview.hidden = NO;
        }
    }else if([sender isKindOfClass:[UIButton class]]){
        UIButton *button = sender;
        for (UIView *sbView in [self.flashView subviews])
        {
            if (sbView.tag==kfxKUIFlashOn||sbView.tag==kfxKUIFlashOff) {
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromRight;
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [sbView.layer addAnimation:transition forKey:nil];
            }
            if (sbView.tag==button.tag)
            {
                sbView.hidden = NO;
                sbView.frame = CGRectMake(20, 0, 35, 20);
            }
            else if(sbView.tag==kfxKUIFlashAuto||sbView.tag==kfxKUIFlashOn||sbView.tag==kfxKUIFlashOff)
            {
                sbView.hidden = YES;
            }
        }
        self.captureControl.flash =(int) button.tag;
    }
    else
    {
        for (UIView *sbView in [self.flashView subviews]) {
            if (sbView.tag==kfxKUIFlashOn||sbView.tag==kfxKUIFlashOff) {
                CATransition *transition = [CATransition animation];
                transition.duration = 0.3;
                transition.type = kCATransitionPush;
                transition.subtype = kCATransitionFromRight;
                [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
                [sbView.layer addAnimation:transition forKey:nil];
            }
            if ((sbView.tag==kfxKUIFlashAuto && self.captureControl.flash==kfxKUIFlashAuto)||(sbView.tag==kfxKUIFlashOn && self.captureControl.flash==kfxKUIFlashOn)||(sbView.tag==kfxKUIFlashOff && self.captureControl.flash==kfxKUIFlashOff)) {
                sbView.hidden = NO;
                sbView.frame = CGRectMake(20, 0, 35, 20);
            }else if(sbView.tag==kfxKUIFlashAuto||sbView.tag==kfxKUIFlashOn||sbView.tag==kfxKUIFlashOff){
                sbView.hidden = YES;
            }
        }
    }
}


-(IBAction)onForceCaptureClicked:(UIButton*)sender
{
    [self.captureControl forceTakePicture];
    sender.userInteractionEnabled = NO;
}

-(IBAction)onCancelClicked:(id)sender
{
    [self freeCaptureControl];
    if(self.delegate && [self.delegate respondsToSelector:@selector(cancelCamera)])
        [self.delegate cancelCamera];
}


#pragma mark
#pragma mark Delegate Methods

-(void)imageCaptureControl:(kfxKUIImageCaptureControl *)imageCaptureControl
             imageCaptured:(kfxKEDImage*)image
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.delegate && [self.delegate respondsToSelector:@selector(imageCaptured:)])
            [self.delegate imageCaptured:image];
        [self freeCaptureControl];

    });
}

#pragma mark-
#pragma mark- Key Value Observer method

// observing tutorialEnabled value
-(void) observeValueForKeyPath: (NSString *)keyPath ofObject: (id) object
                        change: (NSDictionary *) change context: (void *) context
{
    self.cancelButton.hidden = [[change objectForKey: NSKeyValueChangeNewKey] boolValue];
    
    //Starting the timer when guiding demo is completed.

    //Once we shown tap to capture and we should not show again.
    
    if (isTapToCaptureShown == NO && [[change objectForKey: NSKeyValueChangeNewKey] boolValue] == NO) {
        isTapToCaptureShown = YES;
        [self startTheManualCaptureTimer];
    }
    
    if(self.settings.showGallery) {   //showing gallery button when tutorial is completed.
        self.galleryButton.hidden = self.cancelButton.hidden;
    }
}


//Method is used for starting timer to show manual capture message.

- (void)startTheManualCaptureTimer
{
    //start timer to show the force capture message
    if (!self.settings.hideCaptureButton) {
        self.forceCaptureTimer =  [NSTimer scheduledTimerWithTimeInterval:self.settings.manualCaptureTime target:self selector:@selector(showForceCaptureMessage) userInfo:nil repeats:NO];
    }else{
        
        self.forceCaptureTimer =  [NSTimer scheduledTimerWithTimeInterval:self.settings.manualCaptureTime target:self selector:@selector(showCaptureMessage) userInfo:nil repeats:NO];
    }
}

-(void)dealloc
{
    self.torchOn = nil;
    self.torchOff = nil;
    self.torchButton = nil;
    
    if(self.bottomOverlay)
        [self.bottomOverlay removeFromSuperview];
    
    self.bottomOverlay = nil;
    
    if(self.flashView)
    {
        [self.flashView.layer removeAllAnimations];
        [self.flashView removeFromSuperview];
    }
    
    self.flashView = nil;
    
    if(self.forceCaptureMessage)
        [self.forceCaptureMessage removeFromSuperview];
    
    self.forceCaptureMessage = nil;
    
    if(self.forceCaptureTimer)
        [self.forceCaptureTimer invalidate];
    
    self.forceCaptureTimer = nil;
    
    self.forceCaptureButton = nil;
    
    self.captureControl.delegate = nil;
    [self.captureControl removeFromSuperview];
    self.captureControl = nil;
    if (self.uniformGuidanceExperience) {
        [self.uniformGuidanceExperience removeObserver:self forKeyPath:@"tutorialEnabled" context:NULL];
        self.uniformGuidanceExperience = nil;
    }

}



@end
