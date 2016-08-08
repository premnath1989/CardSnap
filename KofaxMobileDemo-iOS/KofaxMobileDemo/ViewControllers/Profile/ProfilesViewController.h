//
//  ProfilesViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilesViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>


-(id)initWithProfileAction: (profileAction)profileAction;

@end
