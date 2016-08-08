//
//  DLInstructionsViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
#import "BaseViewController.h"



@protocol DLInstructionsProtocol <NSObject>


-(void)onDLFrontClicked;
-(void)onDLBackClicked;
-(void)onSettingsClicked;
-(void)backButtonClicked;
-(void)assignCaptureSide:(captureSides)captureSideSelected;
-(void)skipButtonClicked;
-(BOOL)checkForModels;

@end

@interface DLInstructionsViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
}
@property id <DLInstructionsProtocol> delegate;

//These images if set will be displayed else placeholder images
@property(nonatomic,strong)UIImage* frontThumbnail;
@property(nonatomic,strong)UIImage* backThumbnail;

-(id)initWithComponent: (Component*)component;

@end
