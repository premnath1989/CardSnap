//
//  DLSummaryViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 05/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//
//This Class is responsible to show the summary results of the DL

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DLData.h"
#import <kfxLibEngines/kfxEngines.h>

@protocol DLSummaryProtocol <NSObject>

@optional
-(void)licenseFrontThumbNailClicked;
-(void)licenseBackThumbNailClicked;
-(void)submitButtonClicked;
-(void)summaryCancelClicked;
-(void)settingsClicked;

@end

@interface DLSummaryViewController : BaseViewController
{
    
}
@property id <DLSummaryProtocol> delegate;

@property(nonatomic,strong)kfxKEDImage* frontProcessedImage;
@property(nonatomic,strong)kfxKEDImage* frontRawImage;
@property(nonatomic,strong)kfxKEDImage* backRawImage;
@property(nonatomic,strong)kfxKEDImage* barCodeImage;
@property (nonatomic) captureSides captureSide;
@property (nonatomic, strong) NSArray *resultsArray;

@property (nonatomic, assign) BOOL shouldImageDebuggingShown;
@property (nonatomic, assign) BOOL launchedByExtractionFailed;

@property (nonatomic, strong) NSError *extractedError;


-(id)initWithComponent:(Component*)component andDLData: (DLData*)dlData;
-(void)updateDLData:(DLData*)dlData;

@end
