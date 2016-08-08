//
//  CaptureSettings.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

//! This class is a model class for holding the settings needed for Camera
/**
 This class is responsible to hold all the settings needed for the camera. It would be a combination of settings from JSON and module specific settings
 */
#import <Foundation/Foundation.h>

@interface CaptureSettings : NSObject
{
    
}

@property(nonatomic)captureAnimationType captureExperience;
@property (nonatomic,strong) UIImage *tutorialSampleImage;
@property(nonatomic) BOOL showGallery;
@property(nonatomic) BOOL showAutoTorch;
@property(nonatomic) BOOL useVideoFrame;
@property(nonatomic) int stabilityDelay;
@property(nonatomic) int pitchValue;
@property(nonatomic) int rollValue;

@property (nonatomic) int centerShiftValue;


@property(nonatomic) BOOL showFlashOptions;
@property(nonatomic) BOOL hideForceCaptureMessage;
@property(nonatomic) BOOL hideCaptureButton;
@property(nonatomic) BOOL hideStaticFrame;
@property(nonatomic) BOOL doContinuousCapture;
//@property (nonatomic) BOOL isFirstLaunch;

@property(nonatomic) CGSize staticFrameSize;
@property(nonatomic) float staticFrameAspectRatio;
@property(nonatomic) float staticFramePaddingPercent;
@property(nonatomic) CGPoint staticFrameCenter;

@property(nonatomic) CGFloat zoomMinFillFraction;
@property(nonatomic) CGFloat zoomMaxFillFraction;

@property(nonatomic) int manualCaptureTime;


@property(nonatomic) BOOL showPageDetectBorders;

@property(nonatomic) int edgeDetection;


@property(nonatomic,strong) NSString* pageOrientationMessage;
@property(nonatomic,strong) NSString* holdSteadyMessage;
@property(nonatomic,strong) NSString* moveCloserMessage;
@property(nonatomic,strong) NSString* cancelButtonText;
@property(nonatomic,strong) NSString* userInstruction;
@property(nonatomic,strong) NSString* documentNotFoundMessage;

@property(nonatomic,strong) NSString* userInstructionMessage;
@property(nonatomic,strong) NSString* centerMessage;
@property(nonatomic,strong) NSString* zoomOutMessage;
@property(nonatomic,strong) NSString* capturedMessage;
@property(nonatomic,strong) NSString* holdParallelMessage;
@property(nonatomic,strong) NSString* orientationMessage;

@property (nonatomic) BOOL stabilityThresholdEnabled;
@property (nonatomic) BOOL pitchThresholdEnabled;
@property (nonatomic) BOOL rollThresholdEnabled;
@property (nonatomic) BOOL focusConstraintEnabled;
@property (nonatomic) int stabilityThreshold;
@property (nonatomic) int pitchThreshold;
@property (nonatomic) int rollThreshold;
@property (nonatomic) int longAxisThreshold;
@property (nonatomic) int shortAxisThreshold;

@property(nonatomic) BOOL doShowGuidingDemo;

//for check deposit
@property(nonatomic) float offset;

@property(nonatomic) BOOL isBackCheckSide;

@end
