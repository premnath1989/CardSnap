//
//  SelectColorViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/16/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"
@interface SelectColorViewController : UIViewController
-(id)initWithProfile:(Profile*)profile withType:(colorType)colorType;
@end
