//
//  ExhibitorViewController1.h
//  Kofax Mobile Demo
//
//  Created by kaushik on 30/10/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <kfxLibEngines/kfxEngines.h>
@protocol ExhibitorProtocol <NSObject>

-(void)useButtonClicked;
-(void)retakeButtonClicked;
-(void)cancelButtonClicked;
-(void)albumButtonClicked;
-(void)useSelectedPhotoButtonClicked;

@end

@interface ExhibitorViewController : BaseViewController
@property id <ExhibitorProtocol> delegate;

@property (nonatomic, strong) kfxKEDImage *inputImage;
@property (nonatomic, strong) NSString *leftButtonTitle,*rightButtonTitle;

@property (nonatomic) BOOL isCancelButtonShow;
@property (nonatomic) BOOL showTopBar;

//Array which has rectangles of all colored areas
@property (nonatomic,strong) NSArray *coloredAreas;


- (IBAction)discardImageCaptured;
/*
-(void) hideRegularToolBar;
-(void) showRegularToolBar;
*/

-(void) removeNavigationBarItems;

@end
