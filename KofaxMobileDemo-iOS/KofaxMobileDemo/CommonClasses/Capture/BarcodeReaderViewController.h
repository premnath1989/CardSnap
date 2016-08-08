//
//  BarcodeReaderViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 04/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibEngines/kfxEngines.h>
@protocol BarcodeReaderprotocol <NSObject>

@optional
-(void)barcodeFound :(kfxKEDBarcodeResult *)result withImage:(kfxKEDImage*)barcodeImage;
-(void)skipButtonClicked;

@end

@interface BarcodeReaderViewController : BaseViewController
{
    
}

@property id <BarcodeReaderprotocol> delegate;

@end
