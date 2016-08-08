//
//  BPInstructionsViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
@protocol CreditCardInstructionsProtocol <NSObject>

-(void)instructionContinueButtonClicked;
-(void)instructionSettingsButtonClicked;
-(void)instructionsBackButtonClicked;

@end
@interface CreditCardInstructionsViewController : UIViewController
@property id <CreditCardInstructionsProtocol> delegate;

-(id)initWithComponent:(Component*)component;
@end
