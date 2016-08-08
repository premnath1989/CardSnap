//
//  BaseFlowManager.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

//! This class is a base class for implementing flow manager
/**
 This class is a template for any of the flow managers that get created it will have required implementation of methods
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <kfxLibEngines/kfxEngines.h>
#import "CaptureSettings.h"
#import "CaptureViewController.h"
#import "Profile.h"
#import "ExhibitorViewController.h"
#import "ImageProcessor.h"
#import "ExtractionManager.h"
#import "AppStateMachine.h"
#import "BarcodeReaderViewController.h"
#import "AppParser.h"


@interface BaseFlowManager : NSObject<CaptureViewControllerProtocol,ExhibitorProtocol,ImageProcessorProtocol,ExtractionManagerProtocol,BarcodeReaderprotocol,ParserProtocol>


@property (nonatomic,strong) kfxKEDImage* capturedImage;
@property (nonatomic,readonly) NSMutableArray *processedResults;


-(id)initWithComponent : (Component*)component;
-(void)loadManager:(UINavigationController*)appNavController;
-(void)unloadManager;

-(void)showCamera;
-(void)processCapturedImage;
-(void)discardCapturedImage;
-(void)extractData:(kfxKEDImage *)processedImage;
-(void)showSummaryScreen;

@end
