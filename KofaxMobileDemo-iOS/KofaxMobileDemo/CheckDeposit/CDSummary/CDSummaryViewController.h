//
//  CDSummaryViewController.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 19/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CDSummaryViewController : BaseViewController
@property (nonatomic,strong) NSArray *checkResults;
@property (nonatomic,strong) Component *componentObject;
@property (nonatomic,strong) NSString *countryCode;
@end
