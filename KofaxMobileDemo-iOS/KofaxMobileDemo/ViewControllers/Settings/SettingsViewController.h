//
//  SettingsViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/13/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <MessageUI/MessageUI.h>
@interface SettingsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIAlertViewDelegate,MFMailComposeViewControllerDelegate>
{
    
}
@property(nonatomic,strong)IBOutlet UITableView* table;
-(void)importProfile:(NSURL*)url;
@end
