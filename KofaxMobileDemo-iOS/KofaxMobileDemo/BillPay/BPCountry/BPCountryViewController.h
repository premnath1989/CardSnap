//
//  DLRegionViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 24/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol BPCountryProtocol <NSObject>

-(void)countryForBPSelected : (NSString*)bpCountry;
-(void)countrySelectionCancelled;
-(void)countrySettingsClicked;


@end

@interface BPCountryViewController : BaseViewController
{
    
}

@property(nonatomic,assign)id<BPCountryProtocol>delegate;



@end
