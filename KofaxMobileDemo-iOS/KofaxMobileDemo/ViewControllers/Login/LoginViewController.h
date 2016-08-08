//
//  LoginViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/17/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
@interface LoginViewController : UIViewController<UITextFieldDelegate>
-(id)initWithProfile:(Profile*)profile;
@end
