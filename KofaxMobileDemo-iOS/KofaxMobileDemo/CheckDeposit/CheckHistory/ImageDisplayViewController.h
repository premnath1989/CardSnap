//
//  ImageDisplayViewController.h
//  KofaxMobileDemo
//
//  Created by Rambabu N on 11/14/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <kfxLibUIControls/kfxUIControls.h>
#import <kfxLibEngines/kfxKEDImage.h>

@interface ImageDisplayViewController : UIViewController
-(id)initWithImage:(kfxKEDImage*)image;
@end
