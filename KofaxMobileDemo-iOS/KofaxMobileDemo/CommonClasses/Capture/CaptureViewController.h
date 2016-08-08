//
//  CaptureViewController.h
//  Kofax Mobile Demo
//
//  Created by kaushik on 20/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <kfxLibEngines/kfxEngines.h>
#import <kfxLibUIControls/kfxKUIImageCaptureControl.h>
#import "CaptureSettings.h"
#import "BaseViewController.h"



@protocol CaptureViewControllerProtocol <NSObject>

-(void)imageCaptured:(kfxKEDImage*)capturedImage;
-(void)imageSelected:(kfxKEDImage*)capturedImage;
-(void)cancelCamera;

@end


@interface CaptureViewController : BaseViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) CaptureSettings* settings;

@property id <CaptureViewControllerProtocol> delegate;
//@property (nonatomic) BOOL appFromBackground;
@property (assign) BOOL loadAlbum;


-(id)initWithCaptureSettings : (CaptureSettings*)settings;
-(void)freeCaptureControl;

@end
