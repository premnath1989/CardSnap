//
//  ValidationSettingsViewController.h
//  BankRight
//
//  Created by Rambabu N on 8/26/14.
//  Copyright (c) 2014 WIN Information Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface AdvancedSettingsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

-(id)initWithSettings: (Settings*)settings;
@end
