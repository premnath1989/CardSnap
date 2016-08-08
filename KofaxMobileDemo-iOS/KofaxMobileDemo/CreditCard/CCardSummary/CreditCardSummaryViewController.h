//
//  CCardSummaryViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/KFXCreditCardCaptureView.h>
#import "BaseViewController.h"
@protocol CreditCardSummaryProtocol <NSObject>

-(void)summarySubmitButtonClicked;
-(void)summarySettingsButtonClicked;
-(void)summaryCancelButtonClicked;
-(void)summaryRetakeButtonClicked;
-(void)summaryPreviewButtonClicked;
@end
@interface CreditCardSummaryViewController : BaseViewController
@property id <CreditCardSummaryProtocol> delegate;

-(id)initWithComponent:(Component*)component andCreditCard:(NSMutableDictionary*)creditCard;

//Method called to update the credit card extraction data
//This method is called only for extraction with RTTI
-(void)updateCreditCardData:(NSMutableDictionary*)creditCard;
@end
