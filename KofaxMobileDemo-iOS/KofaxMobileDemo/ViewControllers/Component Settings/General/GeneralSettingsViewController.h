//
//  ApplicationTextsViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/21/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileManager.h"
@interface GeneralSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
-(id)initWithComponent:(Component*)component;
@end
