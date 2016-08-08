//
//  BackgroundGraphicsViewController.h
//  Kofax Mobile Demo
//
//  Created by Rambabu N on 10/24/14.
//  Copyright (c) 2014 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import "Profile.h"
@interface BackgroundGraphicsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *pickerController;
-(id)initWithProfile:(Profile*)profile;
-(id)initWithComponent:(Component*)component;
@end
