//
//  CCardCaptureViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/26/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <kfxLibUIControls/KFXCreditCardCaptureView.h>
#import <kfxLibEngines/kfxKEDImage.h>
#import "BaseViewController.h"

@protocol CreditCardProtocol <NSObject>

-(void)creditCardCaptureComplete:(KFXCreditCard*)creditCardInfo;
-(void)cancelCardCapture;

@end
@interface CreditCardCaptureViewController : BaseViewController
@property id <CreditCardProtocol> delegate;
@end
