//
//  RTTISettingsViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/15/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface RTTISettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate, UITextFieldDelegate>
@property (nonatomic, assign) BOOL isODEEnabledForSelectedRegion;
@property (nonatomic, assign) BOOL isKofaxMobileIdEnabledForSelectedRegion;
-(id)initWithSettings: (Settings*)settings component:(Component*)component;
@end
