//
//  BarcodeReaderViewController.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 04/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BarcodeReaderViewController.h"


@interface BarcodeReaderViewController ()<kfxKUIBarCodeCaptureControlDelegate>
{
   
}
@property(nonatomic,strong)kfxKUIBarCodeCaptureControl* barCodeReader;
@property(nonatomic,strong)kfxKEDImage* barCodeImage;

@property (nonatomic,strong) UIBarButtonItem *skipButton;

@property (nonatomic,strong) NSTimer *skipTimer;

@end



@implementation BarcodeReaderViewController


-(void)dealloc{
    self.barCodeReader.delegate = nil;
    [self.barCodeReader removeFromSuperview];
    self.barCodeReader = nil;
    self.skipButton = nil;
    self.skipTimer = nil;
    
    /*
    if (self.barCodeImage) {
        [self.barCodeImage clearImageBitmap];
        self.barCodeImage = nil;
    }
     */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.rightBarButtonItem = nil;
    
   // self.skipTimer =  [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(showSkipButton:) userInfo:nil repeats:NO];
    
    //blur the view when app goes into background
    [self createViewBlurInBackground];
}

-(void)viewWillAppear:(BOOL)animated
{
     [super viewWillAppear:YES];
     [self addCancelBarItem];
     self.navigationItem.title = Klm(@"Barcode Reader");
     [self presentBarCodeReader];
    
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    [self freeBarcodeReader];
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






/// Method to display the bar code capture control to read a bar code
/**
 This method presents the akfxKUIBarCodeCaptureControl object on top of the current view of the application in order to\n
 to read a bar code. Once a bar code is read, the barcode reader is automatically removed from the screen.\n
 A guide line is shown to help the user can align the bar code.\n
 
 */

-(void) presentBarCodeReader
{
    // Hide the image capture view (instead of removing it from superview)
    // and make the barcodereader view visisble
    
   
    self.barCodeReader = [[kfxKUIBarCodeCaptureControl alloc] initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-64)];
    //barCodeReader.backgroundColor = self.navigationController.navigationBar.tintColor;
    self.barCodeReader.guidingLine = kfxKUIGuidingLineLandscape;
    self.barCodeReader.delegate = (id <kfxKUIBarCodeCaptureControlDelegate>)self;
    
    self.barCodeReader.searchDirection = @[@(kfxKUIDirectionAll)];
    self.barCodeReader.symbologies = @[@(kfxKUISymbologyPdf417)];
    self.barCodeReader.delegate = self;
    [self.view addSubview:self.barCodeReader];
    [self.barCodeReader readBarcode];
    
//    barCodeReader = [[kfxKUIBarCodeCaptureControl alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [kfxKUIBarCodeCaptureControl initializeControl];
//    barCodeReader.guidingLine = kfxKUIGuidingLineLandscape;
//    barCodeReader.delegate = self;
//    barCodeReader.searchDirection = @[@(kfxKUIDirectionAll)];
//    barCodeReader.symbologies = @[@(kfxKUISymbologyPdf417)];
//    
//    barcode = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
//    [barcode addSubview:barCodeReader];
//    [self.view addSubview:barcode];
//    [barCodeReader readBarcode];
//    NSLog(@"subviews %@",[self.view subviews]);
    
    
}

-(void)showSkipButton:(NSTimer*)timer{
    [self.skipTimer invalidate];
    self.skipButton = [[UIBarButtonItem alloc]initWithTitle:Klm(@"Skip") style:UIBarButtonItemStylePlain target:self action:@selector(skipButtonAction:)];
    self.skipButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.skipButton;
}


-(IBAction)cancelButtonAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)sendResponse: (kfxKEDBarcodeResult*)result
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(barcodeFound:withImage:)])
        [self.delegate barcodeFound:result withImage:self.barCodeImage];
}

-(void)skipButtonAction:(UIBarButtonItem*)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(skipButtonClicked)])
        [self.delegate skipButtonClicked];
}

-(void)freeBarcodeReader
{

    self.barCodeReader.delegate = nil;
    [self.barCodeReader removeFromSuperview];
    //[barcode removeFromSuperview];
    
    self.barCodeReader = nil;

}

#pragma mark 
#pragma mark Barcode Delegate Methods
-(void)barcodeCaptureControl:(kfxKUIBarCodeCaptureControl *)barcodeCaptureControl barcodeFound:(kfxKEDBarcodeResult *)result image:(kfxKEDImage *)image
{
    self.barCodeImage = image;
    [self performSelectorOnMainThread:@selector(sendResponse:) withObject:result waitUntilDone:NO];
   
}


@end
