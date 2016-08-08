//
//  BaseViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 03/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
{
    
}

@property(nonatomic,strong)AppUtilities *utilitiesObject;

@property (nonatomic, assign) BOOL backButtonClicked;

-(void)cleanTheRawImages;
// Compose Mail in order to send the ImageSumamary
-(void)composeMailWithSubject:(NSString *)strSubject withImages:(NSDictionary *)dictImages withResult:(NSString *)strExtractedResult;
-(void)addCancelBarItem;

//Method is used for showing invalid amount alert.

- (void)showInvalidAmountAlert;
// check whether app has permission to access camera. 
-(void)checkCameraAccess:(void (^)(BOOL))status;

//this method blurs the current view (only when) app goes into background and hence avoids screenshot caching (potential security issue)
-(void)createViewBlurInBackground;
@end
