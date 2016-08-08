//
//  CustomizationViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/14/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
@interface CustomizationViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
-(id)initWithProfile:(Profile*)profile;
@end
