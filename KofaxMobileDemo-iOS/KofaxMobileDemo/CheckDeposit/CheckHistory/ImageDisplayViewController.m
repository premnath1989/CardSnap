//
//  ImageDisplayViewController.m
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/14/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "ImageDisplayViewController.h"




@interface ImageDisplayViewController ()
@property (nonatomic,strong) kfxKUIImageReviewAndEdit *previewImage;
@property (nonatomic, strong) kfxKEDImage *inputImage;
@end

@implementation ImageDisplayViewController
@synthesize previewImage;

-(id)initWithImage:(kfxKEDImage*)image{
    self = [super init];
    if (self) {
        self.inputImage = image;
    }
    return self;
}


-(void)dealloc{
    self.previewImage = nil;
    if (self.inputImage) {
        [self.inputImage clearImageBitmap];
        self.inputImage = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = Klm(@"Image Preview");
    
    self.navigationItem.leftBarButtonItem = [AppUtilities getBackButtonItemWithTarget:self andAction:@selector(backButtonAction:)];
    
    [kfxKUIImageReviewAndEdit initializeControl];
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=7.0) {
        previewImage = [[kfxKUIImageReviewAndEdit alloc]initWithFrame:CGRectMake(0, 64, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-64)];
    }else{
        previewImage = [[kfxKUIImageReviewAndEdit alloc]initWithFrame:CGRectMake(0, 44, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height-44)];
    }
    
    [previewImage setImage:self.inputImage];
    [self.view addSubview:previewImage];
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


-(IBAction)backButtonAction:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
