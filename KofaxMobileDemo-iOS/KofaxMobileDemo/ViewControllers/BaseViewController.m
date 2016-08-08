//
//  BaseViewController.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 03/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BaseViewController.h"
#import <MessageUI/MessageUI.h>
#import <kfxLibEngines/kfxEngines.h>
#import "LicensePromptViewController.h"
#import "UIImageEffects.h"

#define HELPKOFAX_EMAIL @"helpmobileteam@kofax.com"

@interface BaseViewController ()<MFMailComposeViewControllerDelegate>
{
    
}

@property(nonatomic,strong)UIImageView* blurredView;
@property(nonatomic,strong)UIVisualEffectView *blurEffectView;

@end

@implementation BaseViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)createViewBlurInBackground
{
    //listen to notifications of the app states
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createScreenShotBlur) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeScreenShotBlur) name:UIApplicationWillEnterForegroundNotification object:nil];
}

-(void)addCancelBarItem {
    
    self.utilitiesObject = [[AppUtilities alloc]init];
    
    //Uncomment this if you want a back arrow button instead of Cancel
    /*
     UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:BACKBUTTONIMAGE] style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
     {
     backButton.tintColor = [self.utilitiesObject colorWithHexString:[[ProfileManager sharedInstance]getActiveProfile].theme.titleColor];
     }*/
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:Klm(STATICCANCELBUTTONTEXT) style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonAction:)];
    
    //    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    //    {
    cancelButton.tintColor = [UIColor whiteColor];
    //    }
    self.navigationItem.leftBarButtonItem = cancelButton;

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    
    if(self.utilitiesObject)
        self.utilitiesObject = nil;
    
    //remove the notifications added
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _blurredView = nil;
    _blurEffectView = nil;
}


#pragma mark
#pragma mark screenshot blur methods

-(void)createScreenShotBlur
{
    if(IS_OS_8_OR_LATER)
    {
        if (!UIAccessibilityIsReduceTransparencyEnabled()) {
            self.view.backgroundColor = [UIColor clearColor];
            UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            self.blurEffectView.frame = self.view.bounds;
            self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self.view addSubview:self.blurEffectView];
        }  
        else {
            self.view.backgroundColor = [UIColor blackColor];
        }
    }
    else
    {
        UIImage * blurredImage = [UIImageEffects imageByApplyingLightEffectToImage:[self takeSnapshotOfView:self.view]];
        if(!self.blurredView)
        {
            self.blurredView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        [self.blurredView setContentMode:UIViewContentModeScaleToFill];
        [self.blurredView setImage:blurredImage];
        [self.view addSubview:self.blurredView];
        blurredImage = nil;

    }
    
}

-(void)removeScreenShotBlur
{
    if(IS_OS_8_OR_LATER)
    {
        [self.blurEffectView removeFromSuperview];
    }
    else
    {
        [self.blurredView removeFromSuperview];
        
    }
}

//method to take snapshot of the view
- (UIImage *)takeSnapshotOfView:(UIView *)view
{
    CGFloat reductionFactor = 1.25;
    UIGraphicsBeginImageContext(CGSizeMake(view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor));
    BOOL isSnapShotViewAvailable = [view drawViewHierarchyInRect:CGRectMake(0, 0, view.frame.size.width/reductionFactor, view.frame.size.height/reductionFactor) afterScreenUpdates:NO];
    if(isSnapShotViewAvailable)
    {
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    UIGraphicsEndImageContext();
    return nil;
    
}


#pragma mark Local Methods
/*
 This method is used to go back to the previous screen.
 */
-(IBAction)cancelButtonAction:(id)sender
{
    
}

#pragma mark - Mail Composer

//Method is used for showing invalid amount alert.

- (void)showInvalidAmountAlert
{
    if([UIAlertController class]){
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@""
                                                                         message:Klm(@"Please enter valid amount.") preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:Klm(@"OK")
                                                               style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                                                                   
                                                               }];
        
        [alertVc addAction:cancelAction];
        [self presentViewController:alertVc animated:YES completion:nil];
        
    }
    else{
        UIAlertView *aview = [[UIAlertView alloc]initWithTitle:@""
                                                       message:Klm(@"Please enter valid amount.")
                                                      delegate:nil
                                             cancelButtonTitle:@"OK"
                                             otherButtonTitles:nil, nil];
        [aview show];
    }
   
}

