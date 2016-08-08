//
//  BPInstructionsViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
@protocol BPInstructionsProtocol <NSObject>

-(void)instructionContinueButtonClicked;
-(void)instructionSettingsButtonClicked;
-(void)instructionsBackButtonClicked;

@end
@interface BPInstructionsViewController : UIViewController
@property id <BPInstructionsProtocol> delegate;

-(id)initWithComponent:(Component*)component;
@end
