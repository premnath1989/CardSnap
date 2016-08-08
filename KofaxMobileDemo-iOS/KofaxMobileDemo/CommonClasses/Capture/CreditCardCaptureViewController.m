//
//  CCardCaptureViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/26/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "CreditCardCaptureViewController.h"

#define CAMERAACESSALERTTAG   111

@interface CreditCardCaptureViewController ()<KFXCreditCardCapturedDelegate>
@property (nonatomic, strong) KFXCreditCardCaptureView *captureView;

@property (nonatomic, assign)IBOutlet UIButton *cancelButton;
@end

@implementation CreditCardCaptureViewController


-(BOOL)prefersStatusBarHidden{
    return YES;
}


-(void)dealloc{
    self.captureView.delegate = nil;
    [self.captureView removeFromSuperview];
    self.captureView = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [KFXCreditCardCaptureView initializeView];
    
    [self.cancelButton setTitle:Klm(self.cancelButton.titleLabel.text) forState:UIControlStateNormal];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //checking camera access is avialble or not.
    [self checkCameraAccess:^(BOOL status) {
        if (status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // So black screen will show first....
                self.captureView = [[KFXCreditCardCaptureView alloc] initWithFrame: CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height)]; //[[UIScreen mainScreen] bounds]]; //self.view.frame];
                self.captureView.delegate = self;
                
                [self.view addSubview: self.captureView];
                [self.captureView setCardNumberStyle: KFXCreditCardNumberStyleEmbossed];
                
                [self.cancelButton.superview bringSubviewToFront:self.cancelButton];
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

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
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

#pragma mark
#pragma mark CreditCardCaptureViewDelegate Methods
- (void) cardExtractionFailed : (int) failureReason {
    NSLog(@"---card extraction failed with reason --- %@",[kfxError findErrDesc:failureReason]);
}

- (void) cardExtracted : (id) image andCreditCard : (KFXCreditCard *) creditCardData {
    [self freeCaptureView];
    [self.delegate creditCardCaptureComplete:creditCardData];
}


- (void) cardCaptured : (id) image {
    
}

- (IBAction)cancelPressed:(id)sender {
    [self freeCaptureView];
    [self.delegate cancelCardCapture];
}

-(void)freeCaptureView{
    self.captureView.delegate = nil;
    [self.captureView removeFromSuperview];
    self.captureView = nil;
}


@end
