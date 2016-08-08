//
//  ComponentSettingsViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/15/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileManager.h"

@interface ComponentSettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) NSMutableArray *settingsArray;
@property (nonatomic, assign) BOOL isODEEnabledForSelectedRegion;
@property (nonatomic, assign) BOOL isKofaxMobileIdEnabledForSelectedRegion;
-(id)initWithComponent : (Component*)component andTheme:(Theme*)themeObject;
@end
