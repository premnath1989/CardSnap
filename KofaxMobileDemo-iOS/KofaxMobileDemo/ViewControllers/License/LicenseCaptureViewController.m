//
//  LicenseCaptureViewController.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 02/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "LicenseCaptureViewController.h"
#import <kfxLibUIControls/kfxKUILicenseCaptureControl.h>
#import "AppStateMachine.h"
#import "PersistenceManager.h"
#import "HomeViewController.h"
#define tagAlertPrompt 11111111

@interface LicenseCaptureViewController ()<kfxKUILicenseCaptureControlDelegate>
{
    
}

@property (weak, nonatomic) IBOutlet UIView *bottomOverlay;
@property (nonatomic,strong) kfxKUILicenseCaptureControl *licenseControl;

@end

@implementation LicenseCaptureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelector:@selector(initializeLicenseControl) withObject:nil afterDelay:0.25];
}

/*
 This function is used to initialize the SDK’s kfxKUILicenseCaptureControl, which internally initializes the QR Code Scanner.Later we invoke the “ readLicense” method which asynchronously starts searching for QR code. The search will continue indefinely until a valid QR code is found.
 */
-(void)initializeLicenseControl
{
    if (!self.licenseControl) {
        CGFloat captureViewHeight = ([[UIScreen mainScreen] bounds].size.height <= 480 ? 410 : [[UIScreen mainScreen] bounds].size.height);
        CGFloat yOffset = 0;
        self.licenseControl = [[kfxKUILicenseCaptureControl alloc] initWithFrame:CGRectMake(0.0, -yOffset, [[UIScreen mainScreen]bounds].size.width, captureViewHeight)];
        [kfxKUILicenseCaptureControl initializeControl];
        [self.licenseControl readLicense];
        self.licenseControl.delegate = self;
        [self.view addSubview:self.licenseControl];
        [self.bottomOverlay.superview bringSubviewToFront:self.bottomOverlay];
    }
}

// for releasing license control memory
-(void)freeLicenseControl
{
    self.navigationController.navigationBar.hidden = NO;
    if(self.licenseControl!=nil) {
        
        [self.licenseControl removeFromSuperview];
        self.licenseControl.delegate = nil;
        self.licenseControl = nil;
    }
}


// close camera screen back to license prompt screen.
- (IBAction)btnCancelTouchUpInside:(id)sender {
    [self freeLicenseControl];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark-
#pragma mark- Delegate methods
#pragma mark-
/*
 This delegate method is invoked when a license is read . If the license  is valid ,then we store the license permanently in device and use it further in the application . If the license  is not valid , then the application will prompt the user with error message provided by SDK . Once the error message is dismissed , the application will again start searching for QR Code .
 */
- (void)licenseCaptureControl:(kfxKUILicenseCaptureControl*)licenseCaptureControl
                    errorCode:(int)errorCode
                daysRemaining:(int)daysRemaining
                      license:(NSString*)license
{
    if (errorCode == KMC_SUCCESS) {
        [self validLicenseFound:license];
    }
    else{
        NSArray *errorMessage = [AppUtilities getTheErrorMessage:errorCode];

        [[KMDAlertView sharedInstance] showAlert:self title:Klm(errorMessage[0]) message:Klm(errorMessage[1]) buttonTitles:[NSArray arrayWithObjects:Klm(@"OK"), nil] completion:^(NSString *buttonTitle) {
            if (buttonTitle == Klm(@"OK")) {
                [self.licenseControl readLicense];
            }
        }];

    }
}


// this method will be called when valid license string detect in qr code.
// it will navigate to home screen.
-(void)validLicenseFound:(NSString *)license
{
    [self freeLicenseControl];

    [PersistenceManager setLicenseString:license];

    BOOL isHomeExist = NO;
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        //This if condition checks whether the viewController's class is HomeViewController
        // if true that means its the HomeViewController (which has been pushed at some point)
        if ([viewController isKindOfClass:[HomeViewController class]] ) {
            isHomeExist  = YES;
            break;
        }
    }

    if (isHomeExist) {
        UIViewController *controller = self.navigationController.viewControllers[self.navigationController.viewControllers.count-3];
        [self.navigationController popToViewController:controller animated:YES];
    }
    else {
        HomeViewController *homeController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        self.navigationController.viewControllers = [NSArray arrayWithObjects:homeController,nil];
    }
}


@end
