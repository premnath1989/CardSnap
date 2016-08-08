//
//  EVRSSettingsViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface EVRSSettingsViewController : UIViewController<UITableViewDataSource,UITabBarDelegate,UITextFieldDelegate>
@property (nonatomic, assign) Theme *themeObject;
-(id)initWithSettings: (Settings*)settings andComponent:(Component *)compObject;
@end
