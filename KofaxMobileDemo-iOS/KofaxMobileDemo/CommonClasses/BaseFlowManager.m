//
//  BaseFlowManager.m
//  KofaxMobileDemo
//
//  Created by Mahendra on 31/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import "BaseFlowManager.h"




@interface BaseFlowManager()
{
    
}

//@property(nonatomic,strong)UINavigationController* navigationController;

@end

@implementation BaseFlowManager


-(id)initWithComponent : (Component*)component
{
    if(self = [super init])
    {
        
    }
    
    return self;
        
}

-(void)loadManager:(UINavigationController*)appNavController
{
    //self.navigationController = appNavController;
}

-(void)unloadManager
{
    //self.navigationController = nil;
}


-(void)showCamera
{
    
}



-(void)extractData:(kfxKEDImage *)processedImage
{
    
}

-(void)showSummaryScreen
{
    
}

-(void)processCapturedImage
{
    
}
-(void)discardCapturedImage
{
    
}


#pragma mark
#pragma mark exhibitor delegate methods
-(void)useButtonClicked
{
    //implement processor
}

-(void)retakeButtonClicked
{
    //[self showCamera];
}

-(void)cancelButtonClicked
{
    //[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark
#pragma mark Image Processor delegate methods

-(void)processingSucceeded:(BOOL)status withOutputImage:(kfxKEDImage *)processedImage
{
    
}


#pragma mark
#pragma mark Parser delegate methods



#pragma mark Capture control protocol
-(void)imageCaptured:(kfxKEDImage *)capturedImage
{
    //[self showPreview:capturedImage];
}

-(void)cancelCamera
{
    //[self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    NSLog(@"dealloc super");
}

@end