// This method sends the processed and unprocessed images to Mail Composer
-(void)composeMailWithSubject:(NSString *)strSubject withImages:(NSDictionary *)dictImages withResult:(NSString *)strExtractedResult {
    
    if([MFMailComposeViewController canSendMail]) {
        
        
        MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
        mailComposer.mailComposeDelegate = self;
        [mailComposer setSubject:strSubject];
        [mailComposer setToRecipients:[NSArray arrayWithObject:HELPKOFAX_EMAIL]];
        [mailComposer setMessageBody:@"" isHTML:NO];
        for(__strong NSString *strName in dictImages.allKeys){
            
            kfxKEDImage* processedImage = [dictImages objectForKey:strName];
            NSString *strImageType = @"";
            
            switch (processedImage.imageMimeType) {
                case MIMETYPE_TIF:
                    strName = [NSString stringWithFormat:@"%@.%@",strName,@"tif"];
                    strImageType=@"image/tiff";
                    break;
                case MIMETYPE_JPG:
                    strName = [NSString stringWithFormat:@"%@.%@",strName,@"jpeg"];
                    strImageType=@"image/jpeg";
                    break;
                case MIMETYPE_PNG:
                    strName = [NSString stringWithFormat:@"%@.%@",strName,@"png"];
                    strImageType=@"image/png";
                    break;
                case MIMETYPE_UNKNOWN:{
                    strName = [NSString stringWithFormat:@"%@.%@",strName,@"png"];
                    processedImage.imageMimeType=MIMETYPE_PNG;
                    strImageType=@"image/png";
                    break;
                }
                case MIMETYPE_LAST:
                    strName = [NSString stringWithFormat:@"%@.%@",strName,@"jpeg"];
                    processedImage.imageMimeType=MIMETYPE_JPG;
                    strImageType=@"image/jpeg";
                    break;
                default:
                    break;
            }
            NSString *strFilePath = [processedImage getFilePath];
            NSData *imageData;
            if(strFilePath==nil){
                
                // saving the file in documents directory

               /* int error = [processedImage specifyFilePath:[AppUtilities retrieveTheFilePath:strName]];
                NSLog(@"message %@",[kfxError findErrMsg:error]);
                NSLog(@"desc %@",[kfxError findErrDesc:error]);
                NSLog(@" File Path %@",[processedImage getFilePath]);
                int value = [processedImage imageWriteToFile];
                NSLog(@"message %@",[kfxError findErrMsg:value]);
                NSLog(@"desc %@",[kfxError findErrDesc:value]);
                imageData = [NSData dataWithContentsOfFile:[processedImage getFilePath]];
                [processedImage deleteFile]; */
                
                [processedImage imageWriteToFileBuffer];
                imageData = [NSData dataWithBytes:[processedImage getImageFileBuffer] length:processedImage.imageFileBufferSize];
                [processedImage clearFileBuffer];
                
            }
            else {
                imageData = [NSData dataWithContentsOfFile:strFilePath];
                
            }
            
            [mailComposer addAttachmentData:imageData mimeType:strImageType fileName:strName];
            
            imageData = nil;
            strImageType = nil;
            
        }
        dictImages = nil;
        
        // The extracted data needs to be sent as attachment
        // 1) First create the text file with extracted data
        NSString *strFileName = [NSString stringWithFormat:@"%@.txt",[AppUtilities genRandStringLength:FileNameLength]];
        [AppUtilities writeToTextFile:strExtractedResult withFileName:strFileName];
        // 2) Attach the text file as attachment
        NSString *strFilePath = [AppUtilities retrieveTheFilePath:strFileName];
        // 3) Attach the file as attachment
        NSData *dataFile = [NSData dataWithContentsOfFile:strFilePath];
        if(dataFile){
        [mailComposer addAttachmentData:dataFile mimeType:@"application/txt" fileName:@"ExtractedResult.txt"];
        }
        //4) Delete the file from Documents Directory
        [AppUtilities removeFile:strFileName];
        dataFile = nil;
        strFileName = nil;
        strFilePath = nil;
        
        [AppUtilities removeActivityIndicator];
    
            
        [self presentViewController:mailComposer animated:YES completion:NULL];

        
    }
    else {
        
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]; in iOS 8
        
      //  NSString *url = @"mailto:foo@example.com?cc=bar@example.com&subject=Greetings%20from%20Cupertino!&body=Wish%20you%20were%20here!";
      //  [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            
            [AppUtilities removeActivityIndicator];
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:Klm(@"Please configure your mail in Setting of the device") delegate:nil cancelButtonTitle:Klm(@"OK") otherButtonTitles:nil];
            [alertView show];
        });

       
    }
    
    
}

#pragma mark MFMailComposer

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    controller = nil;
    
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)cleanTheRawImages{
    
}

// check whether app has permission to access camera.
-(void)checkCameraAccess:(void (^)(BOOL))status
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusAuthorized)
    {
        status(YES);
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             if(granted)
             {
                 status(YES);
             }
             else
             {
                 status(NO);
             }
         }];
    }
    else if (authStatus == AVAuthorizationStatusRestricted)
    {
        status(NO);
    }
    else
    {
        status(NO);
    }
}

-(void)backButtonAction:(id)sender
{
    self.backButtonClicked = YES;
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
