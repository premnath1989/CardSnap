//
//  CustomComponentCell.h
//  KofaxMobileDemo
//
//  Created by Harendra Singh on 17/02/16.
//  Copyright © 2016 Kofax. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomComponentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldValue;

@end
