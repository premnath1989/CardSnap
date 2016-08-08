//
//  CheckInfoViewController.h
//  BankRight
//
//  Created by Rambabu N on 8/18/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckInfoCustomCell.h"
#import "Component.h"
#import "BaseViewController.h"

@interface CheckInfoViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *checkResults;
@property (nonatomic,strong) Component *componentObject;
@property (nonatomic, strong) NSString *countryCode;

-(IBAction)backButtonAction:(id)sender;
@end
