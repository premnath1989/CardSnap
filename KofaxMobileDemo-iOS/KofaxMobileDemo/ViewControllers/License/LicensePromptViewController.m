//
//  LicensePromptViewController.m
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 02/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import "LicensePromptViewController.h"
#import "LicenseCaptureViewController.h"
#import "LicenceHelper.h"
#import "HomeViewController.h"
#import "PersistenceManager.h"

@interface LicensePromptViewController ()
{
    AppUtilities *utilitiesObject;
}
@property (weak, nonatomic) IBOutlet UITextField *tfLicense;
@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;
@property (weak, nonatomic) IBOutlet UILabel *lblOr;
@property (weak, nonatomic) IBOutlet UIButton *btnCaptureQrCode;
@property (weak, nonatomic) IBOutlet UILabel *lblEnterLicensePlaceHolder;

@end

@implementation LicensePromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.


    self.navigationItem.title = Klm(@"License");
    self.navigationItem.hidesBackButton = YES;

    utilitiesObject = [[AppUtilities alloc]init];
    
    // setting up theme color for all required controls.
    [self setThemeColorAndText];
}

-(void)setThemeColorAndText
{
    [utilitiesObject setThemeColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] andTitleColor:[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor] forNavigationBar:self.navigationController.navigationBar];
    
    self.btnSubmit.backgroundColor =[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] ;
    self.btnCaptureQrCode.backgroundColor =[utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.themeColor] ;
    
    // make rounded corners
    self.btnSubmit.layer.masksToBounds = YES;
    self.lblOr.layer.masksToBounds = YES;
    self.lblOr.layer.borderColor = [UIColor blackColor].CGColor;
    self.lblOr.layer.borderWidth = 1.0;
    
    self.btnCaptureQrCode.layer.masksToBounds = YES;
    // setting up localized text.
    self.lblEnterLicensePlaceHolder.text = Klm(@"Enter License");
    [self.btnSubmit setTitle:Klm(@"Submit") forState:UIControlStateNormal];
    [self.btnCaptureQrCode setTitle:Klm(@"Scan License QR Code") forState:UIControlStateNormal];
    self.lblOr.text = Klm(@"OR");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnSubmitTouchUpInside:(id)sender {
    
    [self.view endEditing:YES];
    
    
    if (self.tfLicense.text.length == 0) {
        [[KMDAlertView sharedInstance] showAlert:self title:nil message:Klm(@"Enter License") buttonTitles:[NSArray arrayWithObjects:Klm(@"OK"), nil] completion:^(NSString *buttonTitle) {
        }];
        return;
    }

    NSArray *errorMessage = [AppUtilities setLicense:self.tfLicense.text];
    if(errorMessage.count == 0){
        [self validLicenseFound:self.tfLicense.text];
    }
    else {
        [[KMDAlertView sharedInstance] showAlert:self title:Klm(errorMessage[0]) message:Klm(errorMessage[1]) buttonTitles:[NSArray arrayWithObjects:Klm(@"OK"), nil] completion:^(NSString *buttonTitle) {
        }];
    }
}

- (IBAction)btnCaptureTouchUpInside:(id)sender {
    
    [self checkCameraAccess:^(BOOL status) {
        if (status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                LicenseCaptureViewController * viewController = [[LicenseCaptureViewController alloc] initWithNibName:@"LicenseCaptureViewController" bundle:nil];
                [self.navigationController pushViewController:viewController animated:YES];
            });
        }
        else{
            [[KMDAlertView sharedInstance] showAlert:self title:ATITLE_CAMERA_PERMISSION message:AMSG_CAMERA_PERMISSION buttonTitles:[NSArray arrayWithObjects:Klm(@"OK"), nil] completion:^(NSString *buttonTitle) {
                if (buttonTitle == Klm(@"OK")) {
                    // handle action here
                }
            }];
        }
    }];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

// this method will be called when valid license string entered in text box.
// it will navigate to home screen.
-(void)validLicenseFound:(NSString *)license
{
    BOOL isHomeExist = NO;
    for (UIViewController* viewController in self.navigationController.viewControllers) {
        //This if condition checks whether the viewController's class is HomeViewController
        // if true that means its the HomeViewController (which has been pushed at some point)
        if ([viewController isKindOfClass:[HomeViewController class]] ) {
            isHomeExist  = YES;
        }
    }
    
    if (isHomeExist) {
        UIViewController *controller = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
        [self.navigationController popToViewController:controller animated:YES];
    }
    else {
        HomeViewController *homeController = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        self.navigationController.viewControllers = [NSArray arrayWithObjects:homeController,nil];
    }
}

@end
