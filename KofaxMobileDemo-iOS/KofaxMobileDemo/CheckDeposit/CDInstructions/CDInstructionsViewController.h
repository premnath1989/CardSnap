//
//  CDInstructionsViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 10/31/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import "ProfileManager.h"
#import "CaptureViewController.h"
#import "BaseViewController.h"
#import <kfxLibEngines/kfxEngines.h>



@protocol CDInstructionsProtocol <NSObject>

-(void)checkFrontButtonClicked;
-(void)checkBackButtonClicked;
-(void)makeDepositButtonClicked;
-(void)backButtonClicked;
-(void)checkHistoryClicked;


@end

@interface CDInstructionsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>

-(id)initWithComponent: (Component*)component;
@property id <CDInstructionsProtocol> delegate;

@property (assign) int cdState;

@property (nonatomic,copy) UIImage *checkFront;
@property (nonatomic,copy) UIImage *checkBack;
@property (nonatomic,strong) kfxKEDImage *checkProcessedFront;
@property (nonatomic,strong) kfxKEDImage *checkProcessedBack;
@property (nonatomic,strong) kfxKEDImage *checkFrontRaw;
@property (nonatomic,strong) kfxKEDImage *checkBackRaw;

@property (nonatomic,strong) NSArray *checkResults;
@property (nonatomic,strong) NSError *extractedError;
@property (nonatomic, retain) NSString *checkAmount;
@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic) BOOL disableSettings;


@end
