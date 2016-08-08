//
//  DLRegionViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 24/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "DLRegionAttributes.h"

@protocol DLRegionProtocol <NSObject>

-(void)regionForDLSelected : (DLRegionAttributes *)dlRegion;
-(void)regionSelectionCancelled;
-(void)regionSettingsClicked;


@end

@interface DLRegionViewController : BaseViewController
{
    
}

@property(nonatomic,assign)id<DLRegionProtocol>delegate;
@property(nonatomic) Component* selectedComponent;


@end
