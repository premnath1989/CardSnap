//
//  CreateProfileViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileManager.h"
#import "AppDelegate.h"
@interface CreateProfileViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIAlertViewDelegate>
{
    
}


-(id)initWithProfile: (Profile*)profile Withaction:(profileAction)action;
@end
