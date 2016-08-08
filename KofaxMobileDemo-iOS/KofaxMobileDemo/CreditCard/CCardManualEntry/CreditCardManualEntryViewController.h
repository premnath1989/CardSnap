//
//  CCardManualEntryViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/KFXCreditCardCaptureView.h>
@protocol CreditCardManualEntryProtocol <NSObject>

-(void)manualDoneButtonClicked:(KFXCreditCard*)creditCard;
-(void)manualCancelButtonClicked;

@end
@interface CreditCardManualEntryViewController : UIViewController
@property id <CreditCardManualEntryProtocol> delegate;

-(id)initWithCreditCard:(KFXCreditCard*)creditCard andComponent:(Component*)component;
@end
