//
//  CCSummaryViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/3/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Component.h"
#import <kfxLibEngines/kfxEngines.h>
#import "BaseViewController.h"
@protocol CustomComponentSummaryProtocol <NSObject>

-(void)summarySubmitButtonClicked;
-(void)summarySettingsButtonClicked;
-(void)summaryCancelButtonClicked;
-(void)summaryPreviewButtonClicked:(NSMutableArray*)results;

@end
@interface CustomComponentSummaryViewController : BaseViewController
@property id <CustomComponentSummaryProtocol> delegate;

@property (nonatomic, strong) NSError *extractedError;

-(id)initWithComponent:(Component*)component kedImage:(kfxKEDImage*)image andRawImage:(kfxKEDImage*)rawImage andResults:(NSArray*)results;
@end
