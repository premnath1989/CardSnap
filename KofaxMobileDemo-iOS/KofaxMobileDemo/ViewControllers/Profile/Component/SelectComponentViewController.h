//
//  SelectComponentViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileManager.h"
@interface SelectComponentViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
}
-(id)initwithArray : (NSMutableArray*)components andTheme:(Theme *)theme;
@end
