//
//  DLRegionViewController.h
//  KofaxMobileDemo
//
//  Created by Mahendra on 24/11/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@protocol CDCountryProtocol <NSObject>

-(void)countryForCDSelected : (NSString*)cdCountry;
-(void)countrySelectionCancelled;
-(void)countrySettingsClicked;


@end

@interface CDCountryViewController : BaseViewController
{
    
}

@property(nonatomic,assign)id<CDCountryProtocol>delegate;



@end
